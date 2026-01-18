#!/bin/sh

HOW="$1"

if [ "$HOW" = "--list" ]; then
    echo urls
    echo words
    echo big-words
    exit 0
fi

case "$HOW" in
    urls) REGEX="https?:\/\/[^][ ^<>]+" ;;
    words) REGEX="[^][ 	]{4,}" ;;
    big-words) REGEX="[^ 	]{4,}" ;;
esac

grep --color=none -onP "$REGEX(?!.*)" | sed 's/:/ /' | tac | awk '!seen[$0]++'
