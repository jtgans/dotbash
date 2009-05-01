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
require url

function project-set-prompt()
{
    local project_name=$1
    local reset=$(term-reset-color)
    local color=$(term-set-attrib bright; term-set-fg 6)

    export PS1="[\\[${reset}${color}\\]${project_name}\\[${reset}\\]] ${PS1}"
}

function project-set-dir()
{
    local project_dir=$1

    pushd $project_dir >/dev/null
}

function project-reset-dir()
{
    while expr $(dirs -v |wc -l) - 1 > /dev/null; do
        popd >/dev/null
    done
}

function project-cd()
{
    local dir="$@"

    if [ "$dir" == "~~" ] || [ "$dir" == "" ]; then
        if [ ! -z $_PROJECT_DIR ]; then
            builtin cd $_PROJECT_DIR
        else
            echo "$0: no project set."
        fi
    else
        builtin cd "$@"
    fi
}

function project()
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

        if [ "$_ALT_SHELL" != "" ]; then
            $_ALT_SHELL
        else
            $SHELL
        fi

        project-reset-dir
        ${_PROJECT}-project-post-hook
        
        remove-hook _INIT_POST_HOOKS ${_PROJECT}-project-init-hook
        remove-hook _INIT_POST_HOOKS project-init-hook
        unset _PROJECT
        unset _PROJECT_DIR
        unset _ALT_SHELL
    else
        echo "No such project $project_name."
        return 1
    fi
}

function edit-project()
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

