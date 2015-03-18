# -*- sh -*-

function telnets()
{
    local hostname=$1
    local port=$2

    if [ "$#" != "2" ]; then
        echo "Usage: telnets <hostname> <port>"
        return
    fi

    openssl s_client -host $hostname -port $port
}
