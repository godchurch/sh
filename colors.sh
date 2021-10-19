#!/bin/sh

# Attribute codes:
# 00=none 01=bold 04=underscore 05=blink 07=reverse 08=concealed
# Text color codes:
# 30=black 31=red 32=green 33=yellow 34=blue 35=magenta 36=cyan 37=white
# Background color codes:
# 40=black 41=red 42=green 43=yellow 44=blue 45=magenta 46=cyan 47=white

for attribute in 00 01 04 05 07 08; do
	unset major minor
	case "$attribute" in
		00) major='NONE      ' ;;
		01) major='BOLD      ' ;;
		04) major='UNDERSCORE' ;;
		05) major='BLINK     ' ;;
		07) major='REVERSE   ' ;;
		08) major='CONCEALED ' ;;
	esac
	for color in 30 31 32 33 34 35 36 37; do
		case "$color" in
			30) colorString="BLACK" ;;
			31) colorString="RED" ;;
			32) colorString="GREEN" ;;
			33) colorString="YELLOW" ;;
			34) colorString="BLUE" ;;
			35) colorString="MAGENTA" ;;
			36) colorString="CYAN" ;;
			37) colorString="WHITE" ;;
		esac
		minor="${minor}\033[${attribute};${color}m${colorString} "
	done
	printf "    ${major} | ${minor}\033[0m\n"
done
