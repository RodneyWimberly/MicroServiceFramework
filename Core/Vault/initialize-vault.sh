#!/bin/bash
  # Vault Health HTTP Status Codes:
  # 200 if initialized, unsealed, and active
  # 429 if unsealed and standby
  # 472 if disaster recovery mode replication secondary and active
  # 473 if performance standby
  # 501 if not initialized
  # 503 if sealed

# shellcheck source=./common-functions.sh
. "${CORE_SCRIPT_DIR}"/common-functions.sh

add_path "${CORE_SCRIPT_DIR}"


log "Initializing, Unsealing, and Configuring the Vault"
if [ -f secret.txt ]; then
  VAULT_INITIALIZED=true
  log_detail "The vault is initialized"
else
  VAULT_INITIALIZED=false
  log_detail "The vault is not initialized"
fi
if ! $VAULT_INITIALIZED; then
  log "Waiting for a valid Vault health response"
  until [ "$(curl -o /dev/null -s -w "%{http_code}" http://localhost:8200/v1/sys/health)" -eq 501 ]; 
  do
    sleep 1
  done
  log_success "Vault is sealed and responding"

  log "Initializing Vault"
  log_detail "Creating secret.txt"
  touch secret.txt
  chmod 600 secret.txt
  until execute_vault_command operator init | remove_colors > secret.txt;
  do
    sleep 1
  done
  dos2unix secret.txt
fi

if  [ "$(curl -o /dev/null -s -w "%{http_code}" http://localhost:8200/v1/sys/health)" -eq 503 ]; then
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
  fi

if ! $VAULT_INITIALIZED; then
  apply_admin_policy
  apply_all_policies
  enable_docker_approle
  enable_docker_secrets_store
  set_auth_methods
fi

log_success "Vault is initialized with root token: $(gawk '$0 ~ /Initial Root Token/ { print $NF;exit }' secret.txt)"

