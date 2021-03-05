#!/bin/bash

# shellcheck source=./vault-functions.sh
. "${CORE_SCRIPT_DIR}"/vault-functions.sh
add_path "${CORE_SCRIPT_DIR}"

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

log_detail "Initializing the Vault"
if [ ! -f secret.txt ]; then
  log_detail "Creating secret.txt"
  touch secret.txt
  chmod 600 secret.txt
  execute_vault_command operator init | remove_colors > secret.txt
  dos2unix secret.txt
fi

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
  xargs -n1 -- "${CORE_SCRIPT_DIR}"/vault-exec.sh operator unseal

apply_admin_policy
apply_all_policies
enable_docker_approle
enable_docker_secrets_store
set_auth_methods

log_detail "Vault is initialized"
