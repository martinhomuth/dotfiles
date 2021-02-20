#!/bin/bash

[ command -v sensors 1>/dev/null ] || exit 1
[ command -v jq 1>/dev/null ] || exit 1

unit="°C"

value=$(sensors -j | jq '."coretemp-isa-0000"."Package id 0"."temp1_input"')

echo "${value}${unit}"
