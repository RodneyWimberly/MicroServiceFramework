#!/bin/sh
set +e
set +x

# shellcheck source=./common-functions.sh
. "$LOGS_SCRIPT_DIR"/common-functions.sh

# Put our script folder in the path
add_path "${LOGS_SCRIPT_DIR}"

# Update container to use our DNS (DNS settings in stack definition don't work 100%)
# update_dns_config

# Get Docker/Node/Hosting information from the Docker API for use in configuration
hosting_details

# Get Consul address so we can register our service and resolve other services
get_consul_ip

log_detail "Starting Mongo"
/sbin/tini -- /run.sh