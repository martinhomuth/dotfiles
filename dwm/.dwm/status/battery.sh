#!/bin/bash

[ -n "${DEBUG}" ] && set -x

# there are 5 states
#  1. discharging > 75%
#  2. discharging > 50%
#  3. discharging > 25%
#  4. discharging > 10%
#  5. discharging <= 10%

charge_icon=''
declare -a discharge_icons=('' '' '' '' '')

CAP=$(cat /sys/class/power_supply/BAT0/capacity)
STATE=$(cat /sys/class/power_supply/BAT0/status)

OUTPUT="${CAP}%"
if [[ ${STATE} = "Discharging" ]]; then
	[[ ${CAP} -lt 100 ]] && ICON="${discharge_icons[0]} "
	[[ ${CAP} -lt 75 ]] && ICON="${discharge_icons[1]} "
	[[ ${CAP} -lt 50 ]] && ICON="${discharge_icons[2]} "
	[[ ${CAP} -lt 25 ]] && ICON="${discharge_icons[3]} "
	[[ ${CAP} -lt 10 ]] && ICON="${discharge_icons[4]} "
else
	ICON="${charge_icon} "
fi

echo -e " ${ICON}${OUTPUT}"
