#!/bin/sh

set -e
TARGET="${1%/}"
test -z "$TARGET" && { printf "Usage: %s [chroot directory]" "$0"; exit 1; }
set -x
mountpoint "$TARGET"; test -d "$TARGET"
mount -t proc proc "$TARGET/proc"
mount -t sysfs sysfs "$TARGET/sys"
mount --bind /dev "$TARGET/dev"

if test -e "$TARGET/etc/resolv.conf"; then
  mount -t tmpfs run "$TARGET/run"
  RESOLV_CONF="$TARGET/etc/resolv.conf"
  printf "%s\n" "nameserver 1.1.1.1" > "$TARGET/run/default-resolv.conf"
  if test -L "$RESOLV_CONF"; then
    RESOLV_CONF="$(readlink "$RESOLV_CONF")"
    case "$RESOLV_CONF" in
      /*) RESOLV_CONF="${TARGET}${RESOLV_CONF}" ;;
      *) RESOLV_CONF="$TARGET/etc/$RESOLV_CONF" ;;
    esac
    RESOLV_CONF="${RESOLV_CONF%/}"
    test -f "$RESOLV_CONF" || install -Dm644 /dev/null "$RESOLV_CONF"
  fi
  mount --bind "$TARGET/run/default-resolv.conf" "$RESOLV_CONF"
fi
