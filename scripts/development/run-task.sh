#!/bin/bash
# MicroServices Framework Root "Run" Task
# This is used as the "Run" task in VS Code (what is run when you press F5 or choose one of the run options)
# This will handle "deploying" all items that are needed to run items defined at the root level
# The will also call the associated run task for each Stack below the root.
# '/scripts/development.env' defines the available build/run/deploy options
set -ueo pipefail
set +x

# shellcheck source=../../shared/scripts/development-functions.sh
. /mnt/d/msf/shared/scripts/development-functions.sh

log_header "Running MicroServices Framework"
eval "$(keychain --eval id_rsa id_dsa)"

log "Removing any current deployments"
ssh -tt "$MANAGER_SSH" ~/remove-deployment.sh

log "Deploying common scripts"
rsync -e "ssh" -avz /mnt/d/msf/shared/scripts/docker-* "$MANAGER_SSH":/bin
rsync -e "ssh" -avz /mnt/d/msf/scripts/deployment/package/* "$MANAGER_SSH":~/msf

/mnt/d/msf/core/scripts/development/run-task.sh
if $START_LOG_STACK; then
  /mnt/d/msf/logs/scripts/development/run-task.sh
fi

log "MicroServices Framework deployment completed successfully"