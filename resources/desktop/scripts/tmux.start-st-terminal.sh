#!/bin/sh

if tmux ls | grep "st-terminal" 1>/dev/null 2>&1; then
  st -t "scratchpad" -g 120x34 -e tmux a -t "st-terminal"
else
  st -t "scratchpad" -g 120x34 -e tmux new -s "st-terminal"
fi
