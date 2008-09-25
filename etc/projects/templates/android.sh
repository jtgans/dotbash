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

project-pre-hook()
{
    local project_name=$1

    : do nothing
}

project-editor-hook()
{
    local project_name=$1

    : do nothing
}

project-pre-scm-hook()
{
    local project_name=$1
    local project_dir=$2
    local scm_type=$3
    local scm_url=$4

    mkdir -p $project_dir
}

project-post-scm-hook()
{
    local project_name=$1
    local project_dir=$2
    local scm_type=$3
    local scm_url=$4

    : do nothing
}

project-post-hook()
{
    local project_name=$1

    if [ -z "$(\ls)" ]; then
        $_SDKS_DIR/android/tools/activitycreator --out $project_dir com.theonelab.$project_name.Main
    fi
}
