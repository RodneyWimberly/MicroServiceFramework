#!/bin/bash
set -ueo pipefail
set +x

# shellcheck source=../../../shared/scripts/development-functions.sh
. /mnt/d/msf/shared/scripts/development-functions.sh

log_header "Running MicroServices Framework Core Stack"
set +e

log_detail "Copying core deployment package to Docker swarm manager"
rsync -e "ssh" -avz /mnt/d/msf/core/scripts/deployment/package/* "$MANAGER_SSH":~/msf/core

log_detail "Running core deployment package on Docker swarm manager"
ssh -tt "$MANAGER_SSH" "~/msf/core/deploy-cluster.sh $SHUTDOWN_CORE_CLUSTER"