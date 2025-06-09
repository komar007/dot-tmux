#!/bin/sh

# This script is responsible for choosing the right directory to set for a tmux session
# Its path is conventional and not configurable.
#
# Lack of this file results in choosing $HOME independently of the tmux session name.
SESSION_DIR=~/.session_dir.sh

SESSION="$1"

if [ -x "$SESSION_DIR" ]; then
    D=$("$SESSION_DIR" "$SESSION")
fi
echo "${D:-$HOME}"
