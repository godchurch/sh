#!/bin/sh

set -ex

BLOCK_DEVICE="$1"
TARGET="${2%/}"

lsblk -lpno NAME | grep "^${BLOCK_DEVICE}$"
test -n "$TARGET"
! mountpoint -q "$TARGET"

test -d "$TARGET" || mkdir "$TARGET"; mount "$BLOCK_DEVICE" "$TARGET"

test -d "$TARGET/proc" || mkdir "$TARGET/proc"; mount -t proc proc "$TARGET/proc"
test -d "$TARGET/sys" || mkdir "$TARGET/sys"; mount -t sysfs sysfs "$TARGET/sys"
test -d "$TARGET/tmp" || mkdir "$TARGET/tmp"; mount -t tmpfs tmpfs "$TARGET/tmp"
test -d "$TARGET/run" || mkdir "$TARGET/run"; mount -t tmpfs run "$TARGET/run"

if test -e "$TARGET/etc/resolv.conf" || test -L "$TARGET/etc/resolv.conf"; then
  RESOLV_CONF="$TARGET/etc/resolv.conf"
  printf "%s\n" "nameserver 1.1.1.1" > "$TARGET/tmp/default-resolv.conf.$$"
  if test -L "$RESOLV_CONF"; then
    RESOLV_CONF="$(readlink "$RESOLV_CONF")"
    case "$RESOLV_CONF" in
      /*) RESOLV_CONF="${TARGET}${RESOLV_CONF}" ;;
      *) RESOLV_CONF="$TARGET/etc/$RESOLV_CONF" ;;
    esac
    test -f "$RESOLV_CONF" || install -Dm644 /dev/null "$RESOLV_CONF"
  fi
  mount --bind "$TARGET/tmp/default-resolv.conf.$$" "$RESOLV_CONF"
fi

test -d "$TARGET/dev" || mkdir "$TARGET/dev"; \
  mount --bind /dev "$TARGET/dev"; mount --make-slave "$TARGET/dev"
test -d "$TARGET/dev/pts" || mkdir "$TARGET/dev/pts"; \
  mount --bind /dev/pts "$TARGET/dev/pts"; mount --make-slave "$TARGET/dev/pts"
