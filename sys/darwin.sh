# -*- sh -*-

require hooks

alias ls='ls -Gsph'
alias ll='ls -l'
alias la='ls -A'

function history-append-and-reload() {
    history -a
    history -n
}

add-hook _PROMPT_HOOKS history-append-and-reload

export PATH="${HOME}/.bin:${PATH}"
export PAGER="/usr/bin/less"

if [[ ! -z $(which emacsclient) ]]; then
    export EDITOR="$(which emacsclient) -c -a $(which vim || which vi)"
else
    export EDITOR="$(which vim || which vi)"
fi

export PS1='\h:\w\$ '
