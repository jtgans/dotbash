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

require term

project-set-prompt()
{
    local project_name=$1
    local reset=$(term-reset-color)
    local color=$(term-set-color 3 6)

    export PS1="[${reset}${color}${project_name}${reset}] ${PS1}"
}

project()
{
    local project_name=$1
    
    if [ "$project_name" == "" ]; then
        echo "Usage: project <project_name>"
        return 1
    fi

    if [ -f $_BASH_ETC/projects/$project_name ]; then
        export _PROJECT=$project_name
        source $_BASH_ETC/projects/$project_name

        run-hooks _PROJECT_PRE_HOOKS
        $SHELL
        run-hooks _PROJECT_POST_HOOKS
    else
        echo "No such project $project_name."
        return 1
    fi
}

new-project()
{
    local project_name=$1
    local template_script=$2

    if [ -z "$project_name" ]; then
        echo "Usage: new-project <project_name> [--template=<template_script>] [--from=<scm_url>|--in=<scm>]"
        return 1
    fi

    if [ ! -z "$template_script" ]; then
        template_script=base
    fi

    source $_BASH_ETC/projects/templates/$template_script.sh
    run-hooks _NEW_PROJECT_PRE_HOOKS

    cp $_BASH_ETC/projects/templates/$template_script.template \
        $_BASH_ETC/projects/$_PROJECT
    $EDITOR $_BASH_ETC/projects/$_PROJECT

    run-hooks _NEW_PROJECT_POST_HOOKS
}

project-init-hook()
{
    if [ ! -z "$_PROJECT" ]; then
        source $_BASH_ETC/projects/$_PROJECT
    fi
}

add-hook _INIT_POST_HOOKS project-init-hook
