#!/bin/sh

# Make our stuff available
# shellcheck source=./common-functions.sh
. "${CORE_SCRIPT_DIR}"/common-functions.sh
add_path "${CORE_SCRIPT_DIR}"

# Set static IP
set_static_ip

# Get Docker/Node/Hosting information from the Docker API for use in configuration
hosting_details
get_consul_ip

log_detail "merging expanded variables and updating configuration based on Consul cluster deployment"
# get_consul_kv config/dns | envsubst > /etc/templates/1.consul-template.conf
envsubst < /etc/templates/1.consul.conf > /etc/templates/1.consul-template.conf
run_consul_template /etc/templates/1.consul-template.conf 1.consul.conf /etc/dnsmasq/1.consul.conf "consul lock -http-addr=${CONSUL_HTTP_ADDR} -name=service/dns -shell=false restart killall dnsmasq"

# add_consul_service dns 53 "\"dns\"" SERVICE_ID
dnsmasq --no-daemon --log-queries --server=/consul/"${CONSUL_IP}#8600"
# remove_consul_service "$SERVICE_ID"
