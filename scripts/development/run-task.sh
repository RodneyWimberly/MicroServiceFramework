#!/bin/bash
set -ueo pipefail
set +x

# shellcheck source=../../scripts/development/development.env
. /mnt/d/msf/scripts/development/development.env
# shellcheck source=../../scripts/development/development-functions.sh
. /mnt/d/msf/scripts/development/development-functions.sh

log_header "Running MicroServices Framework"
eval "$(keychain --eval id_rsa)"

log "Removing any current deployments"
ssh -t "$MANAGER_SSH" ~/remove-deployment.sh

log "Deploying common scripts"
rsync -e "ssh" -avz /mnt/d/msf/shared/scripts/docker-* "$MANAGER_SSH":/bin

/mnt/d/msf/core/scripts/development/run-task.sh