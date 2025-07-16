#!/bin/sh

FZF=${DEP_PREFIX}fzf

GEOMETRY="$(\
    tmux display-message -p -- "\
        -x #{pane_left} \
        -w #{pane_width} \
        -y #{e|+:#{pane_bottom},2} \
        -h #{pane_height} \
    " \
)"

rm -fr /tmp/fzf.in
mkfifo /tmp/fzf.in

printf '%s\0' "$@" | head -c -1 > /tmp/fzf.args0
tmux display-popup -E -B $GEOMETRY \
    "xargs -0 -a /tmp/fzf.args0 $FZF < /tmp/fzf.in > /tmp/fzf.out ; echo \$? > /tmp/fzf.status" &

cat > /tmp/fzf.in

wait

cat /tmp/fzf.out
exit "$(cat /tmp/fzf.status)"
