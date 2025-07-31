#!/bin/sh

set -e
DIR=$(cd "$(dirname "$0")" && pwd)

: "${BGCOLOR:-#ff00ff}"

GEOMETRY=$(tmux display-message -p -- " \
    -x #{e|+:#{pane_left},2} \
    -w #{e|-:#{pane_width},4} \
    -y #{e|-:#{e|-:#{e|+:#{pane_bottom},#{cursor_y}},#{pane_height}},1} \
    -h #{e|-:#{cursor_y},4} \
")

# shellcheck disable=SC2086
tmux display-popup \
    -E \
    -s "bg=$BGCOLOR" \
    $GEOMETRY \
    " \
        tmux send-keys -l ▕; \
        RES=\$( \
            DEP_PREFIX=\"$DEP_PREFIX\" \
            FZF_TMUX_COMMON_STYLE=\"$FZF_TMUX_COMMON_STYLE --color=preview-bg:$BGCOLOR\" \
            ${DIR}/scratch_scraper.sh \
        ); \
        ok=\$?
        tmux send-keys C-h; \
        if [ \$ok -eq 0 ]; then
            tmux send-keys -l -- \"\$(tr '\n' ' ' <<< \"\$RES\")\" || true; \
        fi \
    "
