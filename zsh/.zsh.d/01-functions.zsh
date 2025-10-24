# Zsh functions

not_in_emacs() {
  [[ ! -n $EMACS ]]
}

# this function checks if a command exists and returns either true
# or false. This avoids using 'which' and 'whence', which will
# avoid problems with aliases for which on certain weird systems. :-)
# Usage: check_com [-c|-g] word
#   -c  only checks for external commands
#   -g  does the usual tests and also checks for global aliases
check_com() {
    emulate -L zsh
    local -i comonly gatoo

    if [[ $1 == '-c' ]] ; then
        (( comonly = 1 ))
        shift
    elif [[ $1 == '-g' ]] ; then
        (( gatoo = 1 ))
    else
        (( comonly = 0 ))
        (( gatoo = 0 ))
    fi

    if (( ${#argv} != 1 )) ; then
        printf 'usage: check_com [-c] <command>\n' >&2
        return 1
    fi

    if (( comonly > 0 )) ; then
        [[ -n ${commands[$1]}  ]] && return 0
        return 1
    fi

    if   [[ -n ${commands[$1]}    ]] \
      || [[ -n ${functions[$1]}   ]] \
      || [[ -n ${aliases[$1]}     ]] \
      || [[ -n ${reswords[(r)$1]} ]] ; then

        return 0
    fi

    if (( gatoo > 0 )) && [[ -n ${galiases[$1]} ]] ; then
        return 0
    fi

    return 1
}

# Usage: simple-extract <file>
# Using option -d deletes the original archive file.
#f5# Smart archive extractor
extract() {
    emulate -L zsh
    setopt extended_glob noclobber
    local DELETE_ORIGINAL DECOMP_CMD USES_STDIN USES_STDOUT GZTARGET WGET_CMD
    local RC=0
    zparseopts -D -E "d=DELETE_ORIGINAL"
    for ARCHIVE in "${@}"; do
        case $ARCHIVE in
            *.(tar.bz2|tbz2|tbz))
                DECOMP_CMD="tar -xvjf -"
                USES_STDIN=true
                USES_STDOUT=false
                ;;
            *.(tar.gz|tgz))
                DECOMP_CMD="tar -xvzf -"
                USES_STDIN=true
                USES_STDOUT=false
                ;;
            *.(tar.xz|txz|tar.lzma))
                DECOMP_CMD="tar -xvJf -"
                USES_STDIN=true
                USES_STDOUT=false
                ;;
            *.tar)
                DECOMP_CMD="tar -xvf -"
                USES_STDIN=true
                USES_STDOUT=false
                ;;
            *.rar)
                DECOMP_CMD="unrar x"
                USES_STDIN=false
                USES_STDOUT=false
                ;;
            *.lzh)
                DECOMP_CMD="lha x"
                USES_STDIN=false
                USES_STDOUT=false
                ;;
            *.7z)
                DECOMP_CMD="7z x"
                USES_STDIN=false
                USES_STDOUT=false
                ;;
            *.(zip|jar))
                DECOMP_CMD="unzip"
                USES_STDIN=false
                USES_STDOUT=false
                ;;
            *.deb)
                DECOMP_CMD="ar -x"
                USES_STDIN=false
                USES_STDOUT=false
                ;;
            *.bz2)
                DECOMP_CMD="bzip2 -d -c -"
                USES_STDIN=true
                USES_STDOUT=true
                ;;
            *.(gz|Z))
                DECOMP_CMD="gzip -d -c -"
                USES_STDIN=true
                USES_STDOUT=true
                ;;
            *.(xz|lzma))
                DECOMP_CMD="xz -d -c -"
                USES_STDIN=true
                USES_STDOUT=true
                ;;
            *)
                print "ERROR: '$ARCHIVE' has unrecognized archive type." >&2
                RC=$((RC+1))
                continue
                ;;
        esac

        if ! check_com ${DECOMP_CMD[(w)1]}; then
            echo "ERROR: ${DECOMP_CMD[(w)1]} not installed." >&2
            RC=$((RC+2))
            continue
        fi

        GZTARGET="${ARCHIVE:t:r}"
        if [[ -f $ARCHIVE ]] ; then

            print "Extracting '$ARCHIVE' ..."
            if $USES_STDIN; then
                if $USES_STDOUT; then
                    ${=DECOMP_CMD} < "$ARCHIVE" > $GZTARGET
                else
                    ${=DECOMP_CMD} < "$ARCHIVE"
                fi
            else
                if $USES_STDOUT; then
                    ${=DECOMP_CMD} "$ARCHIVE" > $GZTARGET
                else
                    ${=DECOMP_CMD} "$ARCHIVE"
                fi
            fi
            [[ $? -eq 0 && -n "$DELETE_ORIGINAL" ]] && rm -f "$ARCHIVE"

        elif [[ "$ARCHIVE" == (#s)(https|http|ftp)://* ]] ; then
            if check_com curl; then
                WGET_CMD="curl -L -k -s -o -"
            elif check_com wget; then
                WGET_CMD="wget -q -O - --no-check-certificate"
            else
                print "ERROR: neither wget nor curl is installed" >&2
                RC=$((RC+4))
                continue
            fi
            print "Downloading and Extracting '$ARCHIVE' ..."
            if $USES_STDIN; then
                if $USES_STDOUT; then
                    ${=WGET_CMD} "$ARCHIVE" | ${=DECOMP_CMD} > $GZTARGET
                    RC=$((RC+$?))
                else
                    ${=WGET_CMD} "$ARCHIVE" | ${=DECOMP_CMD}
                    RC=$((RC+$?))
                fi
            else
                if $USES_STDOUT; then
                    ${=DECOMP_CMD} =(${=WGET_CMD} "$ARCHIVE") > $GZTARGET
                else
                    ${=DECOMP_CMD} =(${=WGET_CMD} "$ARCHIVE")
                fi
            fi

        else
            print "ERROR: '$ARCHIVE' is neither a valid file nor a supported URI." >&2
            RC=$((RC+8))
        fi
    done
    return $RC
}

__archive_or_uri() {
    _alternative \
        'files:Archives:_files -g "*.(#l)(tar.bz2|tbz2|tbz|tar.gz|tgz|tar.xz|txz|tar.lzma|tar|rar|lzh|7z|zip|jar|deb|bz2|gz|Z|xz|lzma)"' \
        '_urls:Remote Archives:_urls'
}

_extract() {
    _arguments \
        '-d[delete original archivefile after extraction]' \
        '*:Archive Or Uri:__archive_or_uri'
}

# Check if a URL is up
chk-url() {
    curl -sL -w "%{http_code} %{url_effective}\\n" "$1" -o /dev/null
}

in_gentoo() {
	[[ -x /usr/bin/emerge ]]
}

in_arch() {
	[[ -x /usr/bin/pacman ]]
}

# search for a package in the current distribution's package manager
s() {
	if [ ! $# -eq 1 ]; then
		echo "Usage: s <search string>"
		return
	fi
	if in_gentoo; then
		eix "$1"
	elif in_arch; then
		pacman -Ss "$1"
	else
		echo "Unknown distribution"
	fi
}

# installs a package in the current distribution's package manager
i() {
	if [ ! $# -ge 1 ]; then
		echo "Usage: i <package>"
		return
	fi
	if in_gentoo; then
		sudo emerge -av "$@"
	elif in_arch; then
		yay "$@"
	else
		echo "Unknown distribution"
	fi
}

sgrep() {
    find . \
	 -name .repo -prune \
	 -o \
	 -name .git -prune \
	 -o  -type f -iregex '.*\.\(c\|h\|cc\|cpp\|S\|java\|xml\|sh\|mk\|aidl\|bb\|bbappend\|el)' \
	 -print0 \
	| xargs -0 grep --color -n "$@"
}

bgrep() {
	find . -name .repo -prune -o -name .git -prune -o  -type f -iregex 'build-script' -print0 | xargs -0 grep --color -n "$@"
}

# emacs calling function replacing the simple alias
e() {
	if [[ -n "$(command -v emacs)"  ]]; then
		emacsclient -t "$@"
	else
		error "Emacs is not available"
	fi
}

# WIP
# function that is intended to be used for toggling the debug output of the shell
# during a function execution
toggledebug() {
	RUN=/tmp/zsh-toggledebug

	declare -i was_set=0
	declare -i need_toggle=0

	echo $- | grep x &>/dev/null && was_set=1
	if [ ${was_set} -eq 0 ]; then
		if [ -f ${RUN} ]; then
			echo "ERROR: run file ${RUN} should not exist"
		else
			set -x
			touch ${RUN}
		fi
	else
		if [ -f ${RUN} ]; then
			rm ${RUN}
			set +x
		fi
	fi
}

# ssh function to connect to emlix workstation
emlix() {
	local vpn=0
	declare -i ret=0

	if [ -z ${workstation} ] || [ -z ${workgate} ] || [ -z ${workssh} ]; then
		error "Need to define variables, see 02-secrets.zsh"
	fi

	grep "tun[0-9]" /proc/net/dev &>/dev/null && vpn=1

	if [[ ${vpn} = 1 ]]; then
		ping -c 1 ${workstation} &>/dev/null && ret=1 && ssh -i ~/.ssh/${work_ssh_key} mhomuth@${workstation}
	else
		ping -c 1 ${workgate} &>/dev/null && ret=1 && ssh -i ~/.ssh/${work_ssh_key} mhomuth@${workssh}
	fi

	[ ${ret} -eq 0 ] && error "failed"
}

# ensure to not shutdown SSHed machines by accident
shutdown() {
	SHUTDOWN="sudo shutdown -fh now"
	if [ ! "x${SSH_CLIENT}" = "x" -o ! "x${SSH_CONNECTION}" = "x" ]; then
		echo -n "Are you sure you want to shutdown SSH'ed machine $(hostname)? (y/N) "
		read resp
		case $resp in
			[Yy]* ) eval ${SHUTDOWN};;
			* ) echo "aborting...";;
                esac
	else
		eval ${SHUTDOWN}
	fi
}

# ensure to not rebooting SSHed machines by accident
reboot() {
	REBOOT="sudo reboot"
	if [ ! "x${SSH_CLIENT}" = "x" -o ! "x${SSH_CONNECTION}" = "x" ]; then
		echo -n "Are you sure you want to reboot remote machine $(hostname)? (y/N) "
		read ret
		case $ret in
			[Yy]* ) eval ${REBOOT};;
			* ) echo "aborting...";;
		esac
	else
		eval ${REBOOT}
	fi
}

