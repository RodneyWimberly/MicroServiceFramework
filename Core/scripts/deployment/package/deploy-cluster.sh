#!/bin/bash
# DESCRIPTION: Retrieves Node info and populates environment vars for later use,
#   tears down exiting container resources and builds application stacks on bare containers

set -ueo pipefail
set +x

pushd ~/msf/core || exit 1

# shellcheck source=../../../shared/scripts/deployment-functions.sh
. ~/msf/deployment-functions.sh
# shellcheck source=package/core.env
. ~/msf/core/core.env

eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa
log_header "Core: Stack Deployment"

if ${1:-true}; then
  ~/msf/core/shutdown-cluster.sh
fi

set +e
create_network admin_network 192.168.100.0/24
set -e

deploy_stack "${CORE_STACK_NAME}"

log_detail "Waiting 15 seconds for stack to come up"
sleep 15

log_detail "Checking for Vault service registration"
until docker-service-exec core_consul consul catalog services | grep -- '^vault' > /dev/null; do
  log_warning "Vault is not registered, waiting 5 seconds before retrying"
  sleep 5
done

log "Waiting 30 seconds for Vault to come up"
sleep 30

set +e
docker-service-exec core_vault /usr/local/scripts/initialize-vault.sh

log "Core Deployment completed successfully!"

popd