#!/bin/bash
set -ueo pipefail
set +x

# shellcheck source=../../shared/scripts/development-functions.sh
. /mnt/d/msf/shared/scripts/development-functions.sh

IMAGE_TAG=dev
log_header "Building and Publishing Docker Images with Tag: $IMAGE_TAG"

log_detail "Logging in to Docker hub"
docker login

/mnt/d/msf/core/scripts/development/build-task.sh "$IMAGE_TAG"
/mnt/d/msf/logs/scripts/development/build-task.sh "$IMAGE_TAG"
/mnt/d/msf/auth/scripts/development/build-task.sh "$IMAGE_TAG"
