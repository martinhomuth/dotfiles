#!/bin/zsh

# Directories
alias C='clear'
alias se="sudo -i ${USER} emacsclient -t"
alias ll='ls -lisa'
alias ..='cd ..'
alias ...='cd ..\..'
alias cD='cd ~/Downloads'
alias rm='rm -vI'
alias mv='mv -vi'

# Colorize commands when possible.
alias l='ls -hN --color=auto --group-directories-first'
alias grep='grep --color=auto'
alias diff='diff --color=auto'

# System
alias lock='xscreensaver-command --lock'
if [ -x /usr/bin/emerge ]; then
	alias updatedb="sudo eix-update && sudo emerge --sync"
	alias update='sudo emerge -uDNa world && sudo emerge -uDNa system'
elif [ -x /usr/bin/pacman ]; then
	alias update="sudo pacman -Syuu"
	alias updatedb="sudo pacman -Syuu --dbonly --noconfirm"
else
	alias update="echo unknown distribution"
fi
alias systemctl='sudo systemctl'
alias k='exit'

# interactive C
alias go_libs='-lm'
alias go_flags='-g -Wall -pedantic -Werror -include allhead.h'
alias go_c='c99 -xc - $go_libs $go_flags -o /tmp/go_c.out'
alias rc='/tmp/go_c.out 2>/dev/null || echo "no file"'

# Editing
alias se="SUDO_EDITOR=\"emacsclient -t\" sudo -e"
alias ee="emacsclient -t ~/.emacs.d/${USER}.org"
alias eX='emacsclient -t ~/.Xdefaults'

# Zsh
alias eZ='emacsclient -t ~/.zshrc'
alias Z='source ~/.zshrc'

# news
alias rss='newsbeuter'
