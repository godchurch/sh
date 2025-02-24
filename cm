#!/bin/sh

error () { printf "%s: %s\n" "${0##*/}" "$*" >&2; exit 1; }

command -v ddcutil > /dev/null || error "command 'ddcutil' not found"

display="all" operation="brightness" operation_count=0
while getopts :hd:bvm option; do
    case "$option" in
        h) printf "Usage: %s [-d display] [-b|-v|-m] [arguments]\n" "${0##*/}" >&2; exit 0 ;;
        d) display="$OPTARG" ;;
        b) operation="brightness" operation_count="$(($operation_count + 1))" ;;
        v) operation="volume" operation_count="$(($operation_count + 1))" ;;
        m) operation="mute" operation_count="$(($operation_count + 1))" ;;
        :) error "option requires an argument -- ${OPTARG:-NULL}" ;;
        ?) error "invalid option -- ${OPTARG:-NULL}" ;;
    esac
done
shift $(($OPTIND - 1))

[ "$operation_count" -gt 1 ] && error "too many flags specified"
[ "$operation_count" -eq 0 ] && printf "No operation flags specified, defaulting to brightness.\n"

case "$operation" in
    brightness) code="0x10" ;;
    volume) code="0x62" ;;
    mute) code="0x8d" ;;
esac

case $# in
    0) operation="getvcp" ;;
    *) operation="setvcp" ;;
esac

case "$display" in
    [1-9])
        set -x
        ddcutil --display "$display" "$operation" "$code" "$@"
        ;;
    all)
        set -x
        ddcutil --display 1 "$operation" "$code" "$@"
        ddcutil --display 2 "$operation" "$code" "$@"
        ;;
    *)
        error "invalid display -- ${display:-NULL}"
        ;;
esac
