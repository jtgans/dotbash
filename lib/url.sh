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

url-split()
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

valid-url()
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

url-protocol()
{
    url-split $1 |cut -f1
}

url-user()
{
    url-split $1 |cut -f2
}

url-host()
{
    url-split $1 |cut -f3
}

url-path()
{
    url-split $1 |cut -f4
}

url-anchor()
{
    url-split $1 |cut -f5
}
