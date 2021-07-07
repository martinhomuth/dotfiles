#!/bin/bash

NMCLI=$(command -v nmcli)

VPN_ACTIVE="🔒 VPN 🔒"

[ -n "${NMCLI}" ] || exit

VPN_IDS="$(${NMCLI} -f uuid,type c | grep vpn | awk -F' ' '{ print $1 }' | tr '\n' ' ')"

# check if one of it is active
for vpn in ${VPN_IDS}; do
	${NMCLI} c show --active | grep "${vpn}" &>/dev/null && echo "${VPN_ACTIVE}"
done
