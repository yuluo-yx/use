function proxy
    set -Ux all_proxy http://127.0.0.1:7897
    set -Ux http_proxy http://127.0.0.1:7897
    set -Ux https_proxy http://127.0.0.1:7897ó
    echo all_proxy=$all_proxy
    echo http_proxy=$http_proxy
    echo https_proxy=$https_proxy
end

function noproxy
    set -e all_proxy
    set -e http_proxy
    set -e https_proxy
end

