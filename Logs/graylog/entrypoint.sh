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

# Register Graylog with Consul
add_consul_service "graylog" 9000 "\"www\", \"portal\", \"$CONTAINER_NAME\"" SERVICE_ID1
# add_consul_service "graylog" 12201 "\"gelf\", \"$CONTAINER_NAME\"" SERVICE_ID2

log_detail "Starting Graylog"
/usr/local/scripts/docker-entrypoint.sh graylog

# Un-register Elasticsearch with Consul
# remove_consul_service "${SERVICE_ID2:?Unable to un-register gelf service}"
remove_consul_service "${SERVICE_ID1:?Unable to un-register www service}"
