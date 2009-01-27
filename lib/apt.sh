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

function apt-select()
{
    local selections
    local result
    local key
    local arg
    local done
    local search_terms="$@"

    while [ -z "$done" ]; do
        result=$(apt-cache search "$search_terms" | 
            iselect -eamK \
            -kj:KEY_DOWN \
            -kk:KEY_UP   \
            -kn:KEY_DOWN \
            -kp:KEY_UP   \
            -ki:RETURN   \
            -n "apt-select" \
            -t "$search_terms")
        [ -z "$result" ] && return 1

        OLDIFS="$IFS"
        IFS=$'\n'
        for line in $result; do
            key=$(echo $line |sed 's/:.*$//')
            arg=$(echo $line |sed 's/^[^:]*://')
            package=$(echo $arg |sed 's/ -.*$//')

            case $key in
                i)
                    apt-cache show $package |less -+E -+F -c
                    ;;

                RETURN)
                    selections="$selections $package"
                    done=True
                    ;;
            esac
        done
        IFS="$OLDIFS"
    done

    if [ ! -z "$done" ]; then
        if [ ! -z "$selections" ]; then
            echo apt-get install $selections
        fi
    fi
}
