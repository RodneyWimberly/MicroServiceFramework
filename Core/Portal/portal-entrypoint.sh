#!/bin/sh

set +e

# Make our stuff available
cd $CORE_SCRIPT_DIR
chmod 0755 common-functions.sh
. common-functions.sh

add_path "${CORE_SCRIPT_DIR}"

# get_consul_ip
# export CONSUL_HTTP_ADDR=http://${CONSUL_IP}:8500

# Get Docker/Node/Hosting information from the Docker API for use in configuration
hosting_details
# log "-----------------------------------------------------------"
# log "- Portal Details"
# log "-----------------------------------------------------------"
# log_detail "Consul Address: ${CONSUL_IP}"
# log_detail "Consul HTTP Address: ${CONSUL_HTTP_ADDR}"

set +e

log_detail "merging expanded variables and updating configuration based on Consul cluster deployment"
# cat /etc/templates/nginx.conf | envsubst > /etc/templates/nginx-template.conf
# cat /etc/templates/index.html | envsubst > /etc/templates/index-template.html
run_consul_template /etc/templates/nginx.conf nginx.conf /etc/ngnix/conf.d/default.conf "consul lock -http-addr=http://consul.service.consul:8500 -name service/portal -shell=false reload nginx -s reload"
run_consul_template /etc/templates/index.html index.html /usr/share/nginx/html/index.html
cat /etc/ngnix/conf.d/default.conf
mkdir -p /run/nginx
nginx -g 'daemon off;'
keep_container_alive
