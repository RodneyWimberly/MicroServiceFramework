#!/bin/sh
set +e
set +x

# Make our stuff available
# shellcheck source=./common-functions.sh
. "${CORE_SCRIPT_DIR}"/common-functions.sh
add_path "${CORE_SCRIPT_DIR}"

# Get Docker/Node/Hosting information from the Docker API for use in configuration
hosting_details
export DOCKER_HOST=tcp://$NODE_IP:2375
log_detail "DOCKER_HOST: $DOCKER_HOST"

# Merge expanded variables with configuration templates and place in the config folder
log_detail "Linking the /consul/templates folder to the /etc/templates folder"
ln -s /consul/templates /etc/templates

expand_consul_config_from "common.json"
if [ "${NODE_IS_MANAGER}" = "true" ]; then
  agent_mode="server"
  expand_consul_config_from "server.json"
  cp /consul/templates/consul-dns* /consul/config
else
  agent_mode="client"
  expand_consul_config_from "client.json"
fi

# /bin/sh -c "sleep 15; remove_unhealthy_services"
export SERVICE_CHECK_URL=http://${ETH0_IP}:8500/v1/status/leader
export SERVICE_CHECK_METHOD=GET
export SERVICE_CHECK_BODY={}
add_consul_service "consul" 8500 "\"api\", \"$NODE_NAME\", \"$CONTAINER_NAME\"" SERVICE_ID1 consul-http-service.json
add_consul_service "consul" 8600 "\"dns\"" SERVICE_ID2
log "Starting Consul in ${agent_mode} mode."

docker-entrypoint.sh "$@"
remove_consul_service "$SERVICE_ID2"
remove_consul_service "$SERVICE_ID1"