#!/bin/sh

HOW="$1"

case "$HOW" in
    urls) REGEX="https?:\/\/[^][ ^<>]+" ;;
    words) REGEX="[^][ 	]+" ;;
    big-words) REGEX="[^ 	]+" ;;
esac

grep --color=none -onE "$REGEX" | sed 's/:/ /' | tac | awk '!seen[$0]++'
