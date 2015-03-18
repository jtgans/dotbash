# -*- sh -*-

function x-display-live()
{
    if [ ! -z "$DISPLAY" ]; then
        xdpyinfo >/dev/null 2>/dev/null

        if [ "$?" != "0" ]; then
            return 1
        else
            return 0
        fi
    fi
}

function verify-x-display-live()
{
    if ! x-display-live; then
        unset DISPLAY
    fi
}
