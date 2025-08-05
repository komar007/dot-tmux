#!/usr/bin/env bash

set -e
DIR=$(cd "$(dirname "$0")" && pwd)

: "${BGCOLOR:-#ff00ff}"

GEOMETRY=$(tmux display-message -p -- " \
    #{pane_current_path} \
    #{window_height} \
    #{e|+:#{pane_left},2} \
    #{e|-:#{pane_width},4} \
    #{?#{e|>:#{e|+:#{pane_top},#{cursor_y}},#{e|/:#{window_height},2}}, \
        #{e|-:#{e|+:#{pane_top},#{cursor_y}},1} \
        #{e|-:#{e|+:#{pane_top},#{cursor_y}},4} \
        top \
        , \
        #{window_height} \
        #{e|-:#{e|-:#{window_height},#{e|+:#{pane_top},#{cursor_y}}},4} \
        bottom \
    } \
")
read -r C H x w y h pos <<< "$GEOMETRY"

# if scratch shell pane above cursor, make the first prompt close to the cursor by prepending
# session with a wall of newlines
PADDING=""
if [ "$pos" = top ]; then
    PADDING=$(yes '\n' | head -n "$H")
fi;

# shellcheck disable=SC2086
tmux display-popup \
    -E \
    -s "bg=$BGCOLOR" \
    -x "$x" -w "$w" -y "$y" -h "$h" \
    " \
        tmux send-keys -l ▕; \
        RES=\$( \
            cd \"$C\";
            DEP_PREFIX=\"$DEP_PREFIX\" \
            FZF_TMUX_COMMON_STYLE=\"$FZF_TMUX_COMMON_STYLE --color=preview-bg:$BGCOLOR\" \
            PADDING=\"$PADDING\" \
            ${DIR}/scratch_scraper.sh \
        ); \
        ok=\$?
        tmux send-keys C-h; \
        if [ \$ok -eq 0 ]; then
            tmux send-keys -l -- \"\$(tr '\n' ' ' <<< \"\$RES\")\" || true; \
        fi \
    "
