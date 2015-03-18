# -*- sh -*-

export _IN_SCREEN=$([ ! -z "${WINDOW}" ] && echo true)

function in-screen()
{
	if [ ! -z "${_IN_SCREEN}" ]; then
		return 0
	else
		return 1
	fi
}

function screen-set-window-title()
{
	if in-screen; then
		echo -ne "\\ek$@\\e\\\\"
	fi
}

function screen-ssh-pre-hook()
{
    local remotehost=$1
    
    if in-screen; then
        screen-set-window-title $remotehost
    fi
}

function screen-ssh-post-hook()
{
    if in-screen; then
        screen-set-window-title $HOSTNAME
    fi
}
