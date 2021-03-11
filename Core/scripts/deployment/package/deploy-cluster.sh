#!/bin/bash
# DESCRIPTION: Retrieves Node info and populates environment vars for later use,
#   tears down exiting container resources and builds application stacks on bare containers

set -ueo pipefail
set +x

pushd ~/msf/core || exit 1

# shellcheck source=package/deployment-functions.sh
. ~/msf/core/deployment-functions.sh
# shellcheck source=package/core.env
. ~/msf/core/core.env

eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa
log_header "Core: Stack Deployment"
export NUM_OF_MGR_NODES=$(docker info --format "{{.Swarm.Managers}}")
export NODE_IP=$(docker info --format "{{.Swarm.NodeAddr}}")
export NODE_ID=$(docker info --format "{{.Swarm.NodeID}}")
export NODE_NAME=$(docker info --format "{{.Name}}")
export NODE_IS_MANAGER=$(docker info --format "{{.Swarm.ControlAvailable}}")
export CONTAINER_IP=$(hostip)
export CONTAINER_ID=$(hostid)
export CONTAINER_NAME=$(hostname)
export ETH0_IP=$(get_ip_from_adapter eth0)
export ETH1_IP=$(get_ip_from_adapter eth1)
export ETH2_IP=$(get_ip_from_adapter eth2)
export ETH3_IP=$(get_ip_from_adapter eth3)
export ETH4_IP=$(get_ip_from_adapter eth4)
show_hosting_details

log_detail "Parameter: ${1:-true}"
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