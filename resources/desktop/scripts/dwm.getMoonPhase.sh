#!/bin/sh

# Shows the current moon phase.

case $BUTTON in
	4) st -e vi "$0" ;;
esac

moonfile="${XDG_DATA_HOME:-$HOME/.local/share}/moonphase"

[ "$(stat -c %y "$moonfile" 2>/dev/null | cut -d' ' -f1)" = "$(date '+%Y-%m-%d')" ] ||
	{ curl -sf "wttr.in/?format=%m" > "$moonfile" || exit 1 ;}

[ "$(stat -c %s "$moonfile" 2>/dev/null)" != 0 ] ||
	{ curl -sf "wttr.in/?format=%m" > "$moonfile" || exit 1 ;}

icon="$(cat "$moonfile")"

case "$icon" in
	🌑) name="New" ;;
	🌒) name="Waxing Crescent" ;;
	🌓) name="First Quarter" ;;
	🌔) name="Waxing Gibbous" ;;
	🌕) name="Full" ;;
	🌖) name="Waning Gibbous" ;;
	🌗) name="Last Quarter" ;;
	🌘) name="Waning Crescent" ;;
	*) exit 1 ;;
esac

echo "${icon-?}"

