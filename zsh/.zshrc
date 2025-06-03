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

autoload -U compinit zrecompile promptinit
compinit
promptinit

path=(
	$HOME/.local/bin
	$HOME/bin
	$path
)

# prompt
fpath=(${ZSHD_HOME}/prompts $fpath)
autoload -Uz mh; mh
