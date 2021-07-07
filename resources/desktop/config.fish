# Start X at login
if status --is-login
    and test -z "$DISPLAY"
    and test -n "$XDG_VTNR"
    and test $XDG_VTNR -eq 1
	exec startx -- -keeptty
end

