#!/bin/bash
# Deploys the logs stack to a Docker Swarm

set -ueo pipefail

pushd ~/msf/logs || exit 1  >/dev/null 2>&1

# shellcheck source=../../../shared/scripts/deployment-functions.sh
. ~/msf/deployment-functions.sh
# shellcheck source=../logs.env
. ~/msf/logs/logs.env

log_header "Logs: Stack Deployment"

log "Setting up SSH Keys"
eval "$(ssh-agent -s)" >/dev/null 2>&1
ssh-add ~/.ssh/id_rsa >/dev/null 2>&1

log "Deploying to Swarm"
deploy_stack "${LOGS_STACK_NAME}" >/dev/null 2>&1

log_success "Log Deployment completed successfully!"
popd  >/dev/null 2>&1