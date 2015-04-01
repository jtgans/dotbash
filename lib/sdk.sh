#!/bin/bash

require strings
require project

add-hook project_post_hooks unuse-all-sdks

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

    if sdk-used $sdk_name; then
        echo "rm-sdk: SDK $sdk_name is currently used."
        return 1
    fi

    if [ -z "$sdk_name" ]; then
        echo $usage
        return 1
    fi

    rm $_BASH_ETC/sdks/$sdk_name
}

function sdk-used()
{
    local sdk_name=$1
    in-string _SDKS $sdk_name
}

function load-sdk()
{
    local sdk_name=$1
    local sdk_path="${_BASH_ETC}/sdks/${sdk_name}"

    source $sdk_path
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

    if ! sdk-used $sdk_name; then
        if load-sdk $sdk_name; then
            if eval "${sdk_name}-sdk-init-hook"; then
                push-word _SDKS $sdk_name
                return 0
            else
                echo "use-sdk: Unable to initialize SDK $sdk_name."
                return 1
            fi
        else
            echo "use-sdk: Unable to load SDK $sdk_name."
            return 1
        fi
    fi
}

function unuse-sdk()
{
    local sdk_name=$1
    local usage="Usage: unuse-sdk <sdk_name>"

    if [ -z "$sdk_name" ]; then
        echo $usage;
        return 1
    fi

    if [ ! -f $_BASH_ETC/sdks/$sdk_name ]; then
        echo "unuse-sdk: no such SDK $sdk_name."
        return 1
    fi

    if ! sdk-used $sdk_name; then
        echo "unuse-sdk: $sdk_name is not used."
        return 1
    fi

    if eval "${sdk_name}-sdk-shutdown-hook"; then
        pop-word _SDKS $sdk_name
        return 0
    else
        echo "unuse-sdk: Unable to shutdown SDK $sdk_name"
        return 1
    fi
}

function unuse-all-sdks()
{
    local cur_sdk

    while [[ ! -z $_SDKS ]]; do
        local sdk=$(pop-word _SDKS)

        if ! unuse-sdk $sdk; then
            echo "unuse-all-sdks: SDK $sdk failed to unload -- aborting."
            return 1
        fi
    done
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

function used-sdks()
{
    echo $_SDKS
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

    complete -F _sdk use-sdk
    complete -F _sdk rm-sdk
    complete -F _sdk edit-sdk
fi
