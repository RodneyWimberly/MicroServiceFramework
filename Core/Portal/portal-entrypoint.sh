#!/bin/sh

set -e

# Make our stuff available
source common-functions.sh
add_path "${CORE_SCRIPT_DIR}"

export CONSUL_IP=$(get_ip_from_name "consul.service.consul")
export CONSUL_HTTP_ADDR=http://${CONSUL_IP}:8500

# Get Docker/Node/Hosting information from the Docker API for use in configuration
hosting_details
log "-----------------------------------------------------------"
log "- Portal Details"
log "-----------------------------------------------------------"
log_detail "Consul Address: ${CONSUL_IP}"
log_detail "Consul HTTP Address: ${CONSUL_HTTP_ADDR}"

log_detail "merging expanded variables and updating configuration based on Consul cluster deployment"
cat /etc/templates/nginx.conf | envsubst > /etc/templates/nginx-template.conf
cat /etc/templates/index.html | envsubst > /etc/templates/index-template.html
run_consul_template /etc/templates/nginx-template.conf nginx.conf /etc/nginx/conf.d/default.conf "consul lock -name service/portal -shell=false reload nginx -s reload"
run_consul_template /etc/templates/index-template.html index.html /usr/share/nginx/html/index.html

nginx "$@"
