# Zsh functions

not_in_emacs() {
  [[ ! -n $EMACS ]]
}

not_in_cloud() {
  ! fgrep -q ami_id /etc/motd 2>/dev/null
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

# functions
function history-all { history -E 1 }
function setenv() { export $1=$2 }  # csh compatibility
function rot13 () { tr "[a-m][n-z][A-M][N-Z]" "[n-z][a-m][N-Z][A-M]" }
function maxhead() { head -n `echo $LINES - 5|bc` ; }
function maxtail() { tail -n `echo $LINES - 5|bc` ; }
function bgrep() { git branch -a | grep "$*" | sed 's,remotes/,,'; }

# function to fix ssh agent
function fix-agent() {
    disable -a ls
    export SSH_AUTH_SOCK=`ls -t1 $(find /tmp/ -uid $UID -path \\*ssh\\* -type s 2> /dev/null) | head -1`
    enable -a ls
}

# Usage: simple-extract <file>
# Using option -d deletes the original archive file.
#f5# Smart archive extractor
simple-extract() {
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

__archive_or_uri()
{
    _alternative \
        'files:Archives:_files -g "*.(#l)(tar.bz2|tbz2|tbz|tar.gz|tgz|tar.xz|txz|tar.lzma|tar|rar|lzh|7z|zip|jar|deb|bz2|gz|Z|xz|lzma)"' \
        '_urls:Remote Archives:_urls'
}

_simple_extract()
{
    _arguments \
        '-d[delete original archivefile after extraction]' \
        '*:Archive Or Uri:__archive_or_uri'
}

# define a word
function define(){
    if [[ $# -ge 2 ]] then
        echo "givedef: too many arguments" >&2
        return 1
    else
        curl "dict://dict.org/d:$1"
    fi
}

## TODO make these scripts instead of functions

# Check if a URL is up
function chk-url() {
    curl -sL -w "%{http_code} %{url_effective}\\n" "$1" -o /dev/null
}

function pub() {
    scp $1 writequit:public_html/wq/pub/
}

# Check CLA status for ES pull requests
function cla() {
    curl -I "http://54.204.36.1:3000/verify/nickname/$1"
}

# Tunnel ES from somewhere to here locally on port 9400
function es-tunnel() {
    autossh -M0 $1 -L 9400:localhost:9200 -CNf
}

# Tunnel logstash/kibana locally
function kibana-tunnel() {
    autossh -M0 $1 -L 9292:localhost:9292 -CNf
}

# Delete a branch locally and on my (dakrone) fork
function del-branch() {
    git branch -d $1
    git push dakrone :$1
}

# Fuzzy-check-out, check out the first local branch that matches
function fco() {
    git checkout `git branch | grep -i $1 | head -1 | tr -d " "`
}

# look up a process quickly
function pg {
    # doing it again afterwards for the coloration
    ps aux | fgrep -i $1 | fgrep -v "grep -F" | fgrep -i $1
}

function in_emacs {
  [[ -n $EMACS ]]
}

extract () {
   if [ -f $1 ] ; then
     case $1 in
  	*.tar.bz2)	tar xvjf $1 && cd $(basename "$1" .tar.bz2) ;;
	*.tar.gz)	tar xfvz $1 && cd $(basename "$1" .tar.gz) ;;
	*.tar.xz)	tar Jxvf $1 && cd $(basename "$1" .tar.xz) ;;
	*.bz2)		bunzip2 $1 && cd $(basename "$1" /bz2) ;;
	*.rar)		unrar x $1 && cd $(basename "$1" .rar) ;;
	*.gz)		gunzip $1 && cd $(basename "$1" .gz) ;;
	*.tar)		tar xvf $1 && cd $(basename "$1" .tar) ;;
	*.tbz2)		tar xvjf $1 && cd $(basename "$1" .tbz2) ;;
	*.tgz)		tar xvzf $1 && cd $(basename "$1" .tgz) ;;
	*.zip)		unzip $1 && cd $(basename "$1" .zip) ;;
	*.Z)		uncompress $1 && cd $(basename "$1" .Z) ;;
	*.7z)		7z x $1 && cd $(basename "$1" .7z) ;;
	*)		echo "don't know how to extract '$1'..." ;;
     esac
  else
    echo "'$1' is not a valid file!"
  fi
}

function in_gentoo {
	[[ -x /usr/bin/emerge ]]
}

function in_arch {
	[[ -x /usr/bin/pacman ]]
}

# search for a package in the current distribution's package manager
function s {
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
function i {
	if [ ! $# -ge 1 ]; then
		echo "Usage: i <package>"
		return
	fi
	if in_gentoo; then
		sudo emerge -av "$@"
	elif in_arch; then
		sudo pacman -S "$@"
	else
		echo "Unknown distribution"
	fi
}

function playground {
	e2-build --playground $1
	e2-playground --runinit $1
}

function sgrep {
	find . -name .repo -prune -o -name .git -prune -o  -type f -iregex '.*\.\(c\|h\|cc\|cpp\|S\|java\|xml\|sh\|mk\|aidl\)' -print0 | xargs -0 grep --color -n "$@"
}

function bgrep {
	find . -name .repo -prune -o -name .git -prune -o  -type f -iregex 'build-script' -print0 | xargs -0 grep --color -n "$@"
}

# emacs calling function replacing the simple alias
function e {
	if [[ -n "$(command -v emacs)"  ]]; then
		emacsclient -t "$@"
	else
		error "Emacs is not available"
	fi
}

# WIP
# function that is intended to be used for toggling the debug output of the shell
# during a function execution
function toggledebug {
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
function emlix {
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
function shutdown {
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
function reboot {
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

function smount {
	sudo mount "$@"
}

function sumount {
	sudo umount "$@"
}

# takes an e2factory result and extracts it
# arg1: name of the result
# arg2: [optioal] location to extract to
# if no destination is given, the result will be extracted to its own
# location
function extract_result {
	local res=$1
	local dest=${2:-"out/${res}/last"}
	if [ -z ${res} ] || [ ! -d out/${res} ]; then
		echo "No result given or not in a e2factory project"
		return 1
	fi

	tar xf "out/${res}/last/result.tar" -C "${dest}"
}

function rgrep {
	grep -rI "$@"
}

function emlixchat {
	/usr/bin/ssh -t emlix "tmux attach"
}

# restarts a process
# arg1: process name or PID
# if the process name is given, prompt for the correct one (with dmenu if possible)
function prestart {
	local _findpid=0
	# check for pid or name
	[ -z "${1//[0-9]}" ] && [ -n "$1" ] || _findpid=1

	if [ $_findpid -eq 1 ]; then
		local _pids=($(pidof $1))
		if [ ${#_pids[@]} -eq 1 ]; then
			_PID=$_pids
		else
			warning "multiple instances of $1 running, please identify pid yourself (prompt tbd)"
			return 2
		fi
	else
		_PID=$1
	fi

	EXEC="$(cat /proc/$_PID/cmdline 2>/dev/null)"
	kill $_PID 2>/dev/null
	ret=$?
	if [ ! $ret -eq 0 ]; then
		error "Unable to kill process $_PID"
		return 1
	else
		nohup $EXEC 2>/dev/null &
	fi
}

function vpn_up {
	nmcli --ask c up b79d0113-966d-4495-934d-49269266eb48
}

function vpn_down {
	nmcli c down b79d0113-966d-4495-934d-49269266eb48
}
