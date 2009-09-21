#!/bin/bash
#
# Copyright (C) 2009  June Tate-Gans, All Rights Reserved.
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

function new-sdk()
{
    local sdk_name=$1
    local usage="Usage: new-sdk <sdk_name>"

    if [ -z "$sdk_name" ]; then
        echo $usage
        return 1
    fi

    cat $_BASH_ETC/sdks/templates/base.template \
        | sed "s/@SDK@/$sdk_name/g"             \
        > $_BASH_ETC/sdks/$sdk_name

    $EDITOR $_BASH_ETC/sdks/$sdk_name
    
    if [ "$?" != "0" ]; then
        echo "new-sdk: editor returned nonzero -- aborting build."
        rm $_BASH_ETC/sdks/$sdk_name
        return 1
    fi
}

function rm-sdk()
{
    local sdk_name=$1
    local usage="Usage: rm-sdk <sdk_name>"

    if [ -z "$sdk_name" ]; then
        echo $usage
        return 1
    fi
}

function use-sdk()
{
    local sdk_name=$1
    local usage="Usage: use-sdk <sdk_name>"

    if [ -z "$sdk_name" ]; then
        echo $usage
        return 1
    fi

    if [ ! -f $_BASH_ETC/sdks/$sdk_name ]; then
        echo "use-sdk: no such SDK $sdk_name."
        return 1
    fi

    source $_BASH_ETC/sdks/$sdk_name
}

function edit-sdk()
{
    local sdk_name=$1
    local usage="Usage: edit-sdk <sdk_name>"

    if [ -z "$sdk_name" ]; then
        echo $usage
        return 1
    fi

    if [ -f $_BASH_ETC/sdks/$sdk_name ]; then
        $EDITOR $_BASH_ETC/sdks/$sdk_name
    else
        echo "No such SDK $sdk_name."
    fi
}

function list-sdks()
{
    for i in $_BASH_ETC/sdks/*; do
        if [ -f $i ]; then
            echo $(basename $i)
        fi
    done
}

if builtin complete >/dev/null 2>/dev/null; then
    function _sdk()
    {
        local cur=${COMP_WORDS[COMP_CWORD]}
        COMPREPLY=()
        if [ $COMP_CWORD -eq 1 ]; then
            COMPREPLY=( $(compgen -W "$(list-sdks)" $cur) )
        fi
    }

    complete -F _project use-sdk
    complete -F _project rm-sdk
    complete -F _project edit-sdk
fi
