#!/bin/sh

set -e
test -z "$1" && { printf "Usage: %s [chroot directory]" "$0"; exit 1; }
set -x
mountpoint "$TARGET"
test -d "$TARGET"
mount -t proc proc "$TARGET/proc"
mount -t sysfs sysfs "$TARGET/sys"
mount -t tmpfs run "$TARGET/run"
mkdir -p "$TARGET/run/systemd/resolve"
printf "%s\n" "nameserver 1.1.1.1" > "$TARGET/run/systemd/resolve/stub-resolv.conf"
