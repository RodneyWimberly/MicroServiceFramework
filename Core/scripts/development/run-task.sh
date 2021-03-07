#!/bin/bash
set -ueo pipefail
set +x

# shellcheck source=../../../scripts/development/development.env
. /mnt/d/msf/scripts/development/development.env
# shellcheck source=../../../scripts/development/development-functions.sh
. /mnt/d/msf/scripts/development/development-functions.sh

log_header "Running MicroServices Framework Core Stack"
set +e

log_detail "Copying Core scripts to Swarm Manager"
rsync -e "ssh" -avz /mnt/d/msf/core/scripts/deployment/* "$MANAGER_SSH":~/msf/core

log_detail "Copying Core stack definition to Swarm Manager"
rsync -e "ssh" -avz /mnt/d/msf/core/docker-compose.yml "$MANAGER_SSH":~/msf/core

log_detail "Running Core Stack Deployment on Swarm Manager"
ssh -t "$MANAGER_SSH" chmod -R 755 ~/msf/core/*
ssh -t "$MANAGER_SSH" ~/msf/core/deploy-cluster.sh $SHUTDOWN_CORE_CLUSTER