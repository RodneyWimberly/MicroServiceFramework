#!/bin/sh

# Make our stuff available
cd $CORE_SCRIPT_DIR
chmod 0755 common-functions.sh
. common-functions.sh

add_path "${CORE_SCRIPT_DIR}"

# Get Docker/Node/Hosting information from the Docker API for use in configuration
hosting_details
get_consul_ip

add_consul_service portainer

log_detail "Starting portainer."
/app/portainer

remove_consul_service $SERVICE_ID
