#!/bin/sh

if tmux ls | grep "terminal" 1>/dev/null 2>&1; then
  alacritty -e tmux a -t "terminal"
else
  alacritty -e tmux new -s "terminal"
fi
