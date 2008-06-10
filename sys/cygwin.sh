# -*- sh -*-
#
# Copyright (C) 2008  June Tate-Gans, All Rights Reserved.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

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

