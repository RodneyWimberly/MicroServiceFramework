#!/bin/bash
clear 
set -ue
set +x

# shellcheck source=../../../shared/scripts/development-functions.sh
. /mnt/d/msf/shared/scripts/development-functions.sh

run () {
    local start_ts=$(date +%s)
    log_header "Configuring Swarm Manager"
    log "Configuring SSH Keys"
    eval "$(keychain --eval id_rsa)"  >/dev/null 2>&1
    log "Copying files to Swarm Manager"
    log_detail "Copying scripts"
    envsubst < /mnt/d/msf/scripts/deployment/configure-docker-node-for-deployment.template > /mnt/d/msf/scripts/deployment/configure-docker-node-for-deployment.sh
    set +e
    scp /mnt/d/msf/scripts/deployment/*.sh $MANAGER_SSH:~/ >/dev/null 2>&1
    log_detail "Copying environment configuration"
    scp ~/.bashrc $MANAGER_SSH:~/.bashrc >/dev/null 2>&1
    set -e
    log "Deployed Starting Remote Shell on Swarm Manager"
    ssh -t $MANAGER_SSH "chmod -R 755 ~/* && ~/configure-docker-node-for-deployment.sh"
    local end_ts=$(date +%s)
    local seconds=$((end_ts - start_ts))
    log_success "Swarm Manager configuration completed in $seconds seconds"
}

run
