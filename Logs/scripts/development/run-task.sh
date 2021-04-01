#!/bin/bash
set -ueo pipefail
set +x

# shellcheck source=../../../shared/scripts/development-functions.sh
. /mnt/d/msf/shared/scripts/development-functions.sh

log_header "Running MicroServices Framework Logs Stack"
set +e

log "Copying logs deployment package to Docker swarm manager"
rsync -e "ssh" -avz /mnt/d/msf/logs/scripts/deployment/package/* "$MANAGER_SSH":~/msf/logs  >/dev/null 2>&1

log "Running logs deployment package on Docker swarm manager"
ssh -tt "$MANAGER_SSH" ~/msf/logs/deploy-logs-stack.sh 