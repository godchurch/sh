#!/usr/bin/sh

PATH="/usr/bin"

while getopts ":EF" option; do
    case "$option" in
        E) alias grep="grep -E" ;;
        F) alias grep="grep -F" ;;
        :) printf "%s: option requires an argument -- %c\n" "${0##*/}" "$OPTARG" >&2; exit 1 ;;
        ?) printf "%s: illegal option -- %c\n" "${0##*/}" "$OPTARG" >&2; exit 1 ;;
    esac
done
shift $(($OPTIND - 1))

file="/usr/share/dict/american-english"

if [ $# -ne 1 ]; then
    printf "Usage: %s [-E|-F] pattern_list" "${0##*/}" >&2
    exit 2
elif [ ! -e "$file" ]; then
    printf "%s: '%s' doesn't exist" "${0##*/}" "$file" >&2
    exit 1
elif [ ! -f "$file" ]; then
    printf "%s: '%s' is not a file" "${0##*/}" "$file" >&2
    exit 1
elif [ ! -r "$file" ]; then
    printf "%s: unable to read '%s'" "${0##*/}" "$file" >&2
    exit 1
fi

matched="$(grep "$1" "$file")" || exit $?

set -- $matched

if [ $# -ge 10 ]
then printf "%s\n" "$@" | column -c 80
else printf "%s\n" "$@"
fi
