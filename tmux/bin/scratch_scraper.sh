#!/bin/sh

# Run a "temporary" shell with the session recorded using script.
#
# When the shell exits, run fzf_scrape_capture.sh to let the user select
# tokenized items from the screen capture and print the selected items.
#
# The shell is run with SHELL_SESSION_RECORDED_BY env set to one of the following:
# - "script" - shell is being recorder by the "script" tool,
# - "" (empty string or no value set) - shell is not being recorded.
#
# This variable is provided for the shell configuration to be able to adjust
# the terminal features used to prevent problems with correct recording by
# the tool.
#
# Known quirks that must be handled by the shell are:
# - setting title is not correctly handled by script.

set -e
DIR=$(cd "$(dirname "$0")" && pwd)

RAW=$(mktemp)
CAPTURE=$(mktemp)
CAPTURE_BARE=$(mktemp)
SHELL_SESSION_RECORDED_BY=script script -B "$RAW" -q -c "$SHELL" </dev/tty >/dev/tty 2>/dev/tty || true
sed '1d' "$RAW" | head -n -2 > "$CAPTURE"
"${DEP_PREFIX}ansi2txt" < "$CAPTURE" > "$CAPTURE_BARE"
if [ "$(wc -l < "$CAPTURE_BARE")" -le 3 ]; then
    exit 1
fi
# shellcheck disable=SC2094
"$DIR"/fzf_scrape_capture.sh "$CAPTURE_BARE" "$CAPTURE" words
