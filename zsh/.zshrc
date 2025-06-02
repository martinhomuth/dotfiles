# -*- mode: sh -*-

[[ $TERM == "dumb" ]] && unsetopt zle && PS1='$ ' && return

if [ ! -f /usr/include/mh_common.sh ]; then
	echo "ERROR: no mh_common.sh found"
else
	source /usr/include/mh_common.sh
fi

# when globbing multiple items, one match results in success,
# no match results in an error.
setopt CSH_NULL_GLOB

# history and completion
HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000
COMPLETION_WAITING_DOTS="true"

zstyle ':completion:::::' completer _complete _approximate
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh-cache
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' hosts $ssh_hosts
zstyle ':completion:my-accounts' users-hosts $my_accounts
zstyle ':completion:other-accounts' users-hosts $other_accounts
zstyle -e ':completion:*:approximate:*' max-errors 'reply=( $(( ($#PREFIX + $#SUFFIX) / 3 )) )'
zstyle ':completion:*:descriptions' format "- %d -"
zstyle ':completion:*:corrections' format "- %d - (errors %e})"
zstyle ':completion:*:default' list-prompt '%S%M matches%s'
zstyle ':completion:*' group-name ''
zstyle ':completion:*:manuals' separate-sections true
zstyle ':completion:*:manuals.(^1*)' insert-sections true
zstyle ':completion:*' verbose yes
zstyle ':completion:*' file-list list=20 insert=10

# options
setopt auto_cd

# don't set high nice values for background jobs by default
setopt no_bg_nice
# enable (which is default) function arg zero
setopt function_arg_zero

# autoloads
autoload -U url-quote-magic
zle -N self-insert url-quote-magic

# keybindings
# emacs keybindings
bindkey -e
bindkey "^?" backward-delete-char
bindkey "^p" up-line-or-history
typeset -A key

key[Home]=${terminfo[khome]}

key[End]=${terminfo[kend]}
key[Insert]=${terminfo[kich1]}
key[Delete]=${terminfo[kdch1]}
key[Up]=${terminfo[kcuu1]}
key[Down]=${terminfo[kcud1]}
key[Left]=${terminfo[kcub1]}
key[Right]=${terminfo[kcuf1]}
key[PageUp]=${terminfo[kpp]}
key[PageDown]=${terminfo[knp]}

# setup key accordingly
[[ -n "${key[Home]}"     ]]  && bindkey  "${key[Home]}"     beginning-of-line
[[ -n "${key[End]}"      ]]  && bindkey  "${key[End]}"      end-of-line
[[ -n "${key[Insert]}"   ]]  && bindkey  "${key[Insert]}"   overwrite-mode
[[ -n "${key[Delete]}"   ]]  && bindkey  "${key[Delete]}"   delete-char
[[ -n "${key[Up]}"       ]]  && bindkey  "${key[Up]}"       up-line-or-history
[[ -n "${key[Down]}"     ]]  && bindkey  "${key[Down]}"     down-line-or-history
[[ -n "${key[Left]}"     ]]  && bindkey  "${key[Left]}"     backward-char
[[ -n "${key[Right]}"    ]]  && bindkey  "${key[Right]}"    forward-char
[[ -n "${key[PageUp]}"   ]]  && bindkey  "${key[PageUp]}"   beginning-of-buffer-or-history
[[ -n "${key[PageDown]}" ]]  && bindkey  "${key[PageDown]}" end-of-buffer-or-history


ZSHD_HOME=${HOME}/.zsh.d
# source .zsh.d
setopt EXTENDED_GLOB
for zshrc in ${ZSHD_HOME}/[0-9][0-9]*[^~] ; do
    if [[ ! -z ${DEBUG} ]]; then
        echo +++ $(basename $zshrc)
    fi
    source $zshrc
done
unsetopt EXTENDED_GLOB

if [ ! -z ${DEBUG} ]; then
	end=$EPOCHREALTIME
	printf "+++Loaded files in %0.4f seconds\n" $(($end-$start))
fi

autoload -U compinit zrecompile promptinit
compinit;
promptinit;

path=(
	$HOME/.local/bin
	$HOME/bin
	$path
)

# Backup
export BORG_PASSCOMMAND="gpg --decrypt ${HOME}/borgbackup.key.gpg"

# prompt
fpath=(${ZSHD_HOME}/prompts $fpath)
autoload -Uz mh; mh
