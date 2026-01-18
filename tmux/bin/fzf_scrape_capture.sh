#!/usr/bin/env bash

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
MODE="${MODE:-}"
PREVIEW_HEIGHT="${PREVIEW_HEIGHT:-80%}"

DEP_PREFIX="${DEP_PREFIX:-}"
FZF_TMUX_COMMON_STYLE="${FZF_TMUX_COMMON_STYLE:-}"

FZF=${DEP_PREFIX}fzf
XSEL=${DEP_PREFIX}xsel
BAT_HIGHLIGHT="${DEP_PREFIX}bat \
    --theme=gruvbox-dark \
    --color=always \
    --decorations=never \
    --style=plain \
    --paging=never \
"

FZF_MODE_OPTS=""
if [ "$MODE" = full ]; then
    FZF_MODE_OPTS="--tmux 100%,100%"
elif [ "$MODE" = pane ]; then
    FZF_MODE_OPTS=""
    FZF="$DIR/fzf_tmux_pane.sh"
elif [ "$MODE" != "" ]; then
    exit 1
fi

prompt_for() {
    echo "$1 > "
}

bind_change_tokenization() {
    what="$1"
    echo "change-prompt($(prompt_for "$what"))+reload: \
        cat \"$CAPTURE_BARE\" | \"$DIR\"/tokenize_capture.sh \"$what\""
}

tokenization_binds=()
n=1
for what in $("$DIR"/tokenize_capture.sh --list); do
    tokenization_binds=(
        "${tokenization_binds[@]}"
        "--bind"
        "f$n:$(bind_change_tokenization "$what")"
    )
    ((n++))
done

# shellcheck disable=SC2086
OUT=$(
    "$DIR"/tokenize_capture.sh "$WHAT" < "$CAPTURE_BARE" | $FZF \
        $FZF_MODE_OPTS \
        $FZF_TMUX_COMMON_STYLE \
        -m \
        --with-nth=2.. \
        --no-sort \
        --padding=0% \
        --margin=0% \
        --prompt "$(prompt_for "$WHAT")" \
        --preview " \
            grep -Fn -- {2..} $CAPTURE_BARE \
            | cut -d: -f1 \
            | sed 's/^/-H /' \
            | xargs $BAT_HIGHLIGHT $CAPTURE \
        " \
        --preview-window="up,${PREVIEW_HEIGHT},nowrap,border-none,+{1}+1/1" \
        --bind "ctrl-y:execute(tmux set-buffer {2..} && echo {2..} | $XSEL -i --primary)+abort" \
        "${tokenization_binds[@]}"
)
stat=$?
echo "$OUT" | cut -d' ' -f 2-
exit $stat
