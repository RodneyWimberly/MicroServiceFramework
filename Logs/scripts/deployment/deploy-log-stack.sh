#!/bin/bash
# DESCRIPTION: Retrieves Node info and populates environment vars for later use,
#   tears down exiting container resources and builds application stacks on bare containers

set -ueo pipefail
set +x

# shellcheck source=../../../shared/scripts/development-functions.sh
. /mnt/d/msf/shared/scripts/development-functions.sh

eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa
log_header "Logs: Stack Deployment"
export NUM_OF_MGR_NODES=$(docker info --format "{{.Swarm.Managers}}")
export NODE_IP=$(docker info --format "{{.Swarm.NodeAddr}}")
export NODE_ID=$(docker info --format "{{.Swarm.NodeID}}")
export NODE_NAME=$(docker info --format "{{.Name}}")
export NODE_IS_MANAGER=$(docker info --format "{{.Swarm.ControlAvailable}}")
export CONTAINER_IP=$(hostip)
export CONTAINER_NAME=$(hostname)
export ETH0_IP=$(get_ip_from_adapter eth0)
export ETH1_IP=$(get_ip_from_adapter eth1)
export ETH2_IP=$(get_ip_from_adapter eth2)
export ETH3_IP=$(get_ip_from_adapter eth3)
export ETH4_IP=$(get_ip_from_adapter eth4)
show_hosting_details

deploy_stack "${LOGS_STACK_NAME}"

log_detail "Waiting 15 seconds for stack to come up"
sleep 15

log "Log Deployment completed successfully!"