smount() {
	sudo mount "$@"
}

sumount() {
	sudo umount "$@"
}

# takes an e2factory result and extracts it
# arg1: name of the result
# arg2: [optioal] location to extract to
# if no destination is given, the result will be extracted to its own
# location
extract_result() {
	local res=$1
	local dest=${2:-"out/${res}/last"}
	if [ -z ${res} ] || [ ! -d out/${res} ]; then
		echo "No result given or not in a e2factory project"
		return 1
	fi

	tar xf "out/${res}/last/result.tar" -C "${dest}"
}

rgrep() {
	grep -rI "$@"
}

# Changes into a directory and creates it if required
cdm() {
	mkdir -pv "$1" && cd "$1"
}

info() {
    printf "\e[94mINFO:\e[39m %s\n" "$*" >&2
}

error_exit() {
    printf "\e[31mERROR:\e[39m %s\n" "$*" >&2
    exit 1
}

error() {
    printf "\e[31mERROR:\e[39m %s\n" "$*" >&2
}

warning() {
    printf "\e[33mWARNING:\e[39m %s\n" "$*" >&2
}

check_tool() {
	tool=$1
	_err=0
	command -v "${tool}" >/dev/null 2>&1 || _err=$((_err + 1))
	which "${tool}" >/dev/null 2>&1 || _err=$((_err + 1))
	pkg-config --list-all 2>/dev/null | grep -i "${tool}" >/dev/null || _err=$((_err + 1))
	if [ ${_err} -eq 3 ]; then
		error "$1 not available"
	fi
}

