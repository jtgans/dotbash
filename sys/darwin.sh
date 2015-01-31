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

export PROMPT_COMMAND='history -a; history -n'
export PATH="${HOME}/.bin:${PATH}"
export PAGER="/usr/bin/less"

if [[ ! -z $(which emacsclient) ]]; then
    export EDITOR="$(which emacsclient) -c -a $(which vim || which vi)"
else
    export EDITOR="$(which vim || which vi)"
fi

export PS1='\h:\w\$ '
