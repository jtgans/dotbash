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

require pidofuser
require ssh
require x

function daemonize-emacs()
{
    local pidof_emacs=$(pidofuser emacs)

    if [ -z "$pidof_emacs" ]; then
        echo -n "Daemonizing emacs: "
        $(which emacs) --daemon 2>&1 2>/dev/null

        if [ "$?" == "0" ]; then
            echo $(which emacs)
        else
            echo failed.
        fi
    fi

    return 0
}

function emacs()
{
    local server_file=$(mktemp .$USER.emacs.XXXXXXXXX)
    local result
    local args

    if [ ! -z "$ALT_EDITOR" ]; then
        args="$args -a $ALT_EDITOR"
    fi

    if [ ! -z "$EMACS_REMOTE_DATA" ]; then
        echo $EMACS_REMOTE_DATA \
            | awk '{ printf("%s %s\n%s", $1, $2, $3); }' \
            > $server_file
        args="$args -f /tmp/$server_file"
    fi

    if verify-x-display-live; then
        emacsclient $args -c "$@"
        debug-p && echo emacsclient $args -c "$@"
    else
        emacsclient $args -c -t "$@"
        debug-p && echo emacsclient $args -c -t "$@"
    fi

    result=$?
    rm -f $server_file

    return $result
}

function emacs-server-ssh-pre-hook()
{
    local remotehost=$1; shift
    local emacs_server_file=$HOME/.emacs.d/server/server
    local emacs_remote_port

    if [ -f $emacs_server_file ]; then
        emacs_remote_pid=$(cat $emacs_server_file \
            |head -1 |awk '{ print $2; }')
        emacs_remote_port=$(cat $emacs_server_file \
            |head -1 |sed 's/:/ /' |awk '{ print $2; }')

        if kill -n 0 $emacs_remote_pid 2>/dev/null; then
            export EMACS_REMOTE_DATA=$(cat $emacs_server_file)

            ssh-hook-alter-ssh-args \
                "$(ssh-hook-get-args)" \
                "-oSendEnv=EMACS_REMOTE_DATA" \
                "-L${emacs_remote_port}:localhost:${emacs_remote_port}"

            unset EMACS_REMOTE_DATA
        fi
    fi
}
