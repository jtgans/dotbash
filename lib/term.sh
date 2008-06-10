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

term-clear-to-eol()
{
	echo -ne '\e[K'
}

term-clear-line()
{
	echo -ne '\r\e[K'
}

term-move-cursor()
{
	local dir=$1
	local dist=$2
	local cmd=""

	[ -z "$dist" ] && dist=1

	case $dir in
		up)	cmd=$(echo -ne '\e[1A')	;;
		down)	cmd=$(echo -ne '\e[1B')	;;
		left)	cmd=$(echo -ne '\e[1C')	;;
		right)	cmd=$(echo -ne '\e[1D')	;;
		*)	return 1 ;;
	esac

	for i in $(seq $dist); do
		echo -n $cmd
	done

	return 0
}

term-save-state()
{
	echo -ne '\e7'
}

term-restore-state()
{
	echo -ne '\e8'
}

term-reset-color()
{
    echo -ne '\e[m'
}

term-set-color()
{
    local fg=$1
    local bg=$2

    echo -ne "\\e[${fg}${bg}m"
}

term-show-colors()
{
    local i=0
    local j=0

    while [ $i -lt 10 ]; do
        while [ $j -lt 10 ]; do
            term-reset-color
            term-set-color $i $j
            echo -n "$i $j"
            term-reset-color

            echo -ne "\t"

            j=$((j + 1))
        done

        echo

        i=$((i + 1))
        j=0
    done
}
