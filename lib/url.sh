#!/bin/bash

#  ,-- Protocol
#  |        ,-- User
#  |        |       ,-- Host
#  |        |       |       ,-- Path
#  |        |       |       |         ,-- Anchor
#  |        |       |       |         |
# http ://        foo.com
# http ://        foo.com /bar
# http ://        foo.com /bar/baz
# http ://        foo.com /bar/baz # bonk
# http :// zonk @ foo.com /bar/baz # bonk

# :// @ / #

require string

function url-split()
{
    local url=$1
    local protocol
    local user
    local host
    local path
    local anchor

    url=$(echo $url |sed -e 's|://|\t|')   # protocol userhostpathanchor
    protocol=$(echo $url |awk '{ print $1 }')
    url=$(echo $url |awk '{ print $2 }')   # userhostpathanchor
    
    if in-string url '@'; then
        url=$(echo $url |sed -e 's|@|\t|')    # user hostpathanchor
        user=$(echo $url |awk '{ print $1 }')
        url=$(echo $url |awk '{ print $2 }')  # hostpathanchor
    fi

    if in-string url '#'; then
        url=$(echo $url |sed -e 's|#|\t|')    # hostpath anchor
        anchor=$(echo $url |awk '{ print $2 }')
        url=$(echo $url |awk '{ print $1 }')  # hostpath
    fi

    if in-string url '/'; then
        url=$(echo $url |sed -e 's|/|\t/|')   # host path
        host=$(echo $url |awk '{ print $1 }')
        path=$(echo $url |awk '{ print $2 }')
    else
        host=$url
        path="/"
    fi

    echo -e "$protocol\t$user\t$host\t$path\t$anchor"
}

function valid-url()
{
    local url=$1
    local protocol=$(url-protocol $url)
    local host=$(url-host $url)

    if [ -z $protocol ]; then
        return 1
    fi

    if [ -z $host ]; then
        return 1
    fi

    return 0
}

function url-protocol()
{
    url-split $1 |cut -f1
}

function url-user()
{
    url-split $1 |cut -f2
}

function url-host()
{
    url-split $1 |cut -f3
}

function url-path()
{
    url-split $1 |cut -f4
}

function url-anchor()
{
    url-split $1 |cut -f5
}
