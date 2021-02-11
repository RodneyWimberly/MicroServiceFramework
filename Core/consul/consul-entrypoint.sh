#!/bin/sh

# Make our stuff available
source "${CORE_SCRIPT_DIR}"/common-functions.sh
add_path "${CORE_SCRIPT_DIR}"

# Get Docker/Node/Hosting information from the Docker API for use in configuration
hosting_details

# Merge expanded variables with configuration templates and place in the config folder
expand_consul_config_from "common.json"
if [ "${NODE_IS_MANAGER}" == "true" ]; then
  agent_mode="server"
  expand_consul_config_from "server.json"
else
  agent_mode="client"
  expand_consul_config_from "client.json"
fi

SERVICE_8500=$(add_consul_service "consul" 8500 "\"portal\"")
SERVICE_8600=$(add_consul_service "consul" 8600 "\"dns\"")
log "Starting Consul in ${agent_mode} mode using the following command: exec docker-entrypoint.sh $@"
docker-entrypoint.sh "$@"
remove_consul_service $SERVICE_8600
remove_consul_service $SERVICE_8500
