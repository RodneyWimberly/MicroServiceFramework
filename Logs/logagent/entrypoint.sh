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

log_detail "Starting Log Agent"
/run.sh