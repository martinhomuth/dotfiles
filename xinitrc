#!/bin/sh

DWMLOG="${HOME}/.dwm/dwm.log"
userresources="${HOME}/.Xresources"

REPEAT_DELAY=250
REPEAT_RATE=60

eval $(/usr/bin/gnome-keyring-daemon --start --components=pkcs,secrets,ssh)
export SSH_AUTH_SOCK

# https://unix.stackexchange.com/questions/368817/blank-android-studio-window-in-dwm
export _JAVA_AWT_WM_NONREPARENTING=1

xset dpms 0
xset r rate ${REPEAT_DELAY} ${REPEAT_RATE}
setxkbmap -option ctrl:nocaps

# Start various programs
[ -n "$(command -v sxhkd)" ] && sxhkd &
[ -n "$(command -v nextcloud)" ] && nextcloud &
[ -n "$(command -v nm-applet)" ] && nm-applet &

[ -f "$userresources" ] && xrdb -merge "$userresources"

if [ -d /etc/X11/xinit/xinitrc.d ] ; then
 for f in /etc/X11/xinit/xinitrc.d/?* ; do
  [ -x "$f" ] && . "$f"
 done
 unset f
fi

. ${HOME}/.xprofile

. ${HOME}/.screenlayout/desktop_2monitors_leftPortrait.sh

dwmblocks &>~/.dwm/dwmblocks.log &

dwm &>${DWMLOG}

