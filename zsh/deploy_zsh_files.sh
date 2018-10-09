#!/bin/bash

# zsh startup file deployment script

if [ -f "/usr/local/include/common.sh" ]; then
	. "/usr/local/include/common.sh"
else
	error() {
		printf "ERROR: %s" "$@"
	}

	warning() {
		printf "WARNING: %s" "$@"
	}
fi

if [ ! "x$1" = "x-u" -a ! $UID -eq 0 ]; then
	error "Must be executed as root"
fi

if [ ! -f /bin/zsh ]; then
	error "zsh not available"
fi

# replace USER with the sudo user if necessary
USER=${SUDO_USER:=$USER}

ZSHENV="zshenv"
ZSHENVTARGET="/home/${USER}/.zshenv"
ETCZSHENV="etc-zshenv"
ETCZSHENVTARGET="/etc/zshenv"
ZPROFILE="zprofile"
ZPROFILETARGET="/home/${USER}/.zprofile"
ETCZPROFILE="etc-zprofile"
ETCZPROFILETARGET="/etc/zprofile"
ZSHRC="zshrc"
ZSHRCTARGET="/home/${USER}/.zshrc"
ETCZSHRC="etc-zshrc"
ETCZSHRCTARGET="/etc/zshrc"
ZLOGIN="zlogin"
ZLOGINTARGET="/home/${USER}/.zlogin"
ETCZLOGIN="etc-zlogin"
ETCZLOGINTARGET="/etc/zlogin"
ZSHDIR="zsh.d"
ZSHDIRTARGET="/home/${USER}/.zsh.d"
OHMYZSH="oh-my-zsh"
OHMYZSHTARGET="/home/${USER}/.oh-my-zsh"
ZLOGOUT="zlogout"
ZLOGOUTTARGET="/home/${USER}/.zlogout"
ETCZLOGOUT="etc-logout"
ETCZLOGOUTTARGET="/etc/zlogout"

declare -A fileArray=(
	[${ZSHENV}]=${ZSHENVTARGET}
	[${ZPROFILE}]=${ZPROFILETARGET}
	[${ZSHRC}]=${ZSHRCTARGET}
	[${ZLOGIN}]=${ZLOGINTARGET}
	[${ZSHDIR}]=${ZSHDIRTARGET}
	[${OHMYZSH}]=${OHMYZSHTARGET}
	[${ZLOGOUT}]=${ZLOGOUTTARGET}
)

if [ ! "x$1" = "x-u" ]; then
    fileArray+=(
	[${ETCZLOGIN}]=${ETCZLOGINTARGET}
	[${ETCZSHRC}]=${ETCZSHRCTARGET}
	[${ETCZPROFILE}]=${ETCZPROFILETARGET}
	[${ETCZSHENV}]=${ETCZSHENVTARGET}
	[${ETCZLOGOUT}]=${ETCZLOGOUTTARGET}
    )
fi

for K in "${!fileArray[@]}"; do

	target="${fileArray[$K]}"

	if [ -z "${REMOVE}" ]; then

		if [ -e "$target" -o -L "$target" ]; then
			warning "Configuration file $target already exists"
			continue
		fi

		ln -sv "$(pwd -P)/$K" "${fileArray[$K]}"
	else
		if [ -L ${target} ]; then
			rm -v ${target}
		else
			warning "$target is no symbolic link"
		fi
	fi
done
