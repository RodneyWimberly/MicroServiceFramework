#!/bin/sh
set +e
set +x

# shellcheck source=./common-functions.sh
. "$LOGS_SCRIPT_DIR"/common-functions.sh

# Put our script folder in the path
add_path "${LOGS_SCRIPT_DIR}"
hosting_details
get_consul_ip
update_dns_config

# Register Mongo with Consul
add_consul_service "mongo" 27017 "\"db\", \"$CONTAINER_NAME\"" SERVICE_ID1

log_detail "Starting Mongo"
/usr/local/bin/docker-entrypoint.sh mongod

# Un-register Mongo with Consul
remove_consul_service "${SERVICE_ID1:?Unable to un-register db service}"
