# -*- sh -*-

function pidofuser()
{
    local process_name=$1
    local userid=$2
    local ps_cmd
    local result

    if [ -z "$process_name" ]; then
        echo "Usage: pidofuser <process_name> [<username>]"
        return 1
    fi

    if [ ! -z "$userid" ]; then
        ps_cmd="ps -U $userid -u $userid u"
    else
        ps_cmd="ps -U $USER -u $USER u"
    fi

    result=$($ps_cmd \
        |grep -v "PID"               \
        |awk '{ print $2 " " $11; }' \
        |grep $process_name          \
        |awk '{ print $1 }')
    echo $result

    if [ -z "$result" ]; then
        return 1
    else
        return 0
    fi
}
