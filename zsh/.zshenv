# -*- mode: zsh -*-

# export things that take longer than 5 seconds
export REPORTTIME=5

# don't show load in prompt by default
export SHOW_LOAD=false

# word chars
# default is: *?_-.[]~=/&;!#$%^(){}<>
# other: "*?_-.[]~=&;!#$%^(){}<>\\"
export WORDCHARS='*?_-.[]~=&;!#$%^(){}'
export XSESSION=dwm
export SUDO_EDITOR="emacsclient -t"
export ZSH=${HOME}/.oh-my-zsh

# Default programs
export T_EDITOR="emacsclient -t"
export G_EDITOR="emacsclient -c"
export EDITOR="emacsclient -t"
export ALTERNATE_EDITOR="emacs --daemon && emacsclient -t"
export PAGER="less"
export BROWSER="chromium"
export MOVPLAY="mplayer"
export PICVIEW="feh"
export SNDPLAY="mplayer"
export TERMINAL="st"
export FEXPLORER="thunar"
export PDFVIEW="mupdf"
export LOFFICE="libreoffice"
export MENUCONFIG_COLOR="mono"

# Backup
export BORG_PASSCOMMAND="gpg --decrypt ${HOME}/borgbackup.key.gpg"




