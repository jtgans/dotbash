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

function featurep()
{
    local library=$1
    in-string _FEATURES $library
}

# require-featurep is deprecated -- use featurep instead.
alias require-featurep="featurep"

function load()
{
	local library=$1
	local library_path="${_BASH_LIB}/${library}.sh"

	source $library_path
}

function require()
{
	local library=$1

	if ! featurep $library; then
		if load $library; then
			push-word _FEATURES $library
			return 0
		else
			return 1
		fi
	fi
}

# Can't require strings since require isn't defined yet.
load strings

export _FEATURES="require strings"
