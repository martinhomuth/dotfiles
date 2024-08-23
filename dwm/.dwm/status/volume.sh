#!/bin/bash

vol="$(amixer get Master | awk -F'[][]' '{print $2}' | sed '/^$/d' | head -n1)"
amixer get Master | grep Playback | grep -q off
off=$?

# Noto Color Emoji
declare -a icons=( '🔊' '🔉' '🔈' '🔇' )

val=${vol//%/}
if [ ${off} -eq 0 ]
then
	OUTPUT="${icons[3]}"
elif [ ${val} -lt 30 ]
then
	OUTPUT="${icons[2]} ${vol}"
elif [ ${val} -lt 60 ]
then
	OUTPUT="${icons[1]} ${vol}"
else
	OUTPUT="${icons[0]} ${vol}"
fi

echo ${OUTPUT}
