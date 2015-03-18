# -*- sh -*-

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
