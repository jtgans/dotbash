#!/bin/bash

function in-dir()
{
    local dir="$1"; shift
    local result=0

    pushd $dir >/dev/null
    "$@"
    result="$?"
    popd >/dev/null

    return $result
}
