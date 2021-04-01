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

run() {
  local start_ts=$(get_seconds)
  log_header "Running MicroServices Framework"
  eval "$(keychain --eval id_rsa id_dsa)" >/dev/null 2>&1

  log "Removing any current deployments"
  while ! ssh -tt "$MANAGER_SSH" ~/remove-deployment.sh  >/dev/null 2>&1;
  do
    log_warning "Removing current deployments failed, retrying in 1 second"
    sleep 1
  done

  log "Deploying common scripts"
  while ! rsync -e "ssh" -avz /mnt/d/msf/shared/scripts/docker-* "$MANAGER_SSH":/bin >/dev/null 2>&1; 
  do
    log_warning "Deploying common scripts failed, retrying, retrying in 1 second"
    sleep 1
  done
  while ! rsync -e "ssh" -avz /mnt/d/msf/scripts/deployment/package/* "$MANAGER_SSH":~/msf  >/dev/null 2>&1; 
   do
    log_warning "Deploying common scripts failed, retrying, retrying in 1 second"
    sleep 1
  done

  /mnt/d/msf/core/scripts/development/run-task.sh
  if $START_LOG_STACK; then
    /mnt/d/msf/logs/scripts/development/run-task.sh
  fi
  log_success "MicroServices Framework deployment completed." "$start_ts"
}

run