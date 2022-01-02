#!/bin/sh

required_commands='debootstrap fdisk'
mkfifo_file="named_pipe.$$"
build_directory="/target"

build_files_directory="$build_directory/build-files"

arch='amd64'
hostname='ubuntu'

code_name="$1"
device_name="$2"
device_part_1="${2}1"
device_part_2="${2}2"

default_username="user"
user_home="/home/$default_username"
login_script="$user_home/.local/bin/customlogin"
systemd_service_dir="/etc/systemd/system/getty@tty1.service.d"
autologin_service="$systemd_service_dir/autologin.conf"
packages_to_install="linux-image-generic linux-headers-generic grub-pc build-essential alsa-utils pulseaudio libavcodec-extra unzip curl xorg i3 xterm mpv firefox"
packages_to_purge=""

msg() {
  # 1) NORMAL MAIN       3) WARNING MAIN       5) ERROR MAIN
  # 2) NORMAL SECONDARY  4) WARNING SECONDARY  6) ERROR SECONDARY
  # 0) CUSTOM

  case "$1" in
    1) _msg_fmt="$2"; shift 2; printf "==> ${_msg_fmt}\n" "$@" ;;
    2) _msg_fmt="$2"; shift 2; printf "  -> ${_msg_fmt}\n" "$@" ;;
    3) _msg_fmt="$2"; shift 2; printf "==> [WARNING]: ${_msg_fmt}\n" "$@" ;;
    4) _msg_fmt="$2"; shift 2; printf "  -> [WARNING]: ${_msg_fmt}\n" "$@" ;;
    5) _msg_fmt="$2"; shift 2; printf "==> [ERROR]: ${_msg_fmt}\n" "$@" ;;
    6) _msg_fmt="$2"; shift 2; printf "  -> [ERROR]: ${_msg_fmt}\n" "$@" ;;
    0) shift 1; printf "$@" ;;
  esac
}

_cleanup() { rm -f "$mkfifo_file"; }

trap "_cleanup" EXIT


_create_named_pipe() {
  msg 1 'Creating a named pipe for internal command.'
  mkfifo "$mkfifo_file" \
    || { msg 5 'Unable to create named pipe [%s]' "$mkfifo_file"; return 1; }

  return 0
}

_check_effective_user_id() {
  msg 1 'Checking for root privilages.'
  test "$(id -u)" -eq 0 \
    || { msg 5 'You do not have root privilages.'; return 1; }

  return 0
}

_check_for_required_commands() {
  msg 1 'Checking for required commands.'
  for current_command in "$@"; do
    shift; command -v "$current_command" > /dev/null \
      || set -- "$@" "$current_command"
  done
  test "$#" -eq 0 || { msg 5 'Missing command [%s].' "$@"; return 1; }

  return 0
}

_check_for_required_arguments() {
  msg 1 'Checking for required arguments.'
  case "$#" in
    0) msg 5 'Missing argument [%s].' 'codename'; return 1 ;;
    1) msg 5 'Missing argument [%s].' 'device'; return 1 ;;
    2) ;;
    *) msg 5 'To much arguments supplied.'; return 1 ;;
  esac

  return 0
}

_format_disk() {
  set -- 'g' 'n' '' '' '4095' 'n' '' '4096' '' 't' '1' '4' 't' '2' '20' 'w'
  printf "%s\n" "$@" > "$mkfifo_file" &
  msg 1 'Formating device [%s].' "$device_name"
  fdisk "$device_name" < "$mkfifo_file" \
    || { msg 5 'Unable to format device [%s].' "$device_name"; return 1; }
  msg 1 'Creating an [%s] file system on [%s].' 'ext4' "$device_part_2"
  mkfs.ext4 -F "$device_part_2" \
    || { msg 5 'Unable to create file system [%s] on [%s].' 'ext4' "$device_part_2"; return 1; }

  return 0
}

_mount_partiion_to_build_directory() {
  msg 1 'Creating build directory [%s].' "$build_directory"
  mkdir -p "$build_directory" || return 1
  msg 1 'Mounting [%s] to build directory [%s].' "$device_part_2" "$build_directory"
  mount "$device_part_2" "$build_directory" \
    || { msg 5 'Unable to mount partion [%s] at [%s].' "$device_part_2" "$build_directory" ; return 1; }

  return 0
}

_download_base_files() {
  msg 1 'Downloading base files to build directory [%s].' "$build_directory"
  debootstrap --arch "$arch" "$code_name" "$build_directory" \
    || { msg 5 'Unable to download base files.'; return 1; }

  return 0
}

