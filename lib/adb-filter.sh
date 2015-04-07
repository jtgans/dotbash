#!/bin/bash

function adb-filter-save()
{
    (
        echo "_ADB_FILTER=("
        for i in "${_ADB_FILTER[@]}"; do
            echo "    \"$i\""
        done
        echo ")"
    ) > $_BASH_ETC/adb-filter
}

function adb-filter-load()
{
    if [[ -f $_BASH_ETC/adb-filter ]]; then
        source $_BASH_ETC/adb-filter
    fi
}

function adb-filter-add()
{
    adb-filter-load
    _ADB_FILTER+=("$@")
    adb-filter-save
    
    return 0
}

function adb-filter-remove()
{
    echo "To be implemented."
    return 1
}

function adb-filter-construct-regexp()
{
    adb-filter-load
    set -- "${_ADB_FILTER[@]}"

    echo -n "^./("
    while true; do
        echo -n $1
        shift

        if [[ ! -z $1 ]]; then
            echo -n "|"
        else
            break
        fi
    done
    echo ")"
}

function adb-filter()
{
    local regexp=$(adb-filter-construct-regexp)
    grep -vE "$regexp"
}
