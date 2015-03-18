# -*- sh -*-

function proxycmd()
{
    local proxy_user;
    local proxy_pass;
    
    read -p "User: " proxy_user;
    read -sp "Password: " proxy_pass; 
    echo;
    
    export http_proxy="http://$proxy_user:$proxy_pass@corp-hts-proxy.mhc.:8080";
    export RSYNC_PROXY="http://$proxy_user:$proxy_pass@corp-hts-proxy.mhc.:8080";
    
    $@;
    
    export http_proxy="";
    export RSYNC_PROXY="";
}

