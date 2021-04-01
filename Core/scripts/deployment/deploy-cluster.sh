#!/bin/bash
# DESCRIPTION: Retrieves Node info and populates environment vars for later use,
#   tears down exiting container resources and builds application stacks on bare containers

set -ueo pipefail
set +x



# shellcheck source=../../../shared/scripts/deployment-functions.sh
. ~/msf/deployment-functions.sh
# shellcheck source=package/core.env
. ~/msf/core/core.env

start_ts=$(get_seconds)
push_dir ~/msf/core || exit 1  >/dev/null 2>&1

eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa  >/dev/null 2>&1
log_header "Core: Stack Deployment"

if ${1:-true}; then
  ~/msf/core/shutdown-cluster.sh
fi

set +e
log "Creating admin_network"
create_network admin_network 192.168.100.0/24  >/dev/null 2>&1
set -e

log "Deploying ${CORE_STACK_NAME} stack"
deploy_stack "${CORE_STACK_NAME}"  >/dev/null 2>&1

log "Waiting for Vault service registration"
start1_ts=$(get_seconds)
until docker-service-exec core_consul consul catalog services | grep -- '^vault' > /dev/null; do
  sleep 5
  seconds=$(get_elapsed_seconds "$start1_ts")
  if [ $seconds -gt 200 ]; then
    log_error "Vault service hasn't responded to docker/ssh requests in over $seconds seconds. Exiting"
    exit 1
  elif [ $seconds -gt 150 ]; then
    log_warning "Vault service hasn't responded to docker/ssh requests in over $seconds seconds"
  fi
done
log_success "Vault registered" "$start1_ts"

set +e
docker-service-exec core_vault /usr/local/scripts/initialize-vault.sh

pop_dir  >/dev/null 2>&1

end_ts=$(date +%s)
log_success "Core Deployment completed in $((end_ts - start_ts)) seconds"
