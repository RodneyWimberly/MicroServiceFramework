#!/bin/sh

# Make our stuff available
cd $CORE_SCRIPT_DIR
chmod 0755 common-functions.sh
. common-functions.sh

add_path "${CORE_SCRIPT_DIR}"

# Get Docker/Node/Hosting information from the Docker API for use in configuration
hosting_details

# Consul-template vars are encoded as ** not $ in our templates so that bash doesn't get confused.
# First we use bash to replace all $vars with values
# Second we replace all ** to $
# Third we pass to consul-template
log_detail "merging expanded variables and updating configuration based on Consul cluster deployment"

cat /etc/templates/nginx.conf | envsubst | sed 's/**/$/g' > /etc/templates/nginx-template.conf
run_consul_template /etc/templates/nginx-template.conf nginx.conf /etc/ngnix/conf.d/default.conf "consul lock -http-addr=http://consul.service.consul:8500 -name service/portal -shell=false reload nginx -s reload"

cat /etc/templates/index.html | envsubst  | sed 's/**/$/g' > /etc/templates/index-template.html
run_consul_template /etc/templates/index-template.html index.html /usr/share/nginx/html/index.html

# Make a folder for ngnix.pid
mkdir -p /run/nginx

# Remove default configuration
rm /usr/share/nginx/http-default_server.conf

set +e
nginx -g 'daemon off;'

keep_container_alive
