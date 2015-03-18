# -*- sh -*-

eval $(dircolors -b)
alias ls='ls --color=auto -hsp'
alias ll='ls -l'
alias la='ls -A'
alias dhelp='BROWSER=/usr/bin/w3m dhelp -f'

if echo $TERM |grep -q xterm; then
    export PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD}\007"; history -a'
else
    export PROMPT_COMMAND='history -a'
fi

export PATH="${HOME}/.bin:${PATH}"
export PAGER="/usr/bin/less"
export EDITOR="/usr/bin/emacs"
export BROWSER="/usr/bin/elinks -remote %s"
export PS1='\h:\w\$ '
export LANG="en_US.utf8"

# Debian related stuff
export DEBEMAIL="june@theonelab.com"
export DEBFULLNAME="June Tate-Gans"

# Screen related stuff
if [ "$INTERACTIVE" != "" ]; then
    if [ "$WINDOW" = "" ]; then
        if [ -x /usr/bin/screen ]; then
            echo
            # screen -a -A -d -RR
        else
            echo "Screen not available in /usr/bin/screen -- cannot start screen."
        fi
    else
        alias  emacs="${HOME}/.bin/emacs.sh"
        export EDITOR="${HOME}/.bin/emacs.sh"
        export TERM="screen"
        unset TERMCAP  # Fix broken ncurses behavior
    fi
fi

# RubyGems related stuff
if [ "$GEM_HOME" != "" ]; then
    export PATH="${PATH}:$GEM_HOME/bin"
fi

