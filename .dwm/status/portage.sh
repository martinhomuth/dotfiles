#!/bin/bash

TMPFILE=/tmp/sb-portage.cache

# check if portage is already running
if pgrep 'emerge' >/dev/null; then
	exit 1
fi

nice -n19 emerge -pquDNa @world | grep -c '\[ebuild' 1> ${TMPFILE} 2>/dev/null &

read -r num_updates 2>/dev/null < ${TMPFILE}
if [ -n "$num_updates" ] && [ ! "$num_updates" = "0" ]; then
	echo "${num_updates} updates"
fi
