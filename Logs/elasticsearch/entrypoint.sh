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

# Register Elasticsearch with Consul
add_consul_service "elasticsearch" 9200 "\"api\", \"$CONTAINER_NAME\"" SERVICE_ID1
add_consul_service "elasticsearch" 9300 "\"transport\", \"$CONTAINER_NAME\"" SERVICE_ID2

log_detail "Starting Elasticsearch"
/usr/local/bin/docker-entrypoint.sh "$@"

# Un-register Elasticsearch with Consul
remove_consul_service "${SERVICE_ID2:?Unable to un-register transport service}"
remove_consul_service "${SERVICE_ID1:?Unable to un-register api service}"
