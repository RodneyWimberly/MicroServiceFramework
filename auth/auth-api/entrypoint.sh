#!/bin/sh
set +e
set +x

# shellcheck source=./auth-functions.sh
. "${AUTH_SCRIPT_DIR}"/auth-functions.sh

add_path "${AUTH_SCRIPT_DIR}"
hosting_details
get_consul_ip
update_dns_config
wait_for_auth_db

add_consul_service "auth_api" 50002 "\"api\", \"$CONTAINER_NAME\"" SERVICE_ID
log_detail "Starting auth-api."
cd /app
dotnet MicroServicesFramework.Auth.Admin.Api.dll
remove_consul_service "$SERVICE_ID"

keep_container_alive

