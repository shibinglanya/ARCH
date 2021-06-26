#!/bin/bash

while [ "$(ps -a | grep Xephyr)" == "" ]
do
  sleep 2
done

Display0_Clipboard=$(DISPLAY=:0 xsel --output --clipboard)
Display1_Clipboard=$(DISPLAY=:1 xsel --output --clipboard)

while true
do
  sleep 1
  Var_Display0_Clipboard=$(DISPLAY=:0 xsel --output --clipboard)
  if [ "$Var_Display0_Clipboard" != "$Display0_Clipboard" ]; then
    Display0_Clipboard=$Var_Display0_Clipboard
    Display1_Clipboard=$Var_Display0_Clipboard
    echo "$Display0_Clipboard" | DISPLAY=:1 xsel --input --clipboard
    echo "1: $Display0_Clipboard"
    continue
  fi

  Var_Display1_Clipboard=$(DISPLAY=:1 xsel --output --clipboard)
  if [ "$Var_Display1_Clipboard" != "$Display1_Clipboard" ]; then
    Display0_Clipboard=$Var_Display1_Clipboard
    Display1_Clipboard=$Var_Display1_Clipboard
    echo "$Display1_Clipboard" | DISPLAY=:0 xsel --input --clipboard
    echo "2: $Display0_Clipboard"
    continue
  fi
done
