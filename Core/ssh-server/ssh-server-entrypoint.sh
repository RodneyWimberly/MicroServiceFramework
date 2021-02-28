#!/bin/sh
cd "$CORE_SCRIPT_DIR" || exit 1
chmod 0755 common-functions.sh
# shellcheck source=./common-functions.sh
. "$CORE_SCRIPT_DIR"/common-functions.sh
add_path "${CORE_SCRIPT_DIR}"
update_dns_config
# Get Docker/Node/Hosting information from the Docker API for use in configuration
hosting_details
get_consul_ip
add_consul_service ssh-server 22 "" SERVICE_ID
log_detail "Starting SSH service."
/etc/init.d/sshd start
rc-service sshd start
rc-status
keep_container_alive
remove_consul_service "$SERVICE_ID"
