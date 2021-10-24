#!/bin/sh
set +e
set +x

# shellcheck source=./common-functions.sh
. "$LOGS_SCRIPT_DIR"/common-functions.sh

# export GRAYLOG_ROOT_TIMEZONE=Pacifdic
# Put our script folder in the path
add_path "${LOGS_SCRIPT_DIR}"
hosting_details
get_consul_ip
update_dns_config

# Register Graylog with Consul
add_consul_service "graylog" 9000 "\"www\", \"api\"" SERVICE_ID1
add_consul_service "graylog" 1514 "\"syslog-tcp\"" SERVICE_ID2
# add_consul_service "graylog" 12201 "\"gelf-udp\"" SERVICE_ID3

log_detail "Starting Graylog"
set +e
cd /usr/local/scripts
if [ "$(./docker-entrypoint.sh graylog)" -ne 0 ]; then
    log_failure "Graylog failed to start."
fi
# Un-register Graylog with Consul
# remove_consul_service "${SERVICE_ID3:?Unable to un-register gelf-udp service}"
remove_consul_service "${SERVICE_ID2:?Unable to un-register syslog-udp service}"
remove_consul_service "${SERVICE_ID1:?Unable to un-register www/api service}"