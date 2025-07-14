#!/bin/sh

WHAT="$1"
TMP_CAPTURE_BARE="$2"
TMP_CAPTURE="$3"

if [ "$WHAT" = scrollback ]; then
    OPTS="-S- -E-"
elif [ "$WHAT" = pane ]; then
    OPTS=""
else
    exit 1
fi

# shellcheck disable=SC2086
tmux capture-pane -eJp $OPTS > "$TMP_CAPTURE"
# shellcheck disable=SC2086
tmux capture-pane -Jp $OPTS | tee "$TMP_CAPTURE_BARE"