function list-projects()
{
    for i in $_BASH_ETC/projects/*; do
        if [ -f $i ]; then
            echo $(basename $i)
        fi
    done
}

function rm-project()
{
    local project_name=$1

    if [ -z "$project_name" ]; then
        echo "Usage: rm-project <project_name>"
    else
        if [ ! -f $_BASH_ETC/projects/$project_name ]; then
            echo "No such project $project_name."
            return 1
        fi

        source $_BASH_ETC/projects/$project_name
        
        if [ -d $_PROJECT_DIR ]; then
            rm -rf $_PROJECT_DIR
        fi

        rm $_BASH_ETC/projects/$project_name

        unset _PROJECT_DIR
    fi
}

function new-project()
{
    local project_name
    local template
    local scm_type
    local scm_url
    local directory
    local no_editor
    local usage="Usage: new-project <project_name> [-n] [-d <dir>] [-t <template>] [[-s <scm>] [-u <url>]]"
    local args=$(getopt \
        -o hnd:t:s:u:                   \
        --long help,template:,scm:,url: \
        -n new-project -- "$@")

    eval set -- "$args"

    while true; do
        case "$1" in
            -h|--help)
                echo $usage
                return 1
                ;;

            -d|--directory)
                directory="$2"
                shift 2
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

            -n|--no-editor)
                no_editor=1
                shift
                ;;

            --)
                shift
                break
                ;;
        esac
    done

    project_name=$1

    if [ -z "$project_name" ]; then
        echo $usage
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
        | sed "s/@PROJECT@/$project_name/g"              \
        > $_BASH_ETC/projects/$project_name

    if [ ! -z $directory ]; then
        cat $_BASH_ETC/projects/$project_name                   \
            | sed "s/^_PROJECT_DIR=.*/_PROJECT_DIR=$directory/" \
            > $_BASH_ETC/projects/$project_name.tmp
        mv $_BASH_ETC/projects/$project_name.tmp $_BASH_ETC/projects/$project_name
    fi

    project-editor-hook $project_name
    if [ -z $no_editor ]; then
        $EDITOR $_BASH_ETC/projects/$project_name

        if [ "$?" != "0" ]; then
            echo "new-project: editor returned nonzero -- aborting build."
            rm $_BASH_ETC/projects/$project_name
            echo "new-project: some lingering files may have been left behind."
            return 1
        fi
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

function new-project-template()
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

function project-reset-hooks()
{
    eval 'project-pre-hook() { :; }'
    eval 'project-editor-hook() { :; }'
    eval 'project-pre-scm-hook() { :; }'
    eval 'project-post-scm-hook() { :; }'
    eval 'project-post-hook() { :; }'
}

function project-init-hook()
{
    if [ ! -z "$_PROJECT" ]; then
        source $_BASH_ETC/projects/$_PROJECT
    fi
}

if builtin complete >/dev/null 2>/dev/null; then
    function _project()
    {
        local cur=${COMP_WORDS[COMP_CWORD]}
        COMPREPLY=()
        if [ $COMP_CWORD -eq 1 ]; then
            COMPREPLY=( $(compgen -W "$(list-projects)" $cur) )
        fi
    }

    complete -F _project project
    complete -F _project rm-project
    complete -F _project edit-project
fi

function project-init-scm-git()
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

function project-init-scm-git-svn()
{
    local project_dir=$1
    local scm_url=$2
    
    project-set-dir $project_dir
    if [ -z "$scm_url" ]; then
        echo "new-project: initting from SVN requires an scm_url."
        return 1
    else
        git-svn clone $scm_url /tmp/new-project.$project_name.$$
        find /tmp/new-project.$project_name.$$ -mindepth 1 -maxdepth 1 -exec mv '{}' . ';'
        rmdir /tmp/new-project.$project_name.$$
    fi
    project-reset-dir
}

function project-init-scm-hg()
{
    local project_dir=$1
    local scm_url=$2

    project-set-dir $project_dir
    if [ -z "$scm_url" ]; then
        hg init
    else
        hg clone $scm_url /tmp/new-project.$project_name.$$
        find /tmp/new-project.$project_name.$$ -mindepth 1 -maxdepth 1 -exec mv '{}' . ';'
        rmdir /tmp/new-project.$project_name.$$
    fi
    project-reset-dir
}

function project-init-scm-tla()
{
    local project_dir=$1
    local scm_url=$(echo $2 |sed 's/#/ /' |awk '{ print $1; }')
    local tla_branch=$(echo $2 |sed 's/#/ /' |awk '{ print $2; }')
    local archive_name=$(tla archives |grep -B1 $scm_url |head -1)

    project-set-dir $project_dir
    if [ -z "$scm_url" ]; then
        tla init-tree $project_name--main--0
    else
        if [ ! -z "$archive_name" ]; then
            echo "$scm_url already registered as $archive_name"
        else
            result=$(tla register-archive $scm_url)

            if [ "$?" != "0" ]; then
                echo "Unable to register $scm_url. Aborting."
                return 1
            fi

            archive_name=$(tla archives |grep -B1 $scm_url |head -1)
            echo "$scm_url registered as $archive_name"
        fi

        if [ ! -z "$tla_branch" ]; then
            tla get -A $archive_name $tla_branch /tmp/new-project.$project_name.$$

            if [ "$?" != "0" ]; then
                echo "Unable to get $tla_branch from $archive_name. Aborting."
                return 1
            fi

            find /tmp/new-project.$project_name.$$ -mindepth 1 -maxdepth 1 -exec mv '{}' . ';'
            rmdir /tmp/new-project.$project_name.$$
        else
            echo "No branch specified to 'get', so not getting."
        fi
    fi
    project-reset-dir
}

function project-init-scm-svn()
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

function project-init-scm-cvs()
{
    local project_dir=$1
    local scm_url=$2
    local method=$(url-protocol $scm_url)
    local host=$(url-host $scm_url)
    local path=$(url-path $scm_url)
    local user=$(url-user $scm_url)
    local module=$(url-anchor $scm_url)
    local hostpart

    project-set-dir $project_dir
    if [ -z "$scm_url" ]; then
        echo "new-project: initting from CVS requires an scm_url."
        return 1
    else
        if [ ! -z $user ]; then
            hostpart="$user@$host"
        else
            hostpart=$host
        fi

        mkdir -p /tmp/new-project.$project_name.$$
        pushd /tmp/new-project.$project_name.$$ >/dev/null
        cvs -z3 -d:$method:$hostpart:$path co $module
        
        if [ "$?" != "0" ]; then
            echo "Unable to get $module from $scm_url. Aborting."
            return 1
        fi

        popd >/dev/null

        find /tmp/new-project.$project_name.$$/$module \
            -mindepth 1 -maxdepth 1 -exec mv '{}' . ';'
        rm -rf /tmp/new-project.$project_name.$$
    fi
    project-reset-dir
}
