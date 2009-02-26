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

function gvman()
{
    local manpage=$1
    local tempfile=$(mktemp -t gvman.XXXXXXXX)
    local man_exit_code=0

    man -Tps $manpage > $tempfile
    man_exit_code=$?

    if [ "$man_exit_code" == "0" ]; then
        gv --spartan $tempfile
    fi

    rm $tempfile
    return $man_exit_code
}
