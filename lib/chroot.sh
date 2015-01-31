# -*- sh -*-
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

require term
require hooks

export _CHROOT_ROOT_PATH=$HOME/chroots
export _CHROOT_FILE=/.chroot
export _INSIDE_CHROOT=""

function chroot-init-hook()
{
    local reset=$(term-reset-color)
    local color=$(term-set-attrib bright; term-set-fg 3)

    if [ -z "$_INSIDE_CHROOT" ] && [ -f $_CHROOT_FILE ]; then
        _INSIDE_CHROOT=$(cat $_CHROOT_FILE)
    fi

    if [ ! -z "$_INSIDE_CHROOT" ]; then
        export PS1="[\\[${reset}${color}\\]${_INSIDE_CHROOT}\\[${reset}\\]] ${PS1}"
    fi
}

function switch-chroot()
{
    local chroot_name
    local chroot_path
    local home_dir
    local prefix_command
    local user_to_become=$USER
    local usage="Usage: switch-chroot <chroot_name> [-r] [-u <username>] [-c <prefix_command>]"
    local args=$(getopt hru:c: $*)
        
    set -- $args

    for i; do
        case "$1" in
            -h)  # help
                echo $usage
                return 1
                ;;

            -r)  # root
                user_to_become=root
                shift
                ;;
            
            -u)  # user
                user_to_become="$2"
                shift 2
                ;;

            -c)  # prefix_command
                prefix_command="$2"
                shift 2
                ;;
                
            --)
                shift
                break
                ;;
        esac
    done

    if [ ! -z "$_INSIDE_CHROOT" ]; then
        echo "ALREADY INSIDE A CHROOT!"
        return 1
    fi

    chroot_name=$1
    home_dir=$(getent passwd $user_to_become |awk -F: '{ print $6; }')

    if [ -z "$chroot_name" ]; then
        echo $usage
        return 1
    fi

    if [ -d $_CHROOT_ROOT_PATH/$chroot_name ]; then
        chroot_path=$_CHROOT_ROOT_PATH/$chroot_name
    else
        echo "chroot $chroot_name does not exist."
        return 1
    fi

    sync-chroot $chroot_name
    [ ! -d $chroot_path$home_dir ] && sudo mkdir -p $chroot_path$home_dir

    for dir in /proc /sys /dev /dev/pts $home_dir; do
        sudo mount --bind $dir $chroot_path$dir
    done

    push-word _INSIDE_CHROOT $chroot_name
    echo $_INSIDE_CHROOT | sudo tee $chroot_path$_CHROOT_FILE >/dev/null
    sudo $prefix_command chroot $chroot_path /bin/su -l -p $user_to_become
    pop-word _INSIDE_CHROOT $chroot_name
    echo $_INSIDE_CHROOT | sudo tee $chroot_path$_CHROOT_FILE >/dev/null

    for dir in $home_dir /dev/pts /dev /sys /proc; do
        sudo umount $chroot_path$dir
    done
}

function sync-chroot()
{
    local chroot_name=$1
    local chroot_path

    if [ -z "$chroot_name" ]; then
        echo "Usage: sync-chroot <chroot-name>"
        return 1
    fi

    if [ -d $_CHROOT_ROOT_PATH/$chroot_name ]; then
        chroot_path=$_CHROOT_ROOT_PATH/$chroot_name
    else
        echo "chroot $chroot_name does not exist."
        return 1
    fi

    sudo cp /etc/{passwd,shadow,group}   $chroot_path/etc
    sudo cp /etc/resolv.conf             $chroot_path/etc
    echo $(hostname)                     | sudo tee $chroot_path/etc/hostname >/dev/null
    echo 127.0.0.1 localhost $(hostname) | sudo tee $chroot_path/etc/hosts    >/dev/null
}

function list-chroots()
{
    for i in $_CHROOT_ROOT_PATH/*; do
        if [ -d $i ]; then
            echo $(basename $i)
        fi
    done
}

if builtin complete >/dev/null 2>/dev/null; then
    function _chroots()
    {
        local cur=${COMP_WORDS[COMP_CWORD]}
        COMPREPLY=()
        if [ $COMP_CWORD -eq 1 ]; then
            COMPREPLY=( $(compgen -W "$(list-chroots)" $cur) )
        fi
    }

    complete -F _chroots switch-chroot
    complete -F _chroots rm-chroot
fi

add-hook _INIT_POST_HOOKS chroot-init-hook
