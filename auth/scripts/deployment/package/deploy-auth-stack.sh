#!/bin/bash
# Deploys the auth stack to a Docker Swarm

set -ueo pipefail

pushd ~/msf/auth || exit 1  >/dev/null 2>&1

# shellcheck source=../../../shared/scripts/deployment-functions.sh
. ~/msf/deployment-functions.sh
# shellcheck source=../auth.env
. ~/msf/auth/auth.env

log_header "Auth: Stack Deployment"

log "Setting up SSH Keys"
eval "$(ssh-agent -s)" >/dev/null 2>&1
ssh-add ~/.ssh/id_rsa >/dev/null 2>&1

log "Deploying to Swarm"
deploy_stack "${AUTH_STACK_NAME}" >/dev/null 2>&1

log_success "Auth: Stack Deployment completed successfully!"
popd  >/dev/null 2>&1