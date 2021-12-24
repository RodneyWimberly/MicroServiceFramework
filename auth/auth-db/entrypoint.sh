#!/bin/sh
set +e
set +x

# shellcheck source=./auth-functions.sh
. "${AUTH_SCRIPT_DIR}"/auth-functions.sh

add_path "${AUTH_SCRIPT_DIR}"
hosting_details
get_consul_ip
update_dns_config

add_consul_service "auth_db" 1433 "\"db\", \"$CONTAINER_NAME\"" SERVICE_ID
log_detail "Starting auth-db."
/opt/mssql/bin/sqlservr
remove_consul_service "$SERVICE_ID"
