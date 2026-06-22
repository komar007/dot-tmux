#!/bin/sh

HOW="$1"

if [ "$HOW" = "--list" ]; then
    echo words ctrl-space
    echo hex
    echo sri ctrl-h
    echo quoted ctrl-q
    echo WORDS
    echo urls ctrl-u
    exit 0
fi

case "$HOW" in
    urls) REGEX="https?:\/\/[^][ ^<>]+" ;;
    words) REGEX="[^][() 	]{4,}" ;;
    WORDS) REGEX="[^ 	]{4,}" ;;
    sri) REGEX="sha(256|384|512)-[A-Za-z0-9+/=]{44,88}" ;;
    hex) REGEX="[A-Fa-f0-9+]{4,}" ;;
    quoted) REGEX='"[^"]+"'
esac

grep --color=none -onP "$REGEX(?!.*)" | sed 's/:/ /' | tac | awk '!seen[$0]++'
