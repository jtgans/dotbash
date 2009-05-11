#!/bin/bash

function die()
{
    echo "$@"

    while popd 2>/dev/null >/dev/null; do
        echo "$COMMAND_NAME: Leaving directory $(pwd)"
    done

    exit 1
}

function try()
{
    echo "$@"
    "$@"

    if [ "$?" != "0" ]; then
        die "$COMMAND_NAME: Command failed: exit code $?"
    fi
}

function in-dir()
{
    local dir=$1
    shift

    echo "$COMMAND_NAME: Entering directory $dir"
    pushd $dir 2>/dev/null >/dev/null || die "$COMMAND_NAME: $dir does not exist."
    "$@"
    popd 2>/dev/null >/dev/null
    echo "$COMMAND_NAME: Leaving directory $dir"
}

function require-command()
{
    local command=$1
    shift

    if [ -z $(which $command) ]; then
        die "$@"
    fi
}

function setup-dirs()
{
    try ln -s /media/private Private
    try mkdir Documents Downloads Code Projects SDKs chroots www
}

function setup-repos()
{
    try git clone git://git.theonelab.com/dotemacs.git .emacs.d
    try git clone git://git.theonelab.com/dotbash.git .bash.d
    try git clone git://git.theonelab.com/dotfiles.git .dotfiles
}

function setup-links()
{
    try source .bash.d/setuplinks.sh
    try source .dotfiles/setuplinks.sh
}

require git "git not available."

in-dir $HOME setup-dirs
in-dir $HOME setup-repos
in-dir $HOME setup-links
