#!/bin/sh

HOW="$1"

if [ "$HOW" = "--list" ]; then
    echo urls ctrl-u
    echo words ctrl-space
    echo WORDS
    echo sri ctrl-h
    exit 0
fi

case "$HOW" in
    urls) REGEX="https?:\/\/[^][ ^<>]+" ;;
    words) REGEX="[^][() 	]{4,}" ;;
    WORDS) REGEX="[^ 	]{4,}" ;;
    sri) REGEX="sha(256|384|512)-[A-Za-z0-9+/=]{44,88}" ;;
esac

grep --color=none -onP "$REGEX(?!.*)" | sed 's/:/ /' | tac | awk '!seen[$0]++'
