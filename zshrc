echo -n "+++Reading .zshrc"
[[ -o interactive ]] && echo -n " (for interactive use)"
echo .

# used for reporting how long loading takes
zmodload zsh/datetime
start=$EPOCHREALTIME

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

export XSESSION=i3wm

# the zsh theme configuration
ZSH=$HOME/.oh-my-zsh
ZSH_THEME="lambda-mod"


# history and completion
HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000
COMPLETION_WAITING_DOTS="true"

# zsh completion
if [ -d ~/.zsh.d/zsh-completions ] ; then
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

autoload -U compinit zrecompile

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
    if [[ ! -x $ZSHDEBUG ]]; then
        echo +++ $(basename $zshrc)
    fi
    source $zshrc
done
unsetopt EXTENDED_GLOB

end=$EPOCHREALTIME
printf "+++Loaded files in %0.4f seconds\n" $(($end-$start))

# Default programs
export T_EDITOR="emacsclient -t"
export G_EDITOR="emacsclient -c"
export EDITOR="emacsclient -t"
export ALTERNATE_EDITOR="emacs --daemon && emacsclient -t"
export PAGER="less"
export BROWSER="firefox"
export MOVPLAY="vlc"
export PICVIEW="feh"
export SNDPLAY="mplayer"
export TERMINAL="urxvt"
export PDFVIEW="mupdf"
export LOFFICE="libreoffice"

# Locations and PATH
export JAVA_HOME='/usr/java/jdk1.8.0_111'
export INTELLIJ_HOME='/usr/local/intellij'
export ECLIPSE_HOME='/usr/local/eclipse'
export ANDROID_STUDIO_HOME='/media/hdd2/android-studio'
export ANDROID_SDK_HOME='/media/hdd2/android-sdk-linux/platform-tools'
export XDG_CONFIG_HOME='/home/martin/.config/'
export CROSSTOOL_NG='/home/martin/x-tools/arm-unknown-eabi/'
export CPPUTEST_HOME='/opt/cpputest/'
export XULRUNNER_PATH='/opt/xulrunner/xulrunner'
export CONKEROR_PATH='/home/martin/git/conkeror/application.ini'

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

# path
path=(~/bin
      $JAVA_HOME/bin
      $INTELLIJ_HOME/bin
      $CROSSTOOL_NG/bin
      $ANDROID_STUDIO_HOME/bin
      $JAVA_HOME/include
      $ECLIPSE_HOME/bin
      $ANDROID_SDK_HOME
      $path)
