#!/bin/sh
set +e
set +x

# shellcheck source=./common-functions.sh
. "$LOGS_SCRIPT_DIR"/common-functions.sh

# Put our script folder in the path
add_path "${LOGS_SCRIPT_DIR}"

# Update container to use our DNS (DNS settings in stack definition don't work 100%)
update_dns_config

# Get Docker/Node/Hosting information from the Docker API for use in configuration
hosting_details

# Get Consul address so we can register our service and resolve other services
get_consul_ip

# Register Mongo with Consul
add_consul_service "mongo" 27017 "\"db\", \"$CONTAINER_NAME\"" SERVICE_ID1

log_detail "Starting Mongo"
/sbin/tini -- /run.sh

# Un-register Mongo with Consul
remove_consul_service "${$SERVICE_ID1:?Unable to un-register db service}"
