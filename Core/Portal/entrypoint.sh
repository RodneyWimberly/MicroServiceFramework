#!/bin/sh
set +e
set +x

# shellcheck source=./core-functions.sh
. "${CORE_SCRIPT_DIR}"/core-functions.sh
add_path "${CORE_SCRIPT_DIR}"
hosting_details
get_consul_ip
update_dns_config

log "Merging expanded variables and updating configuration based on Consul cluster deployment"
log_detail "Remove default configuration"
if [ -f /usr/share/nginx/http-default_server.conf ]; then
  rm -f /usr/share/nginx/http-default_server.conf
fi

# Consul-template vars are encoded as ** not $ in our templates so that bash doesn't get confused.
# First we use bash to replace all $vars with values
# Second we replace all ** to $
# Third we pass to consul-template
log_detail "Processing nginx.conf"
envsubst < /etc/templates/nginx.conf > /etc/templates/nginx-template.conf
sed -i 's/\*\*/$/g' /etc/templates/nginx-template.conf
# ContainerPilot will handle consul-template on consul service health change events rather than timeouts

log_detail "Processing index.html"
envsubst < /etc/templates/index.html  > /etc/templates/index-template.html
sed -i 's/\*\*/$/g' /etc/templates/index-template.html
run_consul_template /etc/templates/index-template.html index.html /usr/share/nginx/html/index.html 

log_detail "Processing containerpilot.json5"
envsubst < /etc/templates/containerpilot.json5 > /etc/containerpilot.json5
export CONTAINERPILOT=/etc/containerpilot.json5

log_detail "Starting ContainerPilot."
/bin/containerpilot
