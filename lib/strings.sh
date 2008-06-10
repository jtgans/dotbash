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

in-string()
{
	local string=$(get-by-varname $1)
	local substring=$2

	if [ ! -z "$(echo $string |grep $substring)" ]; then
		return 0
	else
		return 1
	fi
}

push-word()
{
	local string_name=$1
	local string_val=$(get-by-varname $string_name)
	shift
	local str_to_add="$*"

	if ! in-string $string_name $str_to_add; then
		set-by-varname $string_name "$string_val $str_to_add"
		return 0
	else
		return 1
	fi
}

pop-word()
{
	local string_name=$1
	local string_val=$(get-by-varname $string_name)
	local str_to_pop=$2

	if [ ! -z "$str_to_pop" ]; then
		if in-string $string_name $str_to_pop; then
			local new_str=$(echo $string_val |sed -e "s/$str_to_pop//g" -e "s/  / /g")
			set-by-varname $string_name "$new_str"
			return 0
		else
			return 1
		fi
	else
		local popped_element=$(echo $string_val |sed -e 's/^.* \(.*\)$/\1/')
		local rest=$(echo $string_val |sed -e 's/ [^ ]*$//')

		set-by-varname $string_name "$rest"
		echo $popped_element
		return 0
	fi
}

