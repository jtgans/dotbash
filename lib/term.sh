# -*- sh -*-

function term-clear-to-eol()
{
    (tput ce || tput el) 2>/dev/null
}

function term-clear-line()
{
	echo -ne '\r'
    term-clear-to-eol
}

function term-move-cursor()
{
	local dir=$1
	local dist=$2
	local cmd=""

	[ -z "$dist" ] && dist=1

	case $dir in
		up)	    cmd=$(tput up)	;;
		down)	cmd=$(tput do)	;;
		left)	cmd=$(tput le)	;;
		right)	cmd=$(tput nd)	;;
		*)	return 1 ;;
	esac

	for i in $(seq $dist); do
		echo -n $cmd
	done

	return 0
}

function term-reset-color()
{
    tput sgr0
}

function term-set-color()
{
    local fg=$1; shift
    local bg=$1; shift

    term-set-fg $fg
    term-set-bg $bg
}

function term-set-fg()
{
    local fg=$1

    tput setaf "${fg}"
}

function term-set-bg()
{
    local bg=$1

    tput setab "${bg}"
}

function term-set-attrib()
{
    local attrib=$1

    case "$attrib" in
        reset)      tput sgr0 ;;
        bright)     (tput md || tput bold) 2>/dev/null;;
        dim)        tput mh ;;
        underscore) tput us ;;
        blink)      tput mb ;;
        reverse)    tput mr ;;
        hidden)     tput mk ;;
        *)          return 0 ;;
    esac
}

function term-show-colors()
{
    local maxcolor=$(($(tput colors) + 1))
    local basemaxcolor=$maxcolor
    local maxcolorlen=$(($(echo $maxcolor |wc -c) - 1))
    local i=0
    local j=0

    [[ $basemaxcolor -ge 16 ]] && basemaxcolor=16

    while [ $i -lt $basemaxcolor ]; do
        while [ $j -lt $basemaxcolor ]; do
            term-reset-color
            term-set-color $i $j
            printf "%2d %2d" $i $j
            term-reset-color

            echo -ne " "

            j=$((j + 1))
        done

        echo

        i=$((i + 1))
        j=0
    done

    if [[ $maxcolor -ge 256 ]]; then
        echo

        while [[ $i -lt $maxcolor ]]; do
            term-reset-color
            term-set-color 0 $i
            printf "%${maxcolorlen}d" $i
            term-reset-color

            if [[ $((($i - 15) % 24)) -eq 0 ]]; then
                echo
            else
                echo -n ' '
            fi

            i=$((i + 1))
        done

        echo
    fi
}
