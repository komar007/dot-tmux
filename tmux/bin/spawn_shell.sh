#!/bin/sh

# This script is responsible for spawning custom shell based on the tmux session name.
# Its path is conventional and not configurable.
#
# Lack of this file results in spawning $SHELL independently of the tmux session name.
CUSTOM_SHELL=~/.shell.sh

SESSION="$1"

if [ -x "$CUSTOM_SHELL" ]; then
    exec "$CUSTOM_SHELL" "$SESSION"
else
    exec "$SHELL"
fi
