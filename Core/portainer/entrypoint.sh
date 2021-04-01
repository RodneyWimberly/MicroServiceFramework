#!/bin/sh
set +e
set +x

# shellcheck source=./core-functions.sh
. "${CORE_SCRIPT_DIR}"/core-functions.sh

add_path "${CORE_SCRIPT_DIR}"
hosting_details
get_consul_ip
update_dns_config
start_ts=$(get_seconds)
log "Looking for portainer-agent.service.consul"
until dig +short portainer-agent.service.consul >/dev/null 2>&1;
do
  log_warning "Looking for portainer-agent.service.consul failed, Retrying in 1 second"
  sleep 1
done
log_success "Host portainer-agent.service.consul found" "$start_ts"
add_consul_service "portainer" 9000 "\"www\", \"$CONTAINER_NAME\"" SERVICE_ID
log_detail "Starting portainer."
/portainer "$@"
remove_consul_service $SERVICE_ID
