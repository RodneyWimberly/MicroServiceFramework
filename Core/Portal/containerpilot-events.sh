#!/bin/sh
# shellcheck source=./core-functions.sh
. /usr/local/scripts/core-functions.sh

preStart() {
    consul-template \
        -once \
        -consul-addr "${CONSUL_AGENT}" \
        -template "/etc/templates/nginx-template.conf:/etc/nginx/nginx.conf"
}

onStart() {
    nginx -g 'daemon off;'
}

onHealth() {
    /usr/local/scripts/health-check.sh
}

onChange() {
    consul-template \
        -once \
        -consul-addr "${CONSUL_AGENT}" \
        -template "/etc/templates/nginx-template.conf:/etc/nginx/nginx.conf:consul lock -http-addr=${CONSUL_HTTP_ADDR} -name service/portal -shell=false reload nginx -s reload"
}

until
    cmd=$1
    if [ -z "$cmd" ]; then
        onChange
    fi
    shift 1
    $cmd "$@"
    [ "$?" -ne 127 ]
do
    onChange
    exit
done
