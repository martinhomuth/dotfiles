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

if [ ! $UID -eq 0 ]; then
	error "Must be executed as root"
fi

if [ ! -f /bin/zsh ]; then
	error "zsh not available"
fi

ZSHENV="zshenv"
ZSHENVTARGET="/home/${SUDO_USER}/.zshenv"
ETCZSHENV="etc-zshenv"
ETCZSHENVTARGET="/etc/zshenv"
ZPROFILE="zprofile"
ZPROFILETARGET="/home/${SUDO_USER}/.zprofile"
ETCZPROFILE="etc-zprofile"
ETCZPROFILETARGET="/etc/zprofile"
ZSHRC="zshrc"
ZSHRCTARGET="/home/${SUDO_USER}/.zshrc"
ETCZSHRC="etc-zshrc"
ETCZSHRCTARGET="/etc/zshrc"
ZLOGIN="zlogin"
ZLOGINTARGET="/home/${SUDO_USER}/.zlogin"
ETCZLOGIN="etc-zlogin"
ETCZLOGINTARGET="/etc/zlogin"
ZSHDIR="zsh.d"
ZSHDIRTARGET="/home/${SUDO_USER}/.zsh.d"
OHMYZSH="oh-my-zsh"
OHMYZSHTARGET="/home/${SUDO_USER}/.oh-my-zsh"
ZLOGOUT="zlogout"
ZLOGOUTTARGET="/home/${SUDO_USER}/.zlogout"
ETCZLOGOUT="etc-logout"
ETCZLOGOUTTARGET="/etc/zlogout"

declare -A fileArray=(
	[${ZSHENV}]=${ZSHENVTARGET}
	[${ETCZSHENV}]=${ETCZSHENVTARGET}
	[${ZPROFILE}]=${ZPROFILETARGET}
	[${ETCZPROFILE}]=${ETCZPROFILETARGET}
	[${ZSHRC}]=${ZSHRCTARGET}
	[${ETCZSHRC}]=${ETCZSHRCTARGET}
	[${ZLOGIN}]=${ZLOGINTARGET}
	[${ETCZLOGIN}]=${ETCZLOGINTARGET}
	[${ZSHDIR}]=${ZSHDIRTARGET}
	[${OHMYZSH}]=${OHMYZSHTARGET}
	[${ZLOGOUT}]=${ZLOGOUTTARGET}
	[${ETCZLOGOUT}]=${ETCZLOGOUTTARGET}
)

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
