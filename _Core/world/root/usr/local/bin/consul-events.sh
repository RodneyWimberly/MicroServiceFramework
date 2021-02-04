#!/bin/sh

# Render Nginx configuration template using values from Consul,
# but do not reload because Nginx has't started yet
onStart() {
    consul-template \
        -once \
        -consul localhost:8500 \
        -template "/consul/tmp/em.conf:/etc/dnsmasq/em.conf"
}

# Render Nginx configuration template using values from Consul,
# then gracefully reload Nginx
onChange() {
    consul-template \
        -once \
        -consul localhost:8500 \
        -template "/consul/tmp/em.conf:/etc/dnsmasq/em.conf: lock -name=service/dns -shell=false restart killall dnsmasq"
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
