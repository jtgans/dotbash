# -*- sh -*-

function gvman()
{
    local manpage=$1
    local tempfile=$(mktemp -t gvman.XXXXXXXX)
    local man_exit_code=0

    man -Tps $manpage > $tempfile
    man_exit_code=$?

    if [ "$man_exit_code" == "0" ]; then
        gv --spartan $tempfile
    fi

    rm $tempfile
    return $man_exit_code
}
