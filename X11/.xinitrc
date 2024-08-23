#!/bin/sh

DWMLOG="${HOME}/.dwm/dwm.log"
userresources="${HOME}/.Xresources"

REPEAT_DELAY=250
REPEAT_RATE=60

export SSH_AUTH_SOCK

# https://unix.stackexchange.com/questions/368817/blank-android-studio-window-in-dwm
export _JAVA_AWT_WM_NONREPARENTING=1
export LSP_USE_PLISTS=true

xset dpms 0
xset r rate ${REPEAT_DELAY} ${REPEAT_RATE}
setxkbmap -option ctrl:nocaps

[ -f "$userresources" ] && xrdb -merge "$userresources"

if [ -d /etc/X11/xinit/xinitrc.d ] ; then
 for f in /etc/X11/xinit/xinitrc.d/?* ; do
  [ -x "$f" ] && . "$f"
 done
 unset f
fi

. "${HOME}/.xprofile"

exec dwm &>>"${DWMLOG}"

