#!/bin/sh
set +e
set +x

# # Make our stuff available
# # cd "$CORE_SCRIPT_DIR"
# # chmod 0755 core-functions.sh
# . core-functions.sh

# shellcheck source=./core-functions.sh
. "${CORE_SCRIPT_DIR}"/core-functions.sh
add_path "${CORE_SCRIPT_DIR}"
update_dns_config

# Get Docker/Node/Hosting information from the Docker API for use in configuration
hosting_details
get_consul_ip

log_detail "merging expanded variables and updating configuration based on Consul cluster deployment"
# Remove default configuration
if [ -f /usr/share/nginx/http-default_server.conf ]; then
  rm -f /usr/share/nginx/http-default_server.conf
fi

# Consul-template vars are encoded as ** not $ in our templates so that bash doesn't get confused.
# First we use bash to replace all $vars with values
# Second we replace all ** to $
# Third we pass to consul-template
envsubst < /etc/templates/nginx.conf > /etc/templates/nginx-template.conf
sed -i 's/\*\*/$/g' /etc/templates/nginx-template.conf
run_consul_template /etc/templates/nginx-template.conf nginx.conf /etc/nginx/nginx.conf "consul lock -http-addr=${CONSUL_HTTP_ADDR} -name service/portal -shell=false reload nginx -s reload"

envsubst < /etc/templates/index.html  > /etc/templates/index-template.html
sed -i 's/\*\*/$/g' /etc/templates/index-template.html
run_consul_template /etc/templates/index-template.html index.html /usr/share/nginx/html/index.html

log_detail "Waiting 30 seconds for other services to come up before loading Nginx"
sleep 30

add_consul_service "portal" 80 "\"www\", \"$CONTAINER_NAME\"" SERVICE_ID
log_detail "Starting nginx."
nginx -g 'daemon off;'
remove_consul_service "$SERVICE_ID"
