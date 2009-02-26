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

export _IN_SCREEN=$([ ! -z "${WINDOW}" ] && echo true)

function in-screen()
{
	if [ ! -z "${_IN_SCREEN}" ]; then
		return 0
	else
		return 1
	fi
}

function screen-set-window-title()
{
	if in-screen; then
		echo -ne "\\ek$@\\e\\\\"
	fi
}

function screen-ssh-pre-hook()
{
    local remotehost=$1
    screen-set-window-title $remotehost
}

function screen-ssh-post-hook()
{
    screen-set-window-title $HOSTNAME
}
