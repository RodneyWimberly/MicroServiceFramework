#!/bin/sh
set +e
set +x

# # Make our stuff available
# cd "$CORE_SCRIPT_DIR" || exit 1
# # chmod 0755 core-functions.sh
# . ./core-functions.sh

# shellcheck source=./core-functions.sh
. "${CORE_SCRIPT_DIR}"/core-functions.sh

add_path "${CORE_SCRIPT_DIR}"
update_dns_config

# Get Docker/Node/Hosting information from the Docker API for use in configuration
hosting_details
get_consul_ip

add_consul_service portainer-agent 9001 "\"api\", \"$CONTAINER_NAME\"" SERVICE_ID
log_detail "Starting portainer agent."
/app/agent
remove_consul_service $SERVICE_ID
