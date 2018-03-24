#!/bin/zsh
# remove the caps key and replace it with a second control key
setxkbmap -option ctrl:nocaps

# Emacs as daemon forevah!
# print Starting Emacs Server

# if [[ "x${EMACS_SERVER_RUNNING}" == "x" ]]; then
#     emacs --daemon 2&> /dev/null
#     EMACS_SERVER_RUNNING=1
#     export EMACS_SERVER_RUNNING
#     print ok.
# else
#     print failed.
# fi
