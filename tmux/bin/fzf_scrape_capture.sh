#!/bin/sh

# Take a terminal session capture, scrape tokens and let the user select some
# using fzf. Print the selected items.

set -e
DIR=$(cd "$(dirname "$0")" && pwd)

# session capture stripped from any "rich-text" control codes
CAPTURE_BARE="$1"
# full session capture with colors used for preview
CAPTURE="$2"
# tokenization method, see tokenize_capture.sh
WHAT="$3"

# method of running fzf:
# - "full": take full window (tmux mode)
# - "pane": fill currently active pane (tmux mode)
# - "" (default): plain tmux mode (no special tmux handling)
: "${MODE:-}"

: "${DEP_PREFIX:-}"
: "${FZF_TMUX_COMMON_STYLE:-}"

FZF=${DEP_PREFIX}fzf
XSEL=${DEP_PREFIX}xsel
BAT_HIGHLIGHT="${DEP_PREFIX}bat --theme gruvbox-dark --color=always --decorations never"

FZF_MODE_OPTS=""
if [ "$MODE" = full ]; then
    FZF_MODE_OPTS="--tmux 100%,100%"
elif [ "$MODE" = pane ]; then
    FZF_MODE_OPTS=""
    FZF="$DIR/fzf_tmux_pane.sh"
elif [ "$MODE" != "" ]; then
    exit 1
fi

# shellcheck disable=SC2086
"$DIR"/tokenize_capture.sh "$WHAT" < "$CAPTURE_BARE" | $FZF \
    $FZF_MODE_OPTS \
    $FZF_TMUX_COMMON_STYLE \
    -m \
    --with-nth=2.. \
    --no-sort \
    --padding=0% \
    --margin=0% \
    --preview " \
        grep -Fn -- {2..} $CAPTURE_BARE \
        | cut -d: -f1 \
        | sed 's/^/-H /' \
        | xargs $BAT_HIGHLIGHT $CAPTURE \
    " \
    --preview-window="up,80%,nowrap,border-none,+{1}+1/1" \
    --bind "ctrl-y:execute(tmux set-buffer {2..} && echo {2..} | $XSEL -i --primary)+abort" \
    --bind "f1:reload:cat $CAPTURE_BARE | $DIR/tokenize_capture.sh urls" \
    --bind "f2:reload:cat $CAPTURE_BARE | $DIR/tokenize_capture.sh words" \
    --bind "f3:reload:cat $CAPTURE_BARE | $DIR/tokenize_capture.sh big-words" \
| cut -d' ' -f 2-
