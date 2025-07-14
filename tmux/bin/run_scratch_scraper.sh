#!/bin/sh

set -e
DIR=$(cd "$(dirname "$0")" && pwd)

: "${BGCOLOR:-#ff00ff}"

W=$(tmux display-message -p "#{pane_width}")
H=$(tmux display-message -p "#{pane_height}")
tmux display-popup \
    -s "bg=$BGCOLOR" \
    -B -E \
    -x "#{pane_left}" -w "$W" -y "#{e|+:#{pane_bottom},2}" -h "$H" \
    " \
        DEP_PREFIX=\"$DEP_PREFIX\" \
        FZF_TMUX_COMMON_STYLE=\"$FZF_TMUX_COMMON_STYLE --color=preview-bg:$BGCOLOR\" \
        ${DIR}/scratch_scraper.sh \
            | tmux send-keys -l -- \"\$(tr '\n' ' ')\" || true \
    "
