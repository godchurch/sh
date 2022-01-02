#!/bin/sh
# https://help.ubuntu.com/community/Full_Disk_Encryption_Howto_2019

set -e
set -x

test "$#" -eq 1
export DEVICE="$1"
printf '%s' "$DEVICE_NAME" | grep -q 'nvme' && \
  export DEVICE_NAME="${DEVICE##*/}p" || \
  export DEVICE_NAME="${DEVICE##*/}"

effectiveUserIdentity=`id -u`
test "$effectiveUserIdentity" -eq 0

mount | grep -q 'efivars'

sgdisk --zap-all "$DEVICE"
sgdisk --new=1:0:+768M --typecode=1:8301 --change-name=1:/boot \
       --new=2:0:+2M --typecode=2:ef02 --change-name=2:GRUB \
       --new=3:0:+128M --typecode=3:ef00 --change-name=3:EFI-SP \
       --new=5:0:0 --typecode=5:8301 --change-name=5:rootfs \
       "$DEVICE"
sgdisk --hybrid 1:2:3 "$DEVICE"

cryptsetup luksFormat --type=luks1 "${DEVICE}p1"
cryptsetup luksFormat "${DEVICE}p5"
cryptsetup open "${DEVICE}p1" "LUKS_BOOT"
cryptsetup open "${DEVICE}p5" "${DEVICE_NAME}5_crypt"

mkfs.ext4 -L boot "/dev/mapper/LUKS_BOOT"
mkfs.vfat -F 16 -n EFI-SP "${DEVICE}p3"
mkfs.ext4 "/dev/mapper/${DEVICE}5_crypt"

# run installer, manually configure partitions, setup user account...
set +x; printf '%s\n' \
  '################################################' \
  '####            RUN INSTALLER               ####' \
  '################################################'
while [ ! -d /target/etc/default/grub.d ]; do sleep 1; done
printf 'GRUB_ENABLE_CRYPTODISK=y\n' >> /target/etc/default/grub

printf '\n:: After the installer is done press Enter: '; read -r NULL

# Post Installation:
set -x
mount /dev/mapper/root /target
for n in proc sys dev etc/resolv.conf; do mount --rbind /$n /target/$n; done
chroot /target
mount -a
printf 'KEYFILE_PATTERN=/etc/luks/*.keyfile\n' >> /etc/cryptsetup-initramfs/conf-hook
printf 'UMASK=0077\n' >> /etc/initramfs-tools/initramfs.conf
mkdir /etc/luks
dd if=/dev/urandom of=/etc/luks/boot_os.keyfile bs=4096 count=1
chmod u=rx,go-rwx /etc/luks
chmod u=r,go-rwx /etc/luks/boot_os.keyfile
cryptsetup luksAddKey "${DEVICE}p1" /etc/luks/boot_os.keyfile
cryptsetup luksAddKey "${DEVICE}p5" /etc/luks/boot_os.keyfile
DEVICE_UUID_BOOT="`blkid -s UUID -o value "${DEVICE}p1"`"
DEVICE_UUID_CRYPT="`blkid -s UUID -o value "${DEVICE}p5"`"
printf 'LUKS_BOOT UUID=%s /etc/luks/boot_os.keyfile luks,discard\n' "$DEVICE_UUID_BOOT" >> /etc/crypttab
printf '%s UUID=%s /etc/luks/boot_os.keyfile luks,discard\n' "${DEVICE_NAME}5_crypt" "$DEVICE_UUID_CRYPT" >> /etc/crypttab
update-initramfs -u -k all
set +x; printf '%s\n' \
  '################################################' \
  '####          DONE: YOU CAN REBOOT          ####' \
  '################################################'