check_tool_sudo() {
	tool=$1
	_err=0
	sudo command -v "${tool}" >/dev/null 2>&1 || _err=$((_err + 1))
	sudo which "${tool}" >/dev/null 2>&1 || _err=$((_err + 1))
	sudo pkg-config --list-all 2>/dev/null | grep -i "${tool}" >/dev/null || _err=$((_err + 1))
	if [ ${_err} -eq 3 ]; then
		error "$1 not available"
	fi
}

check_env() {
	env=$1
	if [ -z "${env}" ]; then
		error "${env} not set"
	fi
}

check_file() {
	_file="$1"
	if [ ! -f "${_file}" ]; then
		error "$1 not available"
	fi
}

yes_no() {
	question=$1
	done=0
	printf "%s (y/N) " "${question}"
	while [ $done -eq 0 ]; do
		read -r input
		if [ "x${input}" = "xy" ]; then
			done=1
			return 0
		fi
		if [ "x${input}" = "xn" ] || \
		   [ "x${input}" = "x" ]; then
			return 1
		fi
		printf "\n%s (y/N) " "${question}"
	done
}

prestart() {
    local pname="$1"
    local pids

    pids=$(pgrep --exact --full "$pname")
    if [ -n "${pids}" ]; then
	echo "$pname running with pid(s): ${pids}"
	kill "${pids}"
	sleep 0.5
    else
	echo "$pname not running"
    fi

    echo -n "Starting $pname..."
    nohup "$pname" >/dev/null 2>&1 &
}
