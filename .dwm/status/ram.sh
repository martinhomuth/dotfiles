#!/bin/bash

icon=""
command="$(free -h | awk '/^Mem/ { print $3"/"$2 }' | sed s/i//g)"

printf "%s %s " ${icon} ${command}
