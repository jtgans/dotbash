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

alias ls='ls -Gsph'
alias ll='ls -l'
alias la='ls -A'

export PROMPT_COMMAND='history -a'
export PATH="${HOME}/.bin:${PATH}:/opt/local/bin"
export PAGER="/usr/bin/less"
export EDITOR=""
export PS1='\h:\w\$ '

if [ "$TERM" == "dtterm" ]; then
  export TERM="xterm"       # Makes terminfo happy

  alias dock='echo -ne "\E[2t"'
  alias raise='echo -ne "\E[5t"'
  alias 132x30='echo -ne "\E[8;132;30t"'
  alias 80x30='echo -ne "\E[8;80;30t"'
  alias maxh='echo -ne "\E[8;0;80t"'
  alias maxw='echo -ne "\E[8;24;0t"'
  alias bgmake='dock; make \~*; raise'
fi
