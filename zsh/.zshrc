# -*- mode: sh -*-

[[ $TERM == "dumb" ]] && unsetopt zle && PS1='$ ' && return

# run for interactive shells
if [ ! -z "${DEBUG}" ]; then
	echo -n "+++Reading .zshrc"
	[[ -o interactive ]] && echo -n " (for interactive use)"
	echo .

	# used for reporting how long loading takes
	zmodload zsh/datetime
	start=$EPOCHREALTIME
fi

if [ ! -f /usr/include/mh_common.sh ]; then
	echo "ERROR: no mh_common.sh found"
else
	source /usr/include/mh_common.sh
fi

# when globbing multiple items, one match results in success,
# no match results in an error.
setopt CSH_NULL_GLOB

# Prints the bang history before executing it
# setopt HIST_VERIFY
# export things that take longer than 5 seconds
export REPORTTIME=5

# don't show load in prompt by default
export SHOW_LOAD=false

# word chars
# default is: *?_-.[]~=/&;!#$%^(){}<>
# other: "*?_-.[]~=&;!#$%^(){}<>\\"
export WORDCHARS='*?_-.[]~=&;!#$%^(){}'

export XSESSION=dwm

# the zsh theme configuration
ZSH=$HOME/.oh-my-zsh
ZSH_THEME="avit"

# history and completion
HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000
COMPLETION_WAITING_DOTS="true"
export SUDO_EDITOR="emacsclient -t"

# zsh completion
if [ -s ~/.zsh.d/zsh-completions/zsh-completions.plugin.zsh ] ; then
    source ~/.zsh.d/zsh-completions/zsh-completions.plugin.zsh
fi

# use zsh syntax highlighting if available
if [ -s ~/.zsh.d/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] ; then
    source ~/.zsh.d/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# zsh auto suggestions
if [ -s ~/.zsh.d/zsh-autosuggestions/zsh-autosuggestions.zsh ] ; then
    source ~/.zsh.d/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

# zsh auto completion
if [ -s ~/.zsh.d/zsh-autocomplete/zsh-autocomplete.plugin.zsh ] ; then
    source ~/.zsh.d/zsh-autocomplete/zsh-autocomplete.plugin.zsh
fi

autoload -U compinit zrecompile promptinit
compinit
promptinit;

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


# source .zsh.d
setopt EXTENDED_GLOB
for zshrc in ~/.zsh.d/[0-9][0-9]*[^~] ; do
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

# Default programs
export T_EDITOR="emacsclient -t"
export G_EDITOR="emacsclient -c"
export EDITOR="emacsclient -t"
export ALTERNATE_EDITOR="emacs --daemon && emacsclient -t"
export PAGER="less"
export BROWSER="qutebrowser"
export MOVPLAY="mplayer"
export PICVIEW="feh"
export SNDPLAY="mplayer"
export TERMINAL="urxvt"
export FEXPLORER="thunar"
export PDFVIEW="mupdf"
export LOFFICE="libreoffice"
export MENUCONFIG_COLOR="mono"

export MENUCONFIG_COLOR="mono"

DATAPATH=/data
DEVPATH=${DATAPATH}
export INTELLIJ_HOME='/opt/intellij'
export XDG_CONFIG_HOME="${HOME}/.config/"
export CPPUTEST_HOME='/opt/cpputest/'
export SBT_HOME="/opt/sbt"
export TURTL_HOME="/opt/turtl"

# File Extensions
for ext in html org php com net no; do alias -s $ext=$BROWSER; done
for ext in txt tex py PKGBUID; do alias -s $ext=$EDITOR; done
for ext in png jpg gif; do alias -s $ext=$PICVIEW; done
for ext in mpg wmv avi mkv; do alias -s $ext=$MOVPLAY; done
for ext in wav mp3 ogg; do alias -s $ext=$SNDPLAY; done
for ext in pdf; do alias -s $ext=$PDFVIEW; done
for ext in odp ods odt; do alias -s $ext=$LOFFICE; done

plugins=(git archlinux themes color-command)
source $ZSH/oh-my-zsh.sh

export QT_SELECT=qt5

# fallback make version
export MAKE382=/opt/make-3.82/bin

# work
export E2FACTORY_HOME=/opt/emlix/e2factory-2.3.18p1
export CCACHE_DIR=/data/android/.ccache
export USE_CCACHE=1
export TOOLCHAINS_ROOT=${DATAPATH}/toolchains
# odroid Android toolchains
#http://releases.linaro.org/archive/14.09/components/toolchain/binaries/gcc-linaro-aarch64-none-elf-4.9-2014.09_linux.tar.xz
#http://releases.linaro.org/archive/14.04/components/toolchain/binaries/gcc-linaro-arm-none-eabi-4.8-2014.04_linux.tar.xz
#https://releases.linaro.org/components/toolchain/binaries/6.3-2017.05/aarch64-linux-gnu/gcc-linaro-6.3.1-2017.05-x86_64_aarch64-linux-gnu.tar.xz
export ODROID_ANDROID_TOOLCHAINS=(
	${TOOLCHAINS_ROOT}/gcc-linaro-6.3.1-2017.05-x86_64_aarch64-linux-gnu/bin
	${TOOLCHAINS_ROOT}/gcc-linaro-aarch64-none-elf-4.9-2014.09_linux/bin
	${TOOLCHAINS_ROOT}/gcc-linaro-arm-none-eabi-4.8-2014.04_linux/bin
)

path=(
	$HOME/.local/bin
	$HOME/bin
	$INTELLIJ_HOME/bin
	$ODROID_ANDROID_TOOLCHAINS
	$E2FACTORY_HOME/bin
	$MAKE382
	$TAF_UNIDOS/bin
	$SBT_HOME/bin
	$TURTL_HOME
	$path
)

# Backup
export BORG_PASSCOMMAND="gpg --decrypt ${HOME}/borgbackup.key.gpg"


eval "$(zoxide init zsh)"
eval "$(atuin init zsh)"
eval "$(direnv hook zsh)"
