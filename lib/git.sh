#!/bin/bash

function git-get-status() {
    git status -b --porcelain 2>/dev/null |head -n1
}

function git-extract-branch() {
    local branch="$2"
    echo $branch |sed 's/\.\.\..*//'
}

function git-extract-remote-branch() {
    local branch="$2"
    echo $branch |sed 's/.*\.\.\.//'
}

function git-extract-ahead-behind() {
    local aheadbehind="$3 $4"
    echo $aheadbehind |tr -d '[]'
}

function git-is-dirty() {
    local status=$(git status --porcelain 2>/dev/null)

    if [[ ! -z $status ]]; then
        return 0
    else
        return 1
    fi
}
