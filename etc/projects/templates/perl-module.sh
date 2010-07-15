#!/bin/bash
#
# Copyright (C) 2010  June Tate-Gans, All Rights Reserved.
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

project-pre-hook()
{
    local project_name=$1

    : do nothing
}

project-editor-hook()
{
    local project_name=$1
    local module_name=$(echo $project_name |sed 's/-\([A-Z]\)/::\1/g')

    sed -e "s/@MODULE@/$module_name/g" $_BASH_ETC/projects/$project_name -i
}

project-pre-scm-hook()
{
    local project_name=$1
    local project_dir=$2
    local scm_type=$3
    local scm_url=$4

    module-starter               \
        --module="$_MODULE_NAME" \
        --dir="$project_dir"     \
        --author="$_AUTHOR_NAME" \
        --email="$_AUTHOR_EMAIL"
}

project-post-scm-hook()
{
    local project_name=$1
    local project_dir=$(basename $2)
    local scm_type=$3
    local scm_url=$4

    : do nothing
}

project-post-hook()
{
    local project_name=$1

    : do nothing
}
