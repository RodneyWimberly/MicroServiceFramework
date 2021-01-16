#!/bin/bash
# DESCRIPTION
# Starts the core docker stack

clear
set +e

source ./Scripts/common.sh

echo -e "${PURPLE} ******* Diag Stack Swarm Deployment ******* ${NC}"

# init swarm (need for service command); if not created
echo -e "${GREEN} Checking to see if the swarm is initialized ${NC}"
docker node ls 2> /dev/null | grep "Leader"
if [ $? -ne 0 ]; then
    echo -e "${LT_GREEN} Swarm not active, Initializing the swarm ${NC}"
    docker swarm init > /dev/null 2>&1
fi
echo -e "${GREEN} Cleaning up diag stack ${NC}"
docker stack rm diag

./build-diagnostics-stack.sh

echo -e "${GREEN} Validating swarm network infrastructure ${NC}"
docker network ls -f name=consul_network -q 2> /dev/null

if [[ $? -ne 0 ]]; then
    echo -e "${LT_GREEN} Creating attachable overlay network 'consul_network' ${NC}"
    docker network create --driver=overlay --attachable --subnet=192.168.1.0/24 consul_network
    #192.168.1.0/24
fi


SWARM_MASTER=$(docker info --format "{{.Swarm.NodeAddr}}")
echo -e "${GREEN} Deploying diag stack to swarm master ${SWARM_MASTER} ${NC} "
docker stack deploy diag --compose-file=./diagnostics-stack.yml

