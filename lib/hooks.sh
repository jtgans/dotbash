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

run-hooks()
{
    local hooks=$(get-by-varname $1)
    local hook

    if [ ! -z "$hooks" ]; then
        for hook in $hooks; do
            $hook
        done
    fi
}

add-hook()
{
    local hooks_varname=$1
    local hooks=$(get-by-varname $hooks_varname)
    local hook_name=$2

    push-word hooks $hook_name
    set-by-varname $hooks_varname $hooks
}

remove-hook()
{
    local hooks_varname=$1
    local hooks=$(get-by-varname $1)
    local hook_to_remove=$2
    local hook
    local new_hooks

    for hook in $hooks; do
        if [ "$hook" != "$hook_to_remove" ]; then
            push-word $new_hooks $hook
        fi
    done

    set-by-varname $hooks_varname $new_hooks
}
