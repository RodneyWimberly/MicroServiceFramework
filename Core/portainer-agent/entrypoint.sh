#!/bin/sh
set +e
set +x

# shellcheck source=./core-functions.sh
. "${CORE_SCRIPT_DIR}"/core-functions.sh

add_path "${CORE_SCRIPT_DIR}"
hosting_details
get_consul_ip
update_dns_config
add_consul_service portainer-agent 9001 "\"api\", \"$CONTAINER_NAME\"" SERVICE_ID
log_detail "Starting portainer agent."
cd /app
./agent
keep_container_alive
remove_consul_service $SERVICE_ID
