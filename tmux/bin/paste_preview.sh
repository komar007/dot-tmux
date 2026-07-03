#!/usr/bin/env bash

TIMG=${DEP_PREFIX}timg
XCLIP=${DEP_PREFIX}xclip
A2T=${DEP_PREFIX}ansi2txt

T=$(mktemp)
cleanup() { rm "$T"; }
trap cleanup EXIT

case "$(${A2T} <<<"$1")" in
*)
	tmux show-buffer -b "$2" 2>/dev/null >"$T"
	;;
*)
	$XCLIP -o -selection "$2" >"$T"
	;;
*)
	exit 1
	;;
esac

case "$(file --mime-type -b "$T")" in
image/*)
	"$TIMG" -g "${FZF_PREVIEW_COLUMNS}x1000" -pq "$T"
	;;
*)
	cat "$T"
	;;
esac
