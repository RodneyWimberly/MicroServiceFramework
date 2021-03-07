#!/bin/bash
set -ueo pipefail
set +x

# shellcheck source=../../scripts/development/development.env
. /mnt/d/msf/scripts/development/development.env
# shellcheck source=../../scripts/development/development-functions.sh
. /mnt/d/msf/scripts/development/development-functions.sh

IMAGE_TAG=dev
log_header "Building and Publishing Docker Images with Tag: $IMAGE_TAG"

log_detail "Logging in to Docker hub"
docker login

/mnt/d/msf/core/scripts/development/build-task.sh "$IMAGE_TAG"
