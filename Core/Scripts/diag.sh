#!/bin/bash
# DESCRIPTION
# Starts the the diag-tools container with a Bash shell for debugging

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

clear
set +e

echo -e "${GREEN} Starting diag-tools container and opening a shell, happy debugging ${NC}"
docker run --name diag-tools -it --net=admin_network --dns 192.168.1.2 localhost:5000/diag-tools

echo -e "${RED} Shell closed, now stopping the diag-tools container  ${NC}"
docker rm diag-tools

-bind='{{ GetAllInterfaces | include "network" "192.168.0.0/16" }}'


# Portainer
docker run -d -p 9000:9000 --restart always -v /var/run/docker.sock:/var/run/docker.sock -v /opt/portainer:/data portainer/portainer
curl -L https://downloads.portainer.io/agent-stack.yml -o agent-stack.yml && docker stack deploy --compose-file=agent-stack.yml portainer-agent
# Docker Compose
#docker run --name docker-compose-ui -p 5000:5000 -w /opt/docker-compose-projects/ -v /var/run/docker.sock:/var/run/docker.sock francescou/docker-compose-ui:1.10.0
# Rancher
#docker run -d --restart=unless-stopped -p 8080:8080 rancher/server:stable
