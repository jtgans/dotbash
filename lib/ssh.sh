#!/bin/bash
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

require "screen"

ssh()
{
    local ssh_args
    local remotehost
    local emacs_remote_port

    local emacs_server_file=$HOME/.emacs.d/server/server
    local args=$(getopt \
        -o 1246AaCfgKkMNnqsTtVvXxYb:c:D:e:F:i:L:l:m:O:o:p:R:S:w: \
        -n ssh -- "$@")

    eval set -- "$args"

    while true; do
        case "$1" in
            -[bcDeFiLlmOopRSw])
                ssh_args="$ssh_args $1 $2"
                shift 2
                ;;

            --)
                shift
                break
                ;;

            *)
                ssh_args="$ssh_args $1"
                shift
                ;;
        esac
    done

    remotehost=$1

    if in-string remotehost '@'; then
        remotehost=$(echo $remotehost |sed 's/.*@//')
    fi

    if [ -f $emacs_server_file ]; then
        emacs_remote_pid=$(cat $emacs_server_file \
            |head -1 |awk '{ print $2; }')
        emacs_remote_port=$(cat $emacs_server_file \
            |head -1 |sed 's/:/ /' |awk '{ print $2; }')
        emacs_remote_pw=$(cat $emacs_server_file \
            |tail -1)

        if kill -n 0 $emacs_remote_pid 2>/dev/null; then
            export EMACS_PASS=$emacs_remote_pw
            export EMACS_PORT=$emacs_remote_port

            ssh_args="$ssh_args -L${emacs_remote_port}:localhost:${emacs_remote_port}"
        fi
    fi

	screen-set-window-title ${remotehost}
	/usr/bin/ssh $ssh_args $@
	screen-set-window-title ${HOSTNAME}
}
