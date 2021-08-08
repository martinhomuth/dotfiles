#!/bin/bash

TMPFILE=/tmp/sb-portage.cache

nice -n19 emerge -pquDNa @world | wc -l &> ${TMPFILE} &

read -r num_updates 2>/dev/null < ${TMPFILE}
if [ -n "$num_updates" ] && [ ! "$num_updates" = "0" ]; then
	echo "${num_updates} updates"
fi
