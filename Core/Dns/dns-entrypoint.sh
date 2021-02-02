#!/bin/sh

# Make our stuff available
source "${CORE_SCRIPT_DIR}"/common-functions.sh
add_path "${CORE_SCRIPT_DIR}"

log "Looking up the IP address for Consul to set as Consul domain owner"
export CONSUL_IP=$(get_ip_from_name "consul.service.consul")
export CONSUL_HTTP_ADDR=http://${CONSUL_IP}:8500

log_detail "merging expanded variables and updating configuration based on Consul cluster deployment"
cat /etc/templates/1.consul.conf | envsubst > /etc/templates/1.consul-template.conf
run_consul_template /etc/templates/1.consul-template.conf 1.consul.conf /etc/dnsmasq/1.consul.conf "consul lock -http-addr=${CONSUL_HTTP_ADDR} -name=service/dnsmasq -shell=false restart killall dnsmasq"

# Get Docker/Node/Hosting information from the Docker API for use in configuration
hosting_details
log "-----------------------------------------------------------"
log "- DNS Details"
log "-----------------------------------------------------------"
log_detail "${CONSUL_DOMAIN} domain downstream DNS: ${CONSUL_IP}"
log_detail "Consul HTTP Address: ${CONSUL_HTTP_ADDR}"

dnsmasq --no-daemon --log-queries --server=/consul/${CONSUL_IP}#8600
