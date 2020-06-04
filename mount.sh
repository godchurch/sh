#!/bin/sh

set -e
test -z "$1" && { printf "Usage: %s [chroot directory]" "$0"; exit 1; }
set -x
mountpoint "$1"
test -d "$1"
mount -t proc proc "$1/proc"
mount -t sysfs sysfs "$1/sys"
mount -t tmpfs run "$1/run"
mkdir -p "$1/run/systemd/resolve"
printf "%s\n" "nameserver 1.1.1.1" > "$1/run/systemd/resolve/stub-resolv.conf"
