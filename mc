#!/bin/sh

usage () {
    printf "%s\n" "Usage: ${0##*/} [-h] -b|-v|-m [-d display] [arguments]" >&2
    exit "$1"
}
die () {
    printf "%s\n" "$2" >&2
    exit "$1"
}

PATH=$(command -p getconf PATH) || exit $?

unset -v display
unset -v operation
while getopts ":hd:bvm" option; do
    case "$option" in
        h) usage 0 ;;
        d) display="$OPTARG" ;;
        b) operation=brightness ;;
        v) operation=volume ;;
        m) operation=mute ;;
        :) die 1 "${0##*/}: option requires an argument -- $OPTARG" ;;
        ?) die 1 "${0##*/}: illegal option -- $OPTARG" ;;
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

case "${display+X}" in
    X)
        [ "$primary" = setvcp ] && set -x
        ddcutil -d "$display" "$primary" "$code" "$@"
        ;;
    *)
        [ "$primary" = setvcp ] && set -x
        ddcutil -d 1 "$primary" "$code" "$@"
        ddcutil -d 2 "$primary" "$code" "$@"
        ;;
esac
