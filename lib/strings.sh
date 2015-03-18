# -*- sh -*-

function in-string()
{
	local string=$(get-by-varname $1)
	local substring=$2

	echo $string |grep -q "$substring"
    return $?
}

function push-word()
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

function pop-word()
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

