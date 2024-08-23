# vim:ft=zsh:colorcolumn=80:tw=80

# === DOCUMENTATION ============================================================
# Symbols require `hack nerd font mono`
# Check `fc-list hacknerdfontmono` and add to `.Xresources`


# === DEFINES ==================================================================

SYM_PTR=$'\uE285'

SYM_ARR_PORT=$'\uE0B0'
SYM_ARR_STAR=$'\uE0B2'

SYM_BAR_HOR=$'\u2501'
SYM_BAR_VER=$'\u2503'

SYM_TOP_PORT=$'\u250F'
SYM_TOP_STAR=$'\u2513'
SYM_BOT_PORT=$'\u2517'
SYM_BOT_STAR=$'\u251B'
SYM_TEE_PORT=$'\u2523'
SYM_TEE_STAR=$'\u252B'

SYM_ELLIPSE=$'\u2026'

SYM_KEYS=$'\uE60A'

PADDING_PLAQUE=2
PADDING_BORDER=2

SYM_GIT_REF_TYPE_BRANCH=$'\uE0A0'
SYM_GIT_REF_TYPE_TAG=$'\u25C8'
SYM_GIT_REF_TYPE_COMMIT=$'\u2234'

SYM_STATE_UNTRACKED=$'\u25CC'
SYM_STATE_UNSTAGED=$'\u2298'
SYM_STATE_UNCOMMITTED=$'\u2295'
SYM_STATE_CLEAN=$'\uF058'

SYM_REMOTE_NONE=$'\u21BB'
SYM_REMOTE_AHEAD=$'\u21EB'
SYM_REMOTE_BEHIND=$'\u21CA'
SYM_REMOTE_DIFF=$'\uEA68'
SYM_REMOTE_SYNCED=$'\u21C4'

# === FUNCTIONS ================================================================

function theme_precmd()
{
	RETVAL=$(print -P $?)

	precmd_top
	precmd_mid
}

function precmd_top()
{
	local term_width=$(( COLUMNS - ${ZLE_RPROMPT_INDENT:-1} ))

	SPACE_TOP=1
	PWD_STR=$(print -P $(get_pwd))

	local port_arr=(
		$PWD_STR
		)

	local star_arr=(
		$(print -P $(get_ssh_state))
		$(print -P $(get_host))
		$(get_date)
		)

	local port_len=$(get_str_len $port_arr)
	local star_len=$(get_str_len $star_arr)

	local total_len=$(( port_len + star_len + PADDING_BORDER - 1 ))

	local pwd_max_len=$(( term_width - star_len - PADDING_BORDER - 1 - PADDING_PLAQUE ))
	if [ $total_len -lt $term_width ]
	then
		SPACE_TOP="$(( term_width - total_len ))"
	else
		local fmt=$(print -f '%%%d<%s<%s' $pwd_max_len $SYM_ELLIPSE $PWD_STR)
		PWD_STR=$(print -P $fmt)
	fi
}

function precmd_mid()
{
	local term_width=$(( COLUMNS - ${ZLE_RPROMPT_INDENT:-1} ))

	SPACE_MID=1
	IS_GIT=is_git

	if $IS_GIT
	then
		local port_arr=(
			x
			x
			"$(get_git_ref_desc)"
		)
	else
		local port_arr=()
	fi

	local star_arr=(
		$(print -P $(get_error_code))
		$(get_time)
		)

	local port_len=$(get_str_len $port_arr)
	local star_len=$(get_str_len $star_arr)

	local total_len=$(( port_len + star_len + PADDING_BORDER - 1 ))

	SPACE_MID="$(( term_width - total_len ))"
}

