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

# Install GitHub CLI (curl), Clone Consul repo, and run deployment script.
# This can be used to build application stacks on bare containers
GITHUB_ACCESS_TOKEN=b606a0781f57605d4e5b00b753a6f26c23ff8908 && \
VERSION=`curl  "https://api.github.com/repos/cli/cli/releases/latest" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/' | cut -c2-` && \
echo "Downloading GitHub CLI version "$VERSION && \
curl -sSL https://github.com/cli/cli/releases/download/v${VERSION}/gh_${VERSION}_linux_amd64.tar.gz -o gh_${VERSION}_linux_amd64.tar.gz && \
tar xvf gh_${VERSION}_linux_amd64.tar.gz && \
rm gh_${VERSION}_linux_amd64.tar.gz && \
cp gh_${VERSION}_linux_amd64/bin/gh ./ && \
rm -rf ./gh_${VERSION}_linux_amd64 && \
./gh version && \
echo "GitHub CLI was successfully installed" && \
echo "${GITHUB_ACCESS_TOKEN}" > key.txt && \
./gh auth login --with-token < key.txt && \
rm -rf /tmp/consul && \
echo "Cloning Consul repo" && \
./gh repo clone RodneyWimberly/consul /tmp/consul && \
cd /tmp/consul && \
chmod u+x *.sh && \
chmod u+x ./scripts/*.sh && \
deploy.sh

# Install GitHub CLI (APK), Clone Consul repo, and run deployment script.
# This can be used to build application stacks on bare containers
apk add gitsome && \
./gh version && \
echo "GitHub CLI was successfully installed" && \
echo "${GITHUB_ACCESS_TOKEN}" > key.txt && \
./gh auth login --with-token < key.txt && \
rm -rf /tmp/consul && \
echo "Cloning Consul repo" && \
./gh repo clone RodneyWimberly/consul /tmp/consul && \
cd /tmp/consul && \
deploy.sh

# Diag-Tools
docker run -d --restart always docker.pkg.github.com/rodneywimberly/dockerrepositories/diag-tools:1.0

# Portainer
docker run -d -p 9000:9000 --restart always -v /var/run/docker.sock:/var/run/docker.sock -v /opt/portainer:/data portainer/portainer && \
curl -L https://downloads.portainer.io/agent-stack.yml -o agent-stack.yml && \
docker stack deploy --compose-file=agent-stack.yml portainer-agent

# Docker Compose UI
docker run --name docker-compose-ui -p 5000:5000 -w /opt/docker-compose-projects/ -v /var/run/docker.sock:/var/run/docker.sock francescou/docker-compose-ui:1.10.0

# Rancher
docker run -d --restart=unless-stopped -p 8080:8080 rancher/server:stable
