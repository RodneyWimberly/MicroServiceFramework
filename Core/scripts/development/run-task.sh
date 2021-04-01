#!/bin/bash
set -ueo pipefail
set +x

# shellcheck source=../../../shared/scripts/development-functions.sh
. /mnt/d/msf/shared/scripts/development-functions.sh

start_ts=$(get_seconds)
log_header "Running MicroServices Framework Core Stack"
set +e

log "Copying core deployment package to Docker swarm manager"
until rsync -e "ssh" -avz /mnt/d/msf/core/scripts/deployment/package/* "$MANAGER_SSH":~/msf/core  >/dev/null 2>&1;
do
  log_warning "Deploying core scripts failed, retrying, retrying in 1 second"
  sleep 1
done
log_success "Core script deployment" "$start_ts"

log_detail "Running core deployment package on Docker swarm manager"
ssh -tt "$MANAGER_SSH" "~/msf/core/deploy-cluster.sh $SHUTDOWN_CORE_CLUSTER"