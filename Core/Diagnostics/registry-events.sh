#!/bin/sh

# Generate DnsMasq configuration template using values from Consul,
# but do not reload because DnsMasq has't started yet
onStart() {
    consul-template \
        -once \
        -consul localhost:8500 \
        -template "/tmp/dnsmasq.conf:/etc/dnsmasq/em.conf"
}

# Generate DnsMasq configuration template using values from Consul,
# then gracefully reload DnsMasq
onChange() {
    consul-template \
        -once \
        -consul localhost:8500 \
        -template "/tmp/dnsmasq.conf:/etc/dnsmasq/em.conf: lock -name=service/dns -shell=false restart killall dnsmasq"
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
