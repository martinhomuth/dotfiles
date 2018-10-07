#!/bin/zsh

# remove the caps key and replace it with a second control key
if [[ -x /usr/bin/setxkbmap ]]; then
    setxkbmap -option ctrl:nocaps
fi
