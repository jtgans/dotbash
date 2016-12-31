# -*- sh -*-

require screen
require string
require emacs

eval $(dircolors -b)
alias ls='ls --color=auto -hsF'
alias ll='ls -l'
alias la='ls -A'
alias dhelp='dhelp -f'
alias bc='bc -l'

# Setup an appropriate locale
LANG=$(locale -a |grep en_US.utf8 |head -n 1)
if [ -z "$LANG" ]; then
    LANG=$(locale -a |grep en_US |head -n 1)
    if [ -z "$LANG" ]; then
        LANG=C
    fi
fi
export LANG

export LC_COLLATE=C
export PROMPT_COMMAND='history -a'
export PATH="${HOME}/.bin:/usr/local/bin:${PATH}"
export PAGER="/usr/bin/less"
export EDITOR="$(which emacsclient) -c -a $(which vim || which vi)"
export BROWSER=""
export LESS="-MRFX"
export HISTTIMEFORMAT="%m/%d/%Y %H:%M:%S "

export PS1='\h:\w\$ '

# Debian related stuff
export DEBEMAIL="june@theonelab.com"
export DEBFULLNAME="June Tate-Gans"

if in-screen; then
    export TERM="xterm-256color"
    unset TERMCAP  # Fix broken ncurses behavior
fi
