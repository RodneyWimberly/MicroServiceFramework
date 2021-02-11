#!/bin/bash

cd /mnt/d/em/Core

set -e

source ./shared/dev/dev-functions.sh

log_header "Building and Deploying Docker Images"

log_detail "Logging in to Docker hub"
docker login

build_and_deploy_image "consul"
build_and_deploy_image "dns"
build_and_deploy_image "portal"`
build_and_deploy_image "portainer"
build_and_deploy_image "portainer-agent"
build_and_deploy_image "ssh-server"
build_and_deploy_image "vault"
