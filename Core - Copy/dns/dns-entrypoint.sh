#!/bin/sh

# Make our stuff available
source "${CORE_SCRIPT_DIR}"/common-functions.sh
add_path "${CORE_SCRIPT_DIR}"

# Get Docker/Node/Hosting information from the Docker API for use in configuration
hosting_details
get_CONSUL_AGENT
# add_consul_service dns

log_detail "merging expanded variables and updating configuration based on Consul cluster deployment"
# get_consul_kv config/dns | envsubst > /etc/templates/1.consul-template.conf
# cat /etc/templates/1.consul.conf | envsubst > /etc/templates/1.consul-template.conf
# run_consul_template /etc/templates/1.consul-template.conf 1.consul.conf /etc/dnsmasq/1.consul.conf "consul lock -http-addr=http://consul.service.consul:8500 -name=service/dnsmasq -shell=false restart killall dnsmasq"

cat /etc/templates/1.consul.conf | envsubst > /etc/dnsmasq/1.consul.conf

# add_consul_service dns 53 "\"dns\""
dnsmasq --no-daemon --log-queries --server=/consul/169.254.1.1#8600
# remove_consul_service $SERVICE_ID
