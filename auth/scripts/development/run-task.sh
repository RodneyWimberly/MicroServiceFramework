#!/bin/bash
set -ueo pipefail
set +x

# shellcheck source=../../../shared/scripts/development-functions.sh
. /mnt/d/msf/shared/scripts/development-functions.sh

log_header "Running MicroServices Framework Auth Stack"
set +e

log "Copying auth deployment package to Docker swarm manager"
rsync -e "ssh" -avz /mnt/d/msf/auth/scripts/deployment/package/* "$MANAGER_SSH":~/msf/auth  >/dev/null 2>&1

log "Running auth deployment package on Docker swarm manager"
ssh -tt "$MANAGER_SSH" ~/msf/auth/deploy-auth-stack.sh 