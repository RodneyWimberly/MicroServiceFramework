#!/bin/sh

# Make our stuff available
# shellcheck source=./common-functions.sh
. "${CORE_SCRIPT_DIR}"/common-functions.sh
add_path "${CORE_SCRIPT_DIR}"

# Get Docker/Node/Hosting information from the Docker API for use in configuration
hosting_details

# Merge expanded variables with configuration templates and place in the config folder
log_detail "Linking the /consul/templates folder to the /etc/templates folder"
ln -s /consul/templates /etc/templates

expand_consul_config_from "common.json"
if [ "${NODE_IS_MANAGER}" == "true" ]; then
  agent_mode="server"
  expand_consul_config_from "server.json"
else
  agent_mode="client"
  expand_consul_config_from "client.json"
fi

add_consul_service "consul" 8500 "\"portal\", \"${NODE_NAME}\""
log "Starting Consul in ${agent_mode} mode using the following command: exec docker-entrypoint.sh $@"
docker-entrypoint.sh "$@"
remove_consul_service "$SERVICE_ID"
