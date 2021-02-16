#!/bin/bash

cd /mnt/d/em/Core

set -e
source ./shared/dev/dev-functions.sh
IMAGE_TAG=dev
log_header "Building and Deploying Docker Images with Tag: $IMAGE_TAG"

log_detail "Logging in to Docker hub"
docker login

build_and_deploy_image "consul" "$IMAGE_TAG"
build_and_deploy_image "dns" "$IMAGE_TAG"
build_and_deploy_image "portal" "$IMAGE_TAG"
build_and_deploy_image "portainer" "$IMAGE_TAG"
build_and_deploy_image "portainer-agent" "$IMAGE_TAG"
build_and_deploy_image "ssh-server" "$IMAGE_TAG" "SSH_PASS=P@55w0rd"
build_and_deploy_image "vault" "$IMAGE_TAG"
