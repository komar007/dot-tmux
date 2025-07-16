#!/bin/sh

set -e
DIR=$(cd "$(dirname "$0")" && pwd)

TMP_CAPTURE_BARE="$1"
TMP_CAPTURE="$2"

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
$FZF \
    $FZF_MODE_OPTS \
    $FZF_TMUX_COMMON_STYLE \
    --with-nth=2.. \
    --no-sort \
    --padding=0% \
    --margin=0% \
    --preview " \
        grep -Fn -- {2..} $TMP_CAPTURE_BARE \
        | cut -d: -f1 \
        | sed 's/^/-H /' \
        | xargs $BAT_HIGHLIGHT $TMP_CAPTURE \
    " \
    --preview-window="up,80%,nowrap,border-none,+{1}+1/1" \
    --bind "ctrl-y:execute(tmux set-buffer {2..} && echo {2..} | $XSEL -i --primary)+abort" \
| cut -d' ' -f 2-
