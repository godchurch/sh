#!/bin/sh

set -e -x
TARGET="${1%/}"
test -n "$TARGET"
mountpoint -q "$TARGET";
mount -t proc proc "$TARGET/proc"
mount -t sysfs sysfs "$TARGET/sys"
if test -e "$TARGET/etc/resolv.conf" || test -L "$TARGET/etc/resolv.conf"; then
  RESOLV_CONF="$TARGET/etc/resolv.conf"
  mount -t tmpfs run "$TARGET/run"
  printf "%s\n" "nameserver 1.1.1.1" > "$TARGET/run/default-resolv.conf"
  if test -L "$RESOLV_CONF"; then
    RESOLV_CONF="$(readlink "$RESOLV_CONF")"
    case "$RESOLV_CONF" in
      /*) RESOLV_CONF="${TARGET}${RESOLV_CONF}" ;;
      *) RESOLV_CONF="$TARGET/etc/$RESOLV_CONF" ;;
    esac
    test -f "$RESOLV_CONF" || install -Dm644 /dev/null "$RESOLV_CONF"
  fi
  mount --bind "$TARGET/run/default-resolv.conf" "$RESOLV_CONF"
fi
mount --bind /dev "$TARGET/dev"
