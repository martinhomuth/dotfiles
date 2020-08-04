#!/bin/bash

NMCLI=$(command -v nmcli)

[ -n "${NMCLI}" ] || exit

VPN_ID="$(${NMCLI} -f uuid,type c | grep vpn | awk -F' ' '{ print $1 }')"

# check if it is active
${NMCLI} c show --active | grep ${VPN_ID} &>/dev/null
[ $? -eq 0 ] && echo "VPN Active"
