#!/bin/sh

# Attribute codes:
# 00=none 01=bold 04=underscore 05=blink 07=reverse 08=concealed
# Text color codes:
# 30=black 31=red 32=green 33=yellow 34=blue 35=magenta 36=cyan 37=white
# Background color codes:
# 40=black 41=red 42=green 43=yellow 44=blue 45=magenta 46=cyan 47=white

for attribute in 00 01 04 05 07 08; do

    case "$attribute" in
        00) printf '> none       | ' ;;
        01) printf '> bold       | ' ;;
        04) printf '> underscore | ' ;;
        05) printf '> blink      | ' ;;
        07) printf '> reverse    | ' ;;
        08) printf '> concealed  | ' ;;
    esac

    for color in 30 31 32 33 34 35 36 37; do
        case "$color" in
            30) printf "\033[${attribute};${color}m%s\033[0m " 'BLACK' ;;
            31) printf "\033[${attribute};${color}m%s\033[0m " 'RED' ;;
            32) printf "\033[${attribute};${color}m%s\033[0m " 'GREEN' ;;
            33) printf "\033[${attribute};${color}m%s\033[0m " 'YELLOW' ;;
            34) printf "\033[${attribute};${color}m%s\033[0m " 'BLUE' ;;
            35) printf "\033[${attribute};${color}m%s\033[0m " 'MAGENTA' ;;
            36) printf "\033[${attribute};${color}m%s\033[0m " 'CYAN' ;;
            37) printf "\033[${attribute};${color}m%s\033[0m " 'WHITE' ;;
        esac
    done

    printf '\n'

done
