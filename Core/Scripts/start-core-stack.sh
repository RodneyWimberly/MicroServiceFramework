#!/bin/bash
# DESCRIPTION
# Starts the core docker stack

clear
set +e

source ./Scripts/common.sh

echo -e "${GREEN} ******* Core Stack Swarm Deployment ******* ${NC}"

# init swarm (need for service command); if not created
echo -e "${LT_GREEN} Checking to see if the swarm is initialized ${NC}"
docker node ls 2> /dev/null | grep "Leader"
if [ $? -ne 0 ]; then
    echo -e "${RED} Swarm not active, Initializing the swarm ${NC}"
    docker swarm init > /dev/null 2>&1
fi
echo -e "${LT_RED} Cleaning up core stack ${NC}"
docker stack rm core
echo -e "${LT_RED} Cleaning up all networks, volumes, containers, and images ${NC}"
docker system prune -f > /dev/null 2>&1

./Scripts/build-core-stack.sh

echo -e "${GREEN} Validating swarm network infrastructure ${NC}"
NET_ID=$(docker network ls -f name=admin_network -q)

if [[ -z "$NET_ID" ]]; then
    echo -e "${LT_GREEN} Creating attachable overlay network 'consul_network' ${NC}"
    docker network create --driver=overlay --attachable --subnet=192.168.1.0/24 consul_network
fi
#docker network create --driver=overlay --attachable api_network

SWARM_MASTER=$(docker info --format "{{.Swarm.NodeAddr}}")
echo -e "${GREEN} Deploying core stack to swarm master ${SWARM_MASTER} ${NC} "
docker stack deploy core --compose-file=./docker-compose.yml

./Scripts/add-configs-and-secrets.sh
./Scripts/assign-configs-and-secrets.sh

#echo -e "Scaling service registry-leader to 1 instances for core stack"
#docker service scale core_registry-leader=1

#echo -e "Scaling service registry-follower to 1 instances for core stack"
#docker service scale core_registry-follower=1

#echo -e "Scaling service dns-primary to 1 instances for core stack"
#docker service scale core_dns-primary=1

#echo -e "Scaling service dns-secondary to 1 instances for core stack"
#docker service scale core_dns-secondary=1

#echo -e "Scaling service vault to 1 instances for core stack"
#docker service scale core_vault=1

#echo -e "Scaling service portal to 1 instances for core stack"
#docker service scale core_portal=1

#echo -e "Scaling service hello to 1 instances for core stack"
#docker service scale core_hello=1

#echo -e "Scaling service world to 1 instances for core stack"
#docker service scale core_world=1

#echo -e "Initializing vault service"
#./Vault/scripts/initialize-vault.sh

#echo -e "Launching portal"
#start http://portal.service.consul/

#./Scripts/show-logs.sh core
