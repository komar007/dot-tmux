#!/bin/sh

HOW="$1"

case "$HOW" in
    urls) REGEX="https?:\/\/[^][ ^<>]+" ;;
    words) REGEX="[^][ 	]{4,}" ;;
    big-words) REGEX="[^ 	]{4,}" ;;
esac

grep --color=none -onP "$REGEX(?!.*)" | sed 's/:/ /' | tac | awk '!seen[$0]++'
