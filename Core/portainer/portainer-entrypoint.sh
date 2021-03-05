#!/bin/sh

# Make our stuff available
cd $CORE_SCRIPT_DIR
chmod 0755 common-functions.sh
. common-functions.sh

add_path "${CORE_SCRIPT_DIR}"
update_dns_config

# Get Docker/Node/Hosting information from the Docker API for use in configuration
hosting_details
get_consul_ip

add_consul_service "portainer" 9000 "\"portal\"" SERVICE_ID
log_detail "Starting portainer."
/portainer
remove_consul_service $SERVICE_ID
