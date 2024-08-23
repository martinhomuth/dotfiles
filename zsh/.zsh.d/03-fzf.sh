
fzf_available() {
	command -v fzf &>/dev/null || return 1
}

# lists all installable packages
li() {
	fzf_available || echo "fzf not installed"

	command -v eix >/dev/null || echo "eix not available"

	local os_name=$(grep "^NAME=" /etc/os-release | awk -F'=' '{ print $2 }')

	if [ "z${os_name}" = "zGentoo" ]; then
		EIX_LIMIT_COMPACT=0 eix -c | fzf
	fi
}
