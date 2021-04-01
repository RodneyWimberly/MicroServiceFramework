#!/bin/sh
# shellcheck source=./core-functions.sh
. /usr/local/scripts/core-functions.sh

preStart() {
    consul-template \
        -once \
        -consul-addr "${CONSUL_AGENT}" \
        -template "/etc/templates/1.consul-template.conf:/etc/dnsmasq/1.consul.conf"
}

onStart() {
    dnsmasq --no-daemon --log-queries --server=/consul/"${1}"
}

onHealth() {
    /usr/local/scripts/health-check.sh
}

onChange() {
    consul-template \
        -once \
        -consul-addr "${CONSUL_AGENT}" \
        -template "/etc/templates/1.consul-template.conf:/etc/dnsmasq/1.consul.conf:consul lock -http-addr=${CONSUL_HTTP_ADDR} -name=service/dns -shell=false restart killall dnsmasq"
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
