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
    local color=$(term-set-attrib bright; term-set-fg 6)

    export PS1="[\\[${reset}${color}\\]${project_name}\\[${reset}\\]] ${PS1}"
}

project-set-dir()
{
    local project_dir=$1

    pushd $project_dir >/dev/null
}

project-reset-dir()
{
    while expr $(dirs -v |wc -l) - 1 > /dev/null; do
        popd >/dev/null
    done
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
        add-hook _INIT_POST_HOOKS project-init-hook
        add-hook _INIT_POST_HOOKS ${_PROJECT}-project-init-hook

        ${_PROJECT}-project-pre-hook
        project-set-dir $_PROJECT_DIR
        $SHELL
        project-reset-dir
        ${_PROJECT}-project-post-hook
        
        remove-hook _INIT_POST_HOOKS ${_PROJECT}-project-init-hook
        remove-hook _INIT_POST_HOOKS project-init-hook
        unset _PROJECT
        unset _PROJECT_DIR
    else
        echo "No such project $project_name."
        return 1
    fi
}

edit-project()
{
    local project_name=$1

    if [ -z "$project_name" ]; then
        echo "Usage: edit-project <project_name>"
    else
        if [ -f $_BASH_ETC/projects/$project_name ]; then
            $EDITOR $_BASH_ETC/projects/$project_name
        else
            echo "No such project $project_name."
        fi
    fi
}

list-projects()
{
    for i in $_BASH_ETC/projects/*; do
        if [ -f $i ]; then
            echo $(basename $i)
        fi
    done
}

new-project()
{
    local project_name
    local template
    local scm_type
    local scm_url
    local args=$(getopt \
        -o ht:s:u:                      \
        --long help,template:,scm:,url: \
        -n new-project -- "$@")

    eval set -- "$args"

    while true; do
        case "$1" in
            -h|--help)
                echo "Usage: new-project <project_name> [-t <template>] [[-s <scm>] [-u <url>]]"
                return 1
                ;;

            -t|--template)
                template="$2"
                shift 2
                ;;

            -s|--scm)
                scm_type="$2"
                shift 2
                ;;

            -u|--url)
                if [ -z "$scm_type" ]; then
                    echo "new-project: SCM URL requires an SCM type."
                    return 1
                else
                    scm_url="$2"
                    shift 2
                fi
                ;;

            --)
                shift
                break
                ;;
        esac
    done

    project_name=$1

    if [ -z "$project_name" ]; then
        echo "Usage: new-project <project_name> [-t <template>] [[-s <scm>] [-u <url>]]"
        return 1
    fi

    if [ -z "$template" ]; then
        template=base
    fi

    if [ ! -f $_BASH_ETC/projects/templates/$template.template ]; then
        echo "new-project: template $template not found."
        return 1
    fi

    if [ ! -z "$scm_type" ]; then
        if ! function-p project-init-scm-${scm_type}; then
            echo "SCM not supported."
            return 1
        fi
    fi

    project-reset-hooks
    if [ -f $_BASH_ETC/projects/templates/$template.sh ]; then
        source $_BASH_ETC/projects/templates/$template.sh
    fi

    project-pre-hook $project_name
    cat $_BASH_ETC/projects/templates/$template.template \
        | sed s/@PROJECT@/$project_name/g                       \
        > $_BASH_ETC/projects/$project_name

    project-editor-hook $project_name
    $EDITOR $_BASH_ETC/projects/$project_name

    if [ "$?" != "0" ]; then
        echo "new-project: editor returned nonzero -- aborting build."
        rm $_BASH_ETC/projects/$project_name
        echo "new-project: some lingering files may have been left behind."
        return 1
    fi

    source $_BASH_ETC/projects/$project_name

    project-pre-scm-hook $project_name $_PROJECT_DIR $scm_type $scm_url
    if [ ! -z "$scm_type" ]; then
        project-init-scm-${scm_type} $_PROJECT_DIR $scm_url
    fi
    project-post-scm-hook $project_name $_PROJECT_DIR $scm_type $scm_url

    project-post-hook $project_name
    project-reset-hooks
}

new-project-template()
{
    local name=$1
    local base=$2

    if [ -z "$name" ]; then
        echo "Usage: new-project-template <template_name> [<base_name>]"
        return 1
    fi

    if [ -z "$base" ]; then
        base="base"
    fi

    if [ ! -f $_BASH_ETC/projects/templates/$base.template ]; then
        echo "No template by the name $base was found."
        return 1
    fi

    if [ -f $_BASH_ETC/projects/templates/$name.template ]; then
        echo "Template $name already exists."
        return 1
    fi

    cp $_BASH_ETC/projects/templates/$base.template $_BASH_ETC/projects/templates/$name.template
    cp $_BASH_ETC/projects/templates/$base.sh $_BASH_ETC/projects/templates/$name.sh

    $EDITOR \
        $_BASH_ETC/projects/templates/$name.template \
        $_BASH_ETC/projects/templates/$name.sh
}

project-reset-hooks()
{
    eval 'project-pre-hook() { :; }'
    eval 'project-editor-hook() { :; }'
    eval 'project-pre-scm-hook() { :; }'
    eval 'project-post-scm-hook() { :; }'
    eval 'project-post-hook() { :; }'
}

project-init-hook()
{
    if [ ! -z "$_PROJECT" ]; then
        source $_BASH_ETC/projects/$_PROJECT
    fi
}

project-init-scm-git()
{
    local project_dir=$1
    local scm_url=$2

    project-set-dir $project_dir
    if [ -z "$scm_url" ]; then
        git init
    else
        git clone $scm_url /tmp/new-project.$project_name.$$
        find /tmp/new-project.$project_name.$$ -mindepth 1 -maxdepth 1 -exec mv '{}' . ';'
        rmdir /tmp/new-project.$project_name.$$
    fi
    project-reset-dir
}

project-init-scm-svn()
{
    local project_dir=$1
    local scm_url=$2

    project-set-dir $project_dir
    if [ -z "$scm_url" ]; then
        echo "new-project: initting from SVN requires an scm_url."
        return 1
    else
        svn co $scm_url .
    fi
    project-reset-dir
}
