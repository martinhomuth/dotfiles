#!/bin/zsh

# Directories
alias C='clear'
alias l='ls'
alias ll='ls -lisa'
alias la='ls -lisa'
alias ..='cd ..'
alias ...='cd ..\..'
alias cD='cd ~/Downloads'

# System
alias lock='xscreensaver-command --lock'
alias reboot='sudo reboot'
alias shutdown='sudo shutdown -hP now'
alias update='sudo eix-update && sudo emerge --sync && sudo emerge -uDNa world && sudo emerge -uDNa system'
alias i='sudo emerge -av'
alias s='eix'
alias systemctl='sudo systemctl'
alias netctl='sudo netctl'
alias k='exit'
alias backup='sudo rsync -aAXv /* $1 --exclude={/dev/,/proc/,/sys/,/tmp/,/run/,/mnt/,/media/,/lost+found}'
alias audiooff='sudo pkill mpd && sudo modprobe -r snd_hda_intel && \
    sudo modprobe -r snd_hda_codec'
alias audioon='sudo modprobe snd_hda_intel && sudo modprobe snd_hda_codec && mpd'
alias conkeror='$XULRUNNER_PATH $CONKEROR_PATH'

# Dropbox
alias dropbox='~/.dropbox-dist/dropboxd &'

# interactive C
alias go_libs='-lm'
alias go_flags='-g -Wall -pedantic -Werror -include allhead.h'
alias go_c='c99 -xc - $go_libs $go_flags -o /tmp/go_c.out'
alias rc='/tmp/go_c.out 2>/dev/null || echo "no file"'

# Network
alias MAGI='sudo netctl switch-to MAGI'
alias COCOWLAN='sudo netctl switch-to COCOWLAN'
alias EDUROAM='sudo netctl switch-to EDUROAM'
alias HU_PSE='sudo netctl switch-to HU_PSE'
alias HU_DOR24='sudo netctl switch-to HU_DOR24'
alias HU_DOR65='sudo netctl switch-to HU_DOR65'
alias scanWLAN='sudo iw dev wlp3s0 scan | less'
alias meinfernbus='sudo netctl switch-to MEINFERNBUS'
alias pingG='ping -c 3 www.google.de'
alias wlanoff='sudo systemctl stop wlp3s0.service'
alias wlanon='sudo systemctl start wlp3s0.service'

# Editing
alias sL='sudo leafpad'
alias e="emacsclient -t"
alias se="SUDO_EDITOR=\"emacsclient -t\" sudo -e"
alias ee="emacsclient -t ~/.emacs.d/martin.org"

# Awesome
alias eA='$T_EDITOR ~/.config/awesome/rc.lua'
alias esA='sudo emacscleint -t  /etc/xdg/awesome/rc.lua'
alias cdA='cd ~/.config/awesome'

# Zsh
alias eZ='emacsclient -t ~/.zshrc'
alias Z='source ~/.zshrc'
alias comms='urxvt -e weechat \& && mcabber \& k'

# Urxvt
alias eX='emacsclient -t ~/.Xdefaults'

# news
alias rss='newsbeuter'
