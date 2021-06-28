#!/bin/sh

function get_cpubars() {
  echo "$1" | while read -r row; do
    id=${row%% *}
    rest=${row#* }
    total=${rest%% *}
    idle=${rest##* }
    case "$(echo "$2" | awk '{if ($1 == id)
      printf "%d\n", (1 - (idle - $3)  / (total - $2))*100 /12.5}' \
      id="$id" total="$total" idle="$idle")" in

      "0") printf "#[fg=colour46,bg=colour36]▁";;
      "1") printf "#[fg=colour46,bg=colour36]▂";;
      "2") printf "#[fg=colour46,bg=colour36]▃";;
      "3") printf "#[fg=colour46,bg=colour36]▄";;
      "4") printf "#[fg=colour46,bg=colour36]▅";;
      "5") printf "#[fg=colour196,bg=colour36]▆";;
      "6") printf "#[fg=colour196,bg=colour36]▇";;
      "7") printf "#[fg=colour196,bg=colour36]█";;
      "8") printf "#[fg=colour196,bg=colour36]█";;
    esac
    printf "#[fg=default,bg=default]"
  done;
}

while true; do
  stats=$(awk '/cpu[0-9]+/ {printf "%d %d %d\n", substr($1,4), ($2 + $3 + $4 + $5), $5 }' /proc/stat)
  echo $(get_cpubars "$stats" "$old") > /tmp/tmux_cpubars
  old=$stats
  sleep 1
done;

