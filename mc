#!/bin/sh

unset display operation
while getopts :hd:bvm option; do
    case "$option" in
        h) printf "Usage: %s [-d display] [-b|-v|-m] [arguments]\n" "${0##*/}" >&2; exit 0 ;;
        d) display="$OPTARG" ;;
        b) operation="brightness" ;;
        v) operation="volume" ;;
        m) operation="mute" ;;
        :) printf "%s: option requires an argument -- %c\n" "${0##*/}" "$OPTARG" 1>&2; exit 1 ;;
        ?) printf "%s: illegal option -- %c\n" "${0##*/}" "$OPTARG" 1>&2; exit 1 ;;
    esac
done
shift $(($OPTIND - 1))

if [ ! -n "${operation+x}" ]; then
    printf "%s: no operation flags specified\n" "${0##*/}" 1>&2
    exit 1
fi

case "$operation" in
    brightness) code="0x10" ;;
    volume) code="0x62" ;;
    mute) code="0x8d" ;;
esac

case $# in
    0) operation="getvcp" ;;
    *) operation="setvcp" ;;
esac

case "${display-all}" in
    all)
        [ "setvcp" = "$operation" ] && set -x
        command -p ddcutil -d 1 "$operation" "$code" "$@"
        command -p ddcutil -d 2 "$operation" "$code" "$@"
        ;;
    *)
        [ "setvcp" = "$operation" ] && set -x
        command -p ddcutil -d "$display" "$operation" "$code" "$@"
        ;;
esac
