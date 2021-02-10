#!/bin/sh
# DESCRIPTION: Retrieves Node info and populates environment vars for later use,
#   tears down exiting container resources and builds application stacks on bare containers
set -e

source ./admin-functions.sh

log_header "Stack Deployment"
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

set +e
log_detail "Removing the following stacks: ${CORE_STACK_NAME}, ${LOGGING_STACK_NAME}, and ${UI_STACK_NAME}"
docker stack rm "${CORE_STACK_NAME}" ${LOGGING_STACK_NAME} ${UI_STACK_NAME}

log_detail "Waiting 15 seconds for stack deletion to finalize"
sleep 15

log_detail "Removing the following volumes: ${CORE_STACK_NAME}_consul_data"
docker volume rm "${CORE_STACK_NAME}"_consul_data

log_detail "Waiting 5 seconds for volume deletion to finalize"
sleep 5

create_network admin_network
#create_network admin_network ${CORE_SUBNET}
set -e

deploy_stack "${DEVOPS_STACK_NAME}"
# deploy_stack "${UI_STACK_NAME}"
# deploy_stack "${LOGGING_STACK_NAME}"
deploy_stack "${CORE_STACK_NAME}"

# log_detail "Waiting 15 seconds for stack to come up"
# sleep 15

# ../vault/initialize-vault.sh

exit
