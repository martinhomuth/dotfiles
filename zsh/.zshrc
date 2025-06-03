# -*- mode: sh -*-

[[ $TERM == "dumb" ]] && unsetopt zle && PS1='$ ' && return

if [ ! -f /usr/include/mh_common.sh ]; then
	echo "ERROR: no mh_common.sh found"
else
	source /usr/include/mh_common.sh
fi

# history and completion
HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000
COMPLETION_WAITING_DOTS="true"

## ZSH Options (https://zsh.sourceforge.io/Doc/Release/Options.html#Options)

# when globbing multiple items, one match results in success,
# no match results in an error.
setopt CSH_NULL_GLOB

# Do not print the directory stack after pushd or popd.
setopt PUSHD_SILENT

# Don’t push multiple copies of the same directory onto the directory stack.
setopt PUSHD_IGNORE_DUPS

# Make cd push the old directory onto the directory stack.
setopt AUTO_PUSHD

# If a command is issued that can’t be executed as a normal command, and the command is the name of a directory, perform
# the cd command to that directory. This option is only applicable if the option SHIN_STDIN is set, i.e. if commands are
# being read from standard input. The option is designed for interactive use; it is recommended that cd be used
# explicitly in scripts to avoid ambiguity.
setopt AUTO_CD

# When writing out the history file, older commands that duplicate newer ones are omitted.
setopt HIST_SAVE_NO_DUPS

# don't set high nice values for background jobs by default
setopt NO_BG_NICE

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
compinit
promptinit

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
