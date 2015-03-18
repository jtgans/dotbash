# -*- sh -*-

function run-hooks()
{
    local hooks=$(get-by-varname $1)
    local hook
    shift

    if [ ! -z "$hooks" ]; then
        for hook in $hooks; do
            if debug-p; then
                echo "Running $hook"
            fi

            $hook "$@"
        done
    fi
}

function add-hook()
{
    local hooks_varname=$1
    local hooks=$(get-by-varname $hooks_varname)
    local hook_name=$2

    push-word hooks $hook_name
    set-by-varname $hooks_varname $hooks
}

function remove-hook()
{
    local hooks_varname=$1
    local hooks=$(get-by-varname $1)
    local hook_to_remove=$2
    local hook
    local new_hooks

    for hook in $hooks; do
        if [ "$hook" != "$hook_to_remove" ]; then
            push-word $new_hooks $hook
        fi
    done

    set-by-varname $hooks_varname $new_hooks
}
