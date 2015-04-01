#!/bin/bash

# DSL:
#
#   ref [in <project>]
#       [lang <language>]
#       [regex <regex>]
#       [nocase]
#       [bin]
#       [linenums]

function ref-join()
{
    local separator="$1"; shift
    local -a args=($@)
    local regex="$(printf -- "${separator}%s" "${args[@]}")"
    regex="${regex:${#separator}}"
    echo "${regex}"
}

function ref-usage() {
    cat >/dev/stderr <<EOF
Usage: ref [lang [(c|c++|objc|java|make|proto|header),...]]
           [regex {extended regular expression (as in grep -E)}]
           [nocase] [linenums] [bin] [filesonly] [forcecolor]
EOF
}

function ref-ref() {
    local lang regex
    local -a grep_opts=(--color --binary-file=without-match)

    if [[ -z $1 ]]; then
        ref-usage
        return 1
    fi

    for i; do
        case "$1" in
            lang)
                lang="$2"
                shift 2
                ;;

            regex)
                regex="$2"
                shift 2
                ;;

            nocase)
                grep_opts+=(-i)
                shift 1
                ;;

            linenums)
                grep_opts+=(-n)
                shift 1
                ;;

            bin)
                grep_opts+=(--binary-file=with-match)
                shift 1
                ;;
            
            filesonly)
                grep_opts+=(-l)
                shift 1
                ;;

            forcecolor)
                grep_opts+=(--color=yes)
                shift 1
                ;;

            '')
                break
                ;;

            *)
                ref-usage
                return 1
                ;;
        esac
    done

    local path_predicate="\
-not -path */.git/* \
-not -path */.hg/* \
-not -path */CVS/* \
-not -path */.arch/* \
"

    local extension_predicate=""
    if [[ ! -z $lang ]]; then
        local -a extensions=()
        local oldifs=$IFS
        local IFS=','

        for l in $lang; do
            case "$l" in
                header) extensions+=(\*.h)               ;;
                c)      extensions+=(\*.c)               ;;
                c++)    extensions+=(\*.c \*.cpp)        ;;
                objc)   extensions+=(\*.m \*.mm)         ;;
                java)   extensions+=(\*.java)            ;;
                make)   extensions+=(\*.mk Makefile)     ;;
                proto)  extensions+=(\*.proto \*.protos) ;;

                *)
                    ref-usage
                    return 1
                    ;;
            esac
        done

        IFS=$oldifs
        extension_predicate="-iname $(ref-join " -or -iname " "${extensions[@]}")"
    fi

    # FIXME: Don't use eval here.
    if [[ ! -z $regex ]]; then
        find . \
             -type f \
             -and \( $path_predicate \) \
             -and \( $extension_predicate \) \
             -exec grep ${grep_opts[@]} -E "$regex" '{}' +
    else
        find . \
             -type f \
             -and \( $path_predicate \) \
             -and \( $extension_predicate \) \
             -print
    fi
}

alias ref='ref-ref'
