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
