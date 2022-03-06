#!/bin/bash

set -x

TMPFILE=/tmp/sb-portage.cache
LOGFILE=/tmp/sb-portage.log

# check if portage is already running
if pgrep 'emerge' >/dev/null; then
	exit 1
fi

nice -n19 emerge -pquDNa --backtrack=100 --with-bdeps=y @world | tee ${LOGFILE} | grep -c '\[ebuild' 1> ${TMPFILE} 2>/dev/null &

read -r num_updates 2>/dev/null < ${TMPFILE}
if [ -n "$num_updates" ] && [ ! "$num_updates" = "0" ]; then
	echo "${num_updates} updates"
fi
