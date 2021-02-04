#!/bin/bash

cd ~/msf/Core/shared/admin

set -e

source ../scripts/core.env
source ../scripts/admin-functions.sh

DOCKER_USER="rodneywimberly"
DOCKER_PASSWORD="P@55w0rd"

echo Building and Deploying Docker Images

log "Logging in to Docker hub"
docker login --username="${DOCKER_USER}" --password="${DOCKER_PASSWORD}"

build_and_deploy_image "consul"
build_and_deploy_image "dns"
build_and_deploy_image "portal"
build_and_deploy_image "vault"
