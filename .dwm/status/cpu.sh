#!/bin/bash

[ -n "$(command -v lscpu)" ] || exit 1

declare -a graph_symbol
graph_symbol=(" " "⡀" "⣀" "⣄" "⣤" "⣦" "⣴" "⣶" "⣷" "⣾" "⣿")

declare -A cpu
cpu[cores]="$(lscpu -p=CPU,MAXMHZ | grep -v '#.*')"

echo ${cpu[cores]}

readarray cpu_stat < /proc/stat

OUTPUT=""
for cpu in $(seq 0 $((num_cpu - 1))); do

	val=${graph_symbol[10]}
	OUTPUT="${OUTPUT}${val}"
done

echo "${OUTPUT}"



