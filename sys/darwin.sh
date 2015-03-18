# -*- sh -*-

alias ls='ls -Gsph'
alias ll='ls -l'
alias la='ls -A'

export PROMPT_COMMAND='history -a; history -n'
export PATH="${HOME}/.bin:${PATH}"
export PAGER="/usr/bin/less"

if [[ ! -z $(which emacsclient) ]]; then
    export EDITOR="$(which emacsclient) -c -a $(which vim || which vi)"
else
    export EDITOR="$(which vim || which vi)"
fi

export PS1='\h:\w\$ '