function get_str_len()
{
	local len=0
	for ele in $@
	do
		len=$(( len + ${#ele} ))
		len=$(( len + PADDING_PLAQUE ))
		len=$(( len + 1 ))
	done

	echo $len
}

function get_pwd()
{
	echo -n %~
}

function get_date()
{
	date +%Y-%m-%d
}

function get_host()
{
	echo -n %m
}

function get_time()
{
	date +%R:%S
}

function get_git_ref_desc()
{
	IS_DETACHED=0

	name=$(git rev-parse --abbrev-ref HEAD)
	if [ "$name" != HEAD ]
	then
		echo $SYM_GIT_REF_TYPE_BRANCH $name
		return
	fi

	name=$(git describe --tags --exact-match 2> /dev/null)
	if [ -n "$name" ]
	then
		echo $SYM_GIT_REF_TYPE_TAG $name
		return
	fi

	IS_DETACHED=1
	echo $SYM_GIT_REF_TYPE_COMMIT $(git rev-parse --short HEAD)
}

function get_git_state()
{
	local state=$(git status --porcelain)

	if [ -z "$state" ]
	then
		build_plaque "#606060" "#30D030" $SYM_STATE_CLEAN
		return
	fi

	if grep -m1 -q "^??" <<< $state
	then
		build_plaque "#D0D0D0" "#F03030" $SYM_STATE_UNTRACKED
		return
	fi

	if grep -m1 -q "^ M" <<< $state
	then
		build_plaque "#606060" "#F0C000" $SYM_STATE_UNSTAGED
		return
	fi

	build_plaque "#606060" "#B0D030" $SYM_STATE_UNCOMMITTED
}

function get_git_remote()
{
	if [ "$IS_DETACHED" = 1 ]
	then
		build_plaque "#F03030" "#D0D0D0" $SYM_REMOTE_NONE
		return
	fi

	if ! git rev-parse @{upstream} > /dev/null 2>&1
	then
		build_plaque "#F03030" "#D0D0D0" $SYM_REMOTE_NONE
		return
	fi

    behind=$(git log --oneline ..@{upstream} 2>/dev/null)
    ahead=$(git log --oneline @{upstream}.. 2>/dev/null)
	if [ -z "$behind" -a -z "$ahead" ]
	then
		build_plaque "#606060" "#30D030" $SYM_REMOTE_SYNCED
		return
	fi

	if [ -n "$behind" -a -n "$ahead" ]
	then
		build_plaque "#606060" "#F0C000" $SYM_REMOTE_DIFF
		return
	fi

	if [ -z "$behind" ]
	then
		build_plaque "#606060" "#B0D030" $SYM_REMOTE_AHEAD
		return
	fi

	build_plaque "#606060" "#B0D030" $SYM_REMOTE_BEHIND
	return
}

function get_ssh_state()
{
	if ssh-add -l > /dev/null
	then
		echo -n $SYM_KEYS
	fi
}

function get_error_code()
{
	case $RETVAL in
	130| \
	148)
		return
		;;
	0)
		return
		;;
	*)
		echo $RETVAL
	esac
}

function is_git()
{
	git status > /dev/null 2>&1
}

function fill_space()
{
	local n=$1
	local char=$2

	local fmt=$(print -f '${(l:%s::%s:)}' $n $char)
	print -P $fmt
}

function build_plaque()
{
	local fg_col=$1
	local bg_col=$2
	shift 2
	local text=$@

	if [ -z "$text" ]
	then
		return
	fi

	local str=""

	str+=%K{$bg_col}
	str+=$SYM_ARR_PORT
	str+=%F{$fg_col}
	str+=%B
	str+=$text
	str+=%b
	str+=%f
	str+=$SYM_ARR_STAR
	str+=%k

	echo $str
}

function build_prompt_top()
{
	local str=""

	str+=$SYM_TOP_PORT
	str+=$SYM_BAR_HOR
	str+=$(build_plaque "#D0D0D0" "#30A0C0" $PWD_STR)
	str+=$(fill_space $SPACE_TOP $SYM_BAR_HOR)

	local state=$(build_plaque "#606060" "#30D030" $(get_ssh_state))

	if [ -n "$state" ]
	then
		str+=$state
		str+=$SYM_BAR_HOR
	fi
	str+=$(build_plaque "#30A0C0" "#D0D0D0" $(get_host))
	str+=$SYM_BAR_HOR
	str+=$(build_plaque "#F0C000" "#606060" $(get_date))
	str+=$SYM_BAR_HOR
	str+=$SYM_TOP_STAR

	echo $str
}

function build_prompt_mid()
{
	local str=""

	if $IS_GIT
	then
		str+=$SYM_TEE_PORT
		str+=$SYM_BAR_HOR
		str+=$(get_git_remote)
		str+=$SYM_BAR_HOR
		str+=$(get_git_state)
		str+=$SYM_BAR_HOR
		str+=$(build_plaque "#D0D0D0" "#F070B0"  $(get_git_ref_desc))
	else
		str+=$SYM_BAR_VER
	fi
	str+=$(fill_space $SPACE_MID " ")

	local err=$(build_plaque "#D0D0D0" "#F03030" $(get_error_code))

	if [ -n "$err" ]
	then
		str+=$err
		str+=$SYM_BAR_HOR
	fi
	str+=$(build_plaque "#606060" "#F0C000" $(get_time))
	str+=$SYM_BAR_HOR
	str+=$SYM_BOT_STAR

	echo $str
}

function build_pointer()
{
	echo -n "$SYM_BOT_PORT$SYM_ARR_PORT$SYM_PTR "
}

function build_prompt()
{
	build_prompt_top
	build_prompt_mid
	build_pointer
}


# === MAIN =====================================================================

autoload -U add-zsh-hook
add-zsh-hook precmd theme_precmd

PROMPT='%f%k%b$(build_prompt)'
