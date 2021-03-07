#!/bin/bash
set -ueo pipefail
set +x

# shellcheck source=../../../scripts/development/development.env
. /mnt/d/msf/scripts/development/development.env
# shellcheck source=../../../scripts/development/development-functions.sh
. /mnt/d/msf/scripts/development/development-functions.sh

pushd /mnt/d/msf/core || exit 1

IMAGE_TAG=${1:-dev}
log_header "core: Building and Publishing Docker Images with Tag: $IMAGE_TAG"

if $BUILD_CONSUL; then
    build_and_deploy_image "consul" "$IMAGE_TAG"
fi
if $BUILD_DNS; then
    build_and_deploy_image "dns" "$IMAGE_TAG"
fi
if $BUILD_PORTAL; then
    build_and_deploy_image "portal" "$IMAGE_TAG"
fi
if $BUILD_PORTAINER; then
    build_and_deploy_image "portainer" "$IMAGE_TAG"
fi
if $BUILD_PORTAINER_AGENT; then
    build_and_deploy_image "portainer-agent" "$IMAGE_TAG"
fi
if $BUILD_SSH_SERVER; then
    build_and_deploy_image "ssh-server" "$IMAGE_TAG" "SSH_PASS=P@55w0rd"
fi
if $BUILD_VAULT; then
    build_and_deploy_image "vault" "$IMAGE_TAG"
fi

popd