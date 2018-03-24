#!/bin/bash

# ackquire all conected monitors
declare -a monitors
count=0
for mon in $(xrandr | grep ' connected' | cut -d ' ' -f 1); do
	monitors[${count}]=${mon}
	count=$((count + 1))
done

xrandr --output DisplayPort-1 --mode 1920x1200 --pos 0x0 --rotate normal --output DisplayPort-0 --off --output DVI-D-0 --mode 1920x1080 --pos 1920x0 --rotate normal --output HDMI-A-1 --off --output HDMI-A-0 --off


