#!/bin/sh
set -ex
consul-agent.sh --consul-template-file-cmd /consul/tmp/em.conf em.conf /etc/dnsmasq/em.conf "consul lock -name=service/dns -shell=false restart killall dnsmasq"
set +e
while true; do
    sleep 1
    CONSUL_IP="`dig +short registry-leader.service.em.local | tail -n1`"
    # add --log-queries for more verbosity
    dnsmasq --no-daemon --server=/em/"${CONSUL_IP}"#8600
done