_setting_up_chroot_environment() {
  msg 1 'Setting up mounts for chroot environment.'
  msg 2 'Mounting [%s]' 'proc'
  mkdir -p "$build_directory/proc"; mount -t proc proc "$build_directory/proc"
  msg 2 'Mounting [%s]' 'sys'
  mkdir -p "$build_directory/sys"; mount -t sysfs sysfs "$build_directory/sys"
  msg 2 'Mounting [%s]' 'tmp'
  mkdir -p "$build_directory/tmp"; mount -t tmpfs tmpfs "$build_directory/tmp"
  msg 2 'Mounting [%s]' 'run'
  mkdir -p "$build_directory/run"; mount -t tmpfs run "$build_directory/run"

  msg 2 'Setting up networking [%s].' 'resolv.conf'
  if test -e "$build_directory/etc/resolv.conf" || test -L "$build_directory/etc/resolv.conf"; then
    resolve_configuration="$build_directory/etc/resolv.conf"
    printf "%s\n" "nameserver 1.1.1.1" > "$build_directory/run/default-resolv.conf"
    if test -L "$resolve_configuration"; then
      resolve_configuration="$(readlink "$resolve_configuration")"
      case "$resolve_configuration" in
        /*) resolve_configuration="${build_directory}${resolve_configuration}" ;;
        *) resolve_configuration="$build_directory/etc/$resolve_configuration" ;;
      esac
      test -f "$resolve_configuration" || install -Dm644 /dev/null "$resolve_configuration"
    fi
    msg 2 'Binding [%s]' 'resolv.conf'
    mount --bind "$build_directory/run/default-resolv.conf" "$resolve_configuration"
  fi
  msg 2 'Binding [%s]' 'dev'
  mkdir -p "$build_directory/dev"; mount --bind /dev "$build_directory/dev"

  return 0
}

_create_network_file() {
  msg 2 'Creating network file at [%s].' "$build_directory/etc/netplan/01-netcfg.yaml"
  mkdir -p "$build_directory/etc/netplan" || return 1
  ip_link_info="$(ip link show)" || return 1
  ip_link_info="$(printf "%s\n" "$ip_link_info" \
    | sed -n -e '/[[:blank:]]lo:/d' -e '/^[[:digit:]]/s/^[[:digit:]]*:[[:blank:]]*\([[:alnum:]]*\):.*$/\1/p' | head -n1)"

  printf 'network:\n  ethernets:\n    %s:\n      dhcp4: true\n  version: 2\n' "$ip_link_info" \
    | tee "$build_directory/etc/netplan/01-netcfg.yaml" > /dev/null || return 1
}

_create_fstab_file() {
  msg 2 'Creating fstab file at [%s].' "$build_directory/etc/fstab"
  block_id_info_line="$(blkid "$device_part_2")" || return 1
  block_id_info_line="$(printf '%s\n' "$block_id_info_line" \
    | sed 's/^.*[[:blank:]]UUID="\([^"]\{1,\}\).*[[:blank:]]TYPE="\([^"]\{1,\}\)".*$/UUID=\1 \/ \2 defaults 0 1/')" || return 1

  printf '%s\n' \
    "$block_id_info_line" \
    'tmpfs /tmp tmpfs nosuid,nodev 0 0' \
    | tee "$build_directory/etc/fstab" > /dev/null || return 1

  return 0
}

_create_hostname_file() {
  msg 2 'Creating hostname file at [%s].' "$build_directory/etc/hostname"
  printf '%s\n' "$hostname" > "$build_directory/etc/hostname"
}

_create_hosts_file() {
  msg 2 'Creating hosts file at [%s].' "$build_directory/etc/hosts"
  printf '127.0.0.1    localhost\n127.0.1.1    %s\n' \
    "$hostname" > "$build_directory/etc/hosts"
}

_create_apt_sources_file() {
  msg 2 'Creating sources file at [%s].' "$build_directory/etc/apt/sources.list"
  mkdir -p "$build_directory/etc/apt"
  printf 'deb http://archive.ubuntu.com/ubuntu/ %s main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu/ %s-updates main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu/ %s-backports main restricted universe multiverse
deb http://security.ubuntu.com/ubuntu %s-security main restricted universe multiverse
# deb http://archive.canonical.com/ubuntu %s partner' \
"$code_name" "$code_name" "$code_name" "$code_name" "$code_name" \
  | tee "$build_directory/etc/apt/sources.list" > /dev/null || return 1

  return 0
}


_create_build_files() {
  msg 1 'Creating build files.'
  _create_network_file || { msg 6 'Unable to create a network file.'; return 1; }
  _create_fstab_file || { msg 6 'Unable to create a fstab file.'; return 1; }
  _create_hostname_file || { msg 6 'Unable to create a hostname file.'; return 1; }
  _create_hosts_file || { msg 6 'Unable to create a hosts file.'; return 1; }
  _create_apt_sources_file || { msg 6 'Unable to create a sources file.'; return 1; }

  return 0
}

_modify_system_in_chroot_environment() {
LC_ALL=C chroot "$build_directory" /bin/sh -c "
set -e
set -x
apt-get update -y
apt-get dist-upgrade -y
test -n '$packages_to_install' && apt-get install -y $packages_to_install
test -n '$packages_to_purge' && apt-get purge -y $packages_to_purge
apt-get autoremove --purge -y
apt-get clean -y
sed 's/^\(GRUB_CMDLINE_LINUX_DEFAULT\)=\".*\"$/#&\\
\1=\"\"/' /etc/default/grub > /tmp/grub_file
cp /tmp/grub_file /etc/default/grub
mkdir -p '$systemd_service_dir'
cat > '$autologin_service' << _HEREDOC
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin '$default_username' --noclear %I \\\$TERM
_HEREDOC
mkdir -p /ram
cat >> /etc/fstab << _HEREDOC
tmpfs /ram tmpfs rw 0 0
_HEREDOC
for FILE in .bash_logout .bashrc .profile; do
  test ! -f \"/tmp/skel/\$FILE\" \
    && test -f \"/etc/skel/\$FILE\" \
    && cp \"/etc/skel/\$FILE\" \"/tmp/skel/\$FILE\"
done
useradd -m -k /tmp/skel -d '$user_home' -s '$login_script' '$default_username'
passwd '$default_username' << _HEREDOC
$default_username
$default_username
_HEREDOC"
}

_main() {
  _check_effective_user_id || return 1
  _check_for_required_arguments "$@" || return 1
  _check_for_required_commands $required_commands || return 1

  _create_named_pipe || return 1
  _format_disk || return 1
  _mount_partiion_to_build_directory || return 1
  _download_base_files || return 1
  _setting_up_chroot_environment || return 1

  _create_build_files || return 1
  _modify_system_in_chroot_environment || return 1

  return 0
}

_main "$@"
