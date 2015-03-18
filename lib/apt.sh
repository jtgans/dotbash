# -*- sh -*-

function apt-select()
{
    local selections
    local result
    local key
    local arg
    local done
    local search_terms="$@"

    while [ -z "$done" ]; do
        result=$(apt-cache search "$search_terms" | 
            iselect -eamK \
            -kj:KEY_DOWN \
            -kk:KEY_UP   \
            -kn:KEY_DOWN \
            -kp:KEY_UP   \
            -ki:RETURN   \
            -n "apt-select" \
            -t "$search_terms")
        [ -z "$result" ] && return 1

        OLDIFS="$IFS"
        IFS=$'\n'
        for line in $result; do
            key=$(echo $line |sed 's/:.*$//')
            arg=$(echo $line |sed 's/^[^:]*://')
            package=$(echo $arg |sed 's/ -.*$//')

            case $key in
                i)
                    apt-cache show $package |less -+E -+F -c
                    ;;

                RETURN)
                    selections="$selections $package"
                    done=True
                    ;;
            esac
        done
        IFS="$OLDIFS"
    done

    if [ ! -z "$done" ]; then
        if [ ! -z "$selections" ]; then
            echo apt-get install $selections
        fi
    fi
}
