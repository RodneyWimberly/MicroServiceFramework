#!/bin/sh
# DESCRIPTION: Retrieves Node info and populates environment vars for later use,
#   tears down exiting container resources and builds application stacks on bare containers
set -e
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa

# shellcheck source=./admin-functions.sh
. ~/msf/admin/admin-functions.sh

cd ~/msf/admin/

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
if [ -n "$(docker ps -q -f status=running --filter name=core_consul)" ]; then
    ./shutdown-cluster.sh
else
    create_network admin_network
fi
set -e

cp -f ~/msf/docker-compose.yml ~/msf/"${CORE_STACK_NAME}"-stack.yml
deploy_stack "${CORE_STACK_NAME}"
deploy_stack "${LOG_STACK_NAME}"

log_detail "Waiting 15 seconds for stack to come up"
sleep 15

pushd ~/msf/vault || exit 1
./initialize-vault.sh
popd || exit 1

exit
