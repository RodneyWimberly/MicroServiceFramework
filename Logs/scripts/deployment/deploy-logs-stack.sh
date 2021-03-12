#!/bin/bash
# Deploys the logs stack to a Docker Swarm

set -ueo pipefail
set +x

pushd ~/msf/logs || exit 1

# shellcheck source=../../../shared/scripts/deployment-functions.sh
. ~/msf/deployment-functions.sh
# shellcheck source=../logs.env
. ~/msf/logs/logs.env

eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa
log_header "Logs: Stack Deployment"

deploy_stack "${LOGS_STACK_NAME}"

log_detail "Waiting 15 seconds for stack to come up"
sleep 15

log "Log Deployment completed successfully!"
popd