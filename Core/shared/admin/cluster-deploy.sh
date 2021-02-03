#!/bin/bash
# DESCRIPTION: Retrieves Node info and populates environment vars for later use,
#   tears down exiting container resources and builds application stacks on bare containers
set -e

source ../scripts/core.env
source ../scripts/admin-functions.sh


log "*** >=>=>=>  Stack Deployment  <=<=<=< ***"

export NUM_OF_MGR_NODES=$(docker info --format "{{.Swarm.Managers}}")
export NODE_IP=$(docker info --format "{{.Swarm.NodeAddr}}")
export NODE_ID=$(docker info --format "{{.Swarm.NodeID}}")
export NODE_NAME=$(docker info --format "{{.Name}}")
export NODE_IS_MANAGER=$(docker info --format "{{.Swarm.ControlAvailable}}")
export CONTAINER_IP=$(ip -o ro get $(ip ro | awk '$1 == "default" { print $3 }') | awk '{print $5}')
export ETH0_IP=$(ip -o -4 addr list eth0 | head -n1 | awk '{print $4}' | cut -d/ -f1)
export ETH1_IP=$(ip -o -4 addr list eth1 | head -n1 | awk '{print $4}' | cut -d/ -f1)
export ETH2_IP=$(ip -o -4 addr list eth2 | head -n1 | awk '{print $4}' | cut -d/ -f1)
export ETH3_IP=$(ip -o -4 addr list eth3 | head -n1 | awk '{print $4}' | cut -d/ -f1)
export ETH4_IP=$(ip -o -4 addr list eth4 | head -n1 | awk '{print $4}' | cut -d/ -f1)
show_hosting_details

set +e
log_detail "Removing the following stacks: ${CORE_STACK_NAME}, ${LOGGING_STACK_NAME}, and ${UI_STACK_NAME}"
docker stack rm "${CORE_STACK_NAME}" ${LOGGING_STACK_NAME} ${UI_STACK_NAME}

log_detail "Waiting 1 seconds for item deletion finalizes"
sleep 1

create_network admin_network
# create_network admin_network ${CORE_SUBNET}
# create_network api_network
# create_network log_network
set -e

deploy_stack "${DEVOPS_STACK_NAME}"
# deploy_stack "${UI_STACK_NAME}"
# deploy_stack "${LOGGING_STACK_NAME}"
deploy_stack "${CORE_STACK_NAME}"

exit
