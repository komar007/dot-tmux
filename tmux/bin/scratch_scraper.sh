#!/bin/sh

# Run a "temporary" shell with the session recorded using script.
#
# When the shell exits, run fzf_scrape_capture.sh to let the user select
# tokenized items from the screen capture and print the selected items.

set -e
DIR=$(cd "$(dirname "$0")" && pwd)

RAW=$(mktemp)
CAPTURE=$(mktemp)
CAPTURE_BARE=$(mktemp)
PROMPT_NO_TITLE=1 script -B "$RAW" -q -c "$SHELL" </dev/tty >/dev/tty 2>/dev/tty || true
sed '1d' "$RAW" | head -n -2 > "$CAPTURE"
"${DEP_PREFIX}ansi2txt" < "$CAPTURE" > "$CAPTURE_BARE"
if [ "$(wc -l < "$CAPTURE_BARE")" -le 3 ]; then
    exit
fi
# shellcheck disable=SC2094
"$DIR"/fzf_scrape_capture.sh "$CAPTURE_BARE" "$CAPTURE" words
