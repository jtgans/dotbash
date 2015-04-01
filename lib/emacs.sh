#!/bin/bash

function emacs:view-file() {
    local file="$1"

    emacsclient -e "(view-file \"$PWD/$file\")"
}

function emacs:find-file() {
    local file="$1"

    emacsclient -n $file
}

alias view-file="emacs:view-file"
alias find-file="emacs:find-file"
