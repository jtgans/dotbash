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

require hooks
require pidofuser

export ssh_pre_hooks=""
export ssh_post_hooks=""
export ssh_exec_args=""

function ssh-hook-alter-ssh-args()
{
    ssh_exec_args="$@"
}

function ssh-hook-get-args()
{
    echo $ssh_exec_args
}

function ssh()
{
    local remotehost
    local returncode
    local args=$(getopt \
        -o 1246AaCfgKkMNnqsTtVvXxYb:c:D:e:F:i:L:l:m:O:o:p:R:S:w: \
        -n ssh -- "$@")

    eval set -- "$args"

    ssh_exec_args=""

    while true; do
        case "$1" in
            -[bcDeFiLlmOopRSw])
                ssh_exec_args="$ssh_exec_args $1 $2"
                shift 2
                ;;

            --)
                shift
                break
                ;;

            *)
                ssh_exec_args="$ssh_exec_args $1"
                shift
                ;;
        esac
    done

    remotehost=$1

    if in-string remotehost '@'; then
        remotehost=$(echo $remotehost |sed 's/.*@//')
    fi

    run-hooks ssh_pre_hooks $remotehost
    debug-p && echo /usr/bin/ssh $ssh_exec_args $@
	/usr/bin/ssh $ssh_exec_args $@
    return_code=$?
    run-hooks ssh_post_hooks $remotehost

    ssh_exec_args=""

    return $return_code
}

function ssh-agent() {
    local ssh_agent=$(which ssh-agent)
    local ssh_add=$(which ssh-add)
    local ssh_agent_script

    if is-interactive; then
        return 0
    fi

    if [ -z "$ssh_agent" ]; then
        echo "ssh-agent not available."
	return 1
    fi

    if [ -f $HOME/.ssh_agent ] && [ ! -z "$(pidofuser ssh-agent $USER)" ]; then
        ssh_agent_script=$(cat $HOME/.ssh_agent)
	eval $ssh_agent_script
	return 0
    fi

    ssh_agent_script=$($ssh_agent)
    eval $ssh_agent_script
    echo "${ssh_agent_script}" > $HOME/.ssh_agent
    chmod 0600 $HOME/.ssh_agent

    if [ -z "$SSH_CLIENT" ]; then
        $ssh_add -l >/dev/null
        if [ "$?" != "0" ]; then
            $ssh_add
        fi
    fi

    return 0
}

