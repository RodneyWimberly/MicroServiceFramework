#!/bin/bash

cd ~/msf/vault
# shellcheck source=./vault-functions.sh
. ~/msf/vault/vault-functions.sh

# Setup environment
# Ignore non existent vars
# set -u
set -o nounset
# Terminate on command error
# set -e
set -o errexit
# Apply -e to pipe commands
set -o pipefail
# Output commands
# set -x
# set -oxtrace

log_detail "Checking for Vault service registration"
until docker-service-exec core_consul consul catalog services | grep -- '^vault' > /dev/null; do
  log_warning "Vault is not registered, waiting 5 seconds before retrying"
  sleep 5
done

# log "Get Vault service instance count"
# count=$(docker-service-exec core_consul consul catalog nodes -service=vault | wc -l)
# ((count=count-1))

log "Waiting 15 seconds for Vault to come up"
sleep 15

log_detail "Initializing the Vault"
if [ ! -f secret.txt ]; then
  log_detail "Creating secret.txt"
  touch secret.txt
  chmod 600 secret.txt
  ./vault-exec operator init | remove_colors > secret.txt
fi
dos2unix secret.txt
for SERVICE in $(docker-node-ps -a core_vault); do
  log_detail "Unsealing Vault"
  awk '
  BEGIN {
    x=0
  }
  $0 ~ /Unseal Key/ {
    print $NF;
    x++;
    if(x>2) {
      exit
    }
  }
  ' secret.txt | \
    xargs -n1 -- ./vault-exec "$SERVICE" operator unseal
done


apply_admin_policy
apply_all_policies
enable_docker_approle
enable_docker_secrets_store
set_auth_methods
