# -*- mode: sh -*-

# run for login shells after /etc/zshrc
if [[ ! $DISPLAY && $XDG_VTNR -eq 1 ]]; then
	export XDG_CURRENT_DESKTOP=dwm
	startx
fi
