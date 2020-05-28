#!/bin/sh

set -e -x

if test -z "$1"; then
  printf "Usage: %s [chroot directory]" "$0"
  exit 1
fi
TARGET="$(realpath "$1")"

if test -d "$TARGET"; then
  mount proc   "$TARGET/proc"    -t proc     -o nosuid,nodev,noexec
  mount sys    "$TARGET/sys"     -t sysfs    -o nosuid,nodev,noexec,ro
  mount udev   "$TARGET/dev"     -t devtmpfs -o mode=0755,nosuid
  mount devpts "$TARGET/dev/pts" -t devpts   -o mode=0620,gid=5,nosuid,noexec
  mount shm    "$TARGET/dev/shm" -t tmpfs    -o mode=1777,nosuid,nodev
  mount run    "$TARGET/run"     -t tmpfs    -o mode=0755,nosuid,nodev
  mount tmp    "$TARGET/tmp"     -t tmpfs    -o mode=1777,strictatime,nodev,nosuid
fi

if ! test -f "$TARGET/run/systemd/resolve/stub-resolv.conf"; then
  mkdir -p "$TARGET/run/systemd/resolve"
  echo "nameserver 1.1.1.1" > "$TARGET/run/systemd/resolve/stub-resolv.conf"
fi

ln -sf ../run/systemd/resolve/stub-resolv.conf "$TARGET/etc/resolv.conf"
