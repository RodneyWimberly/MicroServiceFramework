#!/bin/bash
set -ueo pipefail
set +x

# shellcheck source=../../../shared/scripts/development-functions.sh
. /mnt/d/msf/shared/scripts/development-functions.sh

pushd /mnt/d/msf/logs || exit 1

IMAGE_TAG=${1:-dev}
log_header "logs: Building and Publishing Docker Images with Tag: $IMAGE_TAG"

if $BUILD_LOGS_GRAYLOG; then
    build_and_deploy_image "graylog" "$IMAGE_TAG"
fi
if $BUILD_LOGS_LOGAGENT; then
    build_and_deploy_image "logagent" "$IMAGE_TAG"
fi
if $BUILD_LOGS_MONGO; then
    build_and_deploy_image "mongo" "$IMAGE_TAG"
fi
if $BUILD_LOGS_ELASTICSEARCH; then
    build_and_deploy_image "elasticsearch" "$IMAGE_TAG"
fi

popd