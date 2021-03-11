#!/bin/bash
set -ueo pipefail
set +x

# shellcheck source=../../../shared/scripts/development-functions.sh
. /mnt/d/msf/shared/scripts/development-functions.sh

log_header "Running MicroServices Framework Logs Stack"
set +e

log_detail "Copying logs deployment package to Docker swarm manager"
rsync -e "ssh" -avz /mnt/d/msf/logs/scripts/deployment/package/* "$MANAGER_SSH":~/msf/logs

log_detail "Running core deployment package on Docker swarm manager"
# ssh -t "$MANAGER_SSH" chmod -R 755 ~/msf/logs/*deploy-log-stack.sh 
ssh -t "$MANAGER_SSH" ~/msf/logs/