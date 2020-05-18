#!/bin/sh

set -e -x

if test -z "$1"; then
  printf "Usage: %s [chroot directory]" "$0"
  exit 1
fi
CHROOT="$(realpath "$1")"

if test -d "$CHROOT"; then
  mount proc   "$CHROOT/proc"    -t proc     -o nosuid,nodev,noexec
  mount sys    "$CHROOT/sys"     -t sysfs    -o nosuid,nodev,noexec,ro
  mount udev   "$CHROOT/dev"     -t devtmpfs -o mode=0755,nosuid
  mount devpts "$CHROOT/dev/pts" -t devpts   -o mode=0620,gid=5,nosuid,noexec
  mount shm    "$CHROOT/dev/shm" -t tmpfs    -o mode=1777,nosuid,nodev
  mount run    "$CHROOT/run"     -t tmpfs    -o mode=0755,nosuid,nodev
  mount tmp    "$CHROOT/tmp"     -t tmpfs    -o mode=1777,strictatime,nodev,nosuid
fi

#if ! test -f /run/systemd/resolve/stub-resolv.conf; then
#  mkdir -p /run/systemd/resolve
#  echo "nameserver 1.1.1.1" > /run/systemd/resolve/stub-resolv.conf
#fi
#
#ln -sf ../run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
