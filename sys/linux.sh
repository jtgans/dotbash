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

require screen
require string

eval $(dircolors -b)
alias ls='ls --color=auto -hsF'
alias ll='ls -l'
alias la='ls -A'
alias dhelp='dhelp -f'

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

if in-string TERM xterm; then
    export PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD}\007"; history -a'
else
    export PROMPT_COMMAND='history -a'
fi

export PATH="${HOME}/.bin:/usr/local/symlinks:${PATH}:/usr/local/scripts"
export PAGER="/usr/bin/less"
export P4CONFIG=".p4config"
export EDITOR="$(which emacsclient) -c"
export BROWSER="/usr/bin/elinks -remote %s"
export LESS="-MR"
export HISTTIMEFORMAT="%m/%d/%Y %H:%M:%S "

export PS1='\h:\w\$ '

# Debian related stuff
export DEBEMAIL="june@theonelab.com"
export DEBFULLNAME="June Tate-Gans"

alias  emacs="${HOME}/.bin/emacs.sh"

if in-screen; then
    export TERM="screen"
    unset TERMCAP  # Fix broken ncurses behavior
fi

# RubyGems related stuff
if [ ! -z "$GEM_HOME" ]; then
    export PATH="${PATH}:$GEM_HOME/bin"
fi
