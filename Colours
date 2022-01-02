#!/bin/sh

# Attribute codes:
# 00=none 01=bold 04=underscore 05=blink 07=reverse 08=concealed
# Text color codes:
# 30=black 31=red 32=green 33=yellow 34=blue 35=magenta 36=cyan 37=white
# Background color codes:
# 40=black 41=red 42=green 43=yellow 44=blue 45=magenta 46=cyan 47=white

shift $#

str=
for attr in 00 01 04 05 07 08
do
	case "$attr" in
	(00) set -- "$@" 'NONE'; unset attr ;;
	(01) set -- "$@" 'BOLD' ;;
	(04) set -- "$@" 'UNDERSCORE' ;;
	(05) set -- "$@" 'BLINK' ;;
	(07) set -- "$@" 'REVERSE' ;;
	(08) set -- "$@" 'CONCEALED' ;;
	esac

	str="${str}%12s |"

	for col in 30 31 32 33 34 35 36 37
	do
		case "$col" in
		(30) set -- "$@" "BLACK" ;;
		(31) set -- "$@" "RED" ;;
		(32) set -- "$@" "GREEN" ;;
		(33) set -- "$@" "YELLOW" ;;
		(34) set -- "$@" "BLUE" ;;
		(35) set -- "$@" "MAGENTA" ;;
		(36) set -- "$@" "CYAN" ;;
		(37) set -- "$@" "WHITE" ;;
		esac

		str="${str} \033[${col}${attr+;${attr}}m%s\033[0m"
	done
	str="${str}\n"
done

printf "$str" "$@"
