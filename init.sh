# -*- sh -*-

function init-msg()
{
    local error_msg=$1; shift

    if is-interactive; then
        echo -e '\007'
        echo "bash-init: $error_msg"
    fi
}

function get-by-varname()
{
    local var_name=$1
    echo ${!var_name}
}

function set-by-varname()
{
    local var_name=$1
    shift
    local var_value="$*"

    if [ -z "$var_value" ]; then
        unset $var_name
    else
        export $var_name="$var_value"
    fi
}

function source-dir()
{
    local dir=$1; shift


    for i in $(find $dir -name \*.sh); do
        local libname=$(basename $i |sed 's/\.sh$//')

        is-interactive && echo -n "Loading library: "
        is-interactive && echo -n $libname

        if require $libname; then
            is-interactive && term-clear-line
        else
            is-interactive && echo -e " ... failed"
        fi
    done
}

function is-defined()
{
    if declare \
        |grep -ve "^[{} ]"                         \
        |sed -e 's/=.*//' -e 's/()//' -e 's/ *$//' \
        |grep -qe "^$1$"; then
        return 0
    else
        return 1
    fi
}

function function-p()
{
    if declare -f |grep -e '^.* ()' |grep -qe "^$1 ()"; then
        return 0
    else
        return 1
    fi
}

function is-interactive()
{
    if [ ! -z "${_INTERACTIVE}" ]; then
        return 0
    else
        return 1
    fi
}

function debug-p()
{
    is-defined _DEBUG_MODE
}

function set-debug-mode()
{
    export _DEBUG_MODE=t
}

function clear-debug-mode()
{
    unset _DEBUG_MODE
}

export _SYSTEM=$(uname -s |tr '[A-Z]' '[a-z]')
export _HOSTNAME=$(hostname |sed 's/\..*//')
export _BASH_LIB=${HOME}/.bash.d/lib
export _BASH_SYS=${HOME}/.bash.d/sys
export _BASH_ETC=${HOME}/.bash.d/etc
export _SDKS_DIR=${HOME}/SDKs
export _INTERACTIVE=$([ "$PS1" != "" ] && echo true)
set +u

# Setup our libraries
source ${_BASH_LIB}/require.sh
require term
source-dir ${_BASH_LIB}

# Load the common system config
source ${_BASH_SYS}/common.sh

# Load the specific system config
if [ -f ${_BASH_SYS}/${_SYSTEM}.sh ]; then
    source ${_BASH_SYS}/${_SYSTEM}.sh
else
    init-msg "warning: No system-specific configuration detected."
fi

require hooks
run-hooks _INIT_POST_HOOKS
