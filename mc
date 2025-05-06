#!/usr/bin/sh

usage () {
    printf "%s\n" "Usage: ${0##*/} [-h] -b|-v|-m [arguments]" >&2
    exit "$1"
}
quit () {
    printf "%s: %s\n" "${0##*/}" "$2" >&2
    exit "$1"
}

PATH="/usr/bin"

unset -v option
unset -v argument
unset -v operation

while getopts ":hbvm" option; do
    case "$option" in
        h) usage 0 ;;
        b) operation=brightness ;;
        v) operation=volume ;;
        m) operation=mute ;;
        :) quit 1 "option requires an argument -- $OPTARG" ;;
        ?) quit 1 "illegal option -- $OPTARG" ;;
    esac
done
shift $(($OPTIND - 1))

[ -z "${operation-}" ] && usage 1

case $# in
    0) primary=getvcp ;;
    *) primary=setvcp ;;
esac

case "$operation" in
    brightness) code=0x10 ;;
    volume) code=0x62 ;;
    mute) code=0x8d ;;
esac

GREP='^[[:blank:]]+I2C bus:[[:blank:]]+/dev/i2c-[0-9]+$'
SED='s|^.*-([0-9]+)$|ddcutil -b \1 "$primary" "$code" "$@";|'

set -e
_ddcutil="$(ddcutil detect)"
_ddcutil="$(printf "%s\n" "$_ddcutil" | grep -E "$GREP")"
_ddcutil="$(printf "%s\n" "$_ddcutil" | sed -E "$SED")"
set +e

[ "$primary" = setvcp ] && _ddcutil="set -x;
$_ddcutil"

eval $_ddcutil
