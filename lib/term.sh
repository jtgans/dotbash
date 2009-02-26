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

function term-clear-to-eol()
{
	echo -ne '\e[K'
}

function term-clear-line()
{
	echo -ne '\r\e[K'
}

function term-move-cursor()
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

function term-save-state()
{
	echo -ne '\e7'
}

function term-restore-state()
{
	echo -ne '\e8'
}

function term-reset-color()
{
    echo -ne '\e[0m'
}

function term-set-fg()
{
    local fg=$1

    term-set-attribs "3${1}"
}

function term-set-bg()
{
    local bg=$1

    term-set-attribs "4${1}"
}

function term-set-attrib()
{
    local attrib=$1

    case "$attrib" in
        reset)      attrib=0 ;;
        bright)     attrib=1 ;;
        dim)        attrib=2 ;;
        underscore) attrib=4 ;;
        blink)      attrib=5 ;;
        reverse)    attrib=6 ;;
        hidden)     attrib=8 ;;
        *)          return 0 ;;
    esac

    term-set-attribs $attrib
}

function term-set-attribs()
{
    local attrib

    if [ "$#" == "0" ]; then
        return 0
    fi

    echo -ne "\\e["
    while [ "$#" != "0" ]; do
        attrib=$1; shift

        echo -ne $attrib
        [ "$#" != "0" ] && echo -ne ";"
    done
    echo -ne "m"
}

function term-show-colors()
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
