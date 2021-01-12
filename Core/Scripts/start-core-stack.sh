#!/bin/bash
# DESCRIPTION
# Starts the core docker stack

clear
echo "Deploying core stack to swarm"

set +e

# init swarm (need for service command); if not created
echo "Checking to see if we are joined to the the swarm"
docker node ls 2> /dev/null | grep "Leader"
if [ $? -ne 1 ]; then
    echo "We are joined to the swarm, now leaving"
    docker stack rm core
    docker swarm leave -f > /dev/null 2>&1
fi
echo "Cleaning up stacks, networks, containers, and images"
docker system prune -f > /dev/null 2>&1
echo "Initializing the swarm"
docker swarm init > /dev/null 2>&1
set -e

DOCKER_REGISTRY="rodneywimberly/dockerregistry:"
echo "Building dns image for core stack"
docker build -t ${DOCKER_REGISTRY}dns Dns/.
echo "Building hello image for core stack"
docker build -t ${DOCKER_REGISTRY}hello Hello/.
echo "Building portal image for core stack"
docker build -t ${DOCKER_REGISTRY}portal Portal/.
echo "Building registry image for core stack"
docker build -t ${DOCKER_REGISTRY}registry Registry/.
echo "Building world image for core stack"
docker build -t ${DOCKER_REGISTRY}world World/.

echo "Logging in to repository ${DOCKER_REGISTRY}"
docker login --username=rodneywimberly --password=P@55w0rd!
echo "Deploying image dns for core stack"
docker push ${DOCKER_REGISTRY}dns
echo "Deploying image hello for core stack"
docker push ${DOCKER_REGISTRY}hello
echo "Deploying image portal for core stack"
docker push ${DOCKER_REGISTRY}portal
echo "Deploying image registry for core stack"
docker push ${DOCKER_REGISTRY}registry
echo "Deploying image world for core stack"
docker push ${DOCKER_REGISTRY}world

echo "Creating overlay networks"
docker network create --driver=overlay --attachable --subnet=172.16.238.0/24 admin_network
#docker network create --driver=overlay --attachable api_network

SWARM_MASTER=$(docker info --format "{{.Swarm.NodeAddr}}")
echo "Deploying core stack to swarm master ${SWARM_MASTER}"
docker stack deploy core --compose-file=./docker-compose.yml

#echo "Scaling service registry-follower to 2 instances for core stack"
#docker service scale core_registry-follower=2
#echo "Scaling service vault to 3 instances for core stack"
#docker service scale core_vault=3
#echo "Scaling service jump-box to 0 instances for core stack"
#docker service scale core_jump-box=0

#echo "Initializing vault service"
#./Vault/scripts/initialize-vault.sh

#echo "Launching portal"
#start http://portal.service.consul/

#docker run --rm -it -d --name swarm_visualizer -p 8081:8080 -e HOST=localhost -v /var/run/docker.sock:/var/run/docker.sock dockersamples/visualizer
#docker run --volume=/var/run/docker.sock:/var/run/docker.sock -p 8888:1224 amir20/dozzle:latest --addr localhost:1224
