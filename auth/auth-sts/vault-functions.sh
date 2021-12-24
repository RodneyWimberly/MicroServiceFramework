#!/bin/bash

# --------------------------------------------------------------------------------------
# AUTH FUNCTIONS

apply_admin_policy() {
  log "Applying admin policy to vault"
  set -e
  VAULT_TOKEN="$(gawk '$0 ~ /Initial Root Token/ { print $NF;exit }' secret.txt)"
  export VAULT_TOKEN
  execute_vault_command policy write admin /usr/local/policies/admin.hcl
}

apply_all_policies() {
  log "Applying policies to vault"
  set_vault_admin_token

  for x in /usr/local/policies/*.hcl; do
    policy="${x##*/}"
    policy="${policy%.hcl}"
    log_detail "Applying ${x} policy to vault"
    execute_vault_command policy write "${policy}" "${x}"
  done
  revoke_self
}

enable_docker_approle() {
  log "Enabling docker approle to vault"
  set_vault_admin_token
  if execute_vault_command auth list | grep '^approle/'; then
    exit
  fi
  # enable approle auth method
  execute_vault_command auth enable approle

  # configure a role for docker infra based on source IP residing within the
  # docker network CIDR
  execute_vault_command write auth/approle/role/docker \
      role_id=docker \
      bind_secret_id=false \
      token_bound_cidrs=172.16.238.0/24,127.0.0.1/32 \
      token_ttl=15m \
      token_max_ttl=24h \
      token_no_default_policy=true \
      token_policies=docker

  revoke_self
}

enable_docker_secrets_store() {
  log "Enabling docker secrets store to vault"
  set_vault_admin_token

  log_detail "Checking if docker secret store is already enabled in vault"
  if execute_vault_command secrets list | grep '^docker/'; then
    exit
  fi

  log_detail 'Enable KV v2 secrets engine for docker infra.'
  execute_vault_command secrets enable -path=docker/ -version=2 kv

  revoke_self
}

get_admin_token() {
  set -e
  if [ "$#" -gt 1 ]; then
    echo 'ERROR: must pass zero or one arguments.' >&2
    exit 1
  fi

  VAULT_TOKEN="$(gawk '$0 ~ /Initial Root Token/ { print $NF;exit }' secret.txt)"
  export VAULT_TOKEN
  execute_vault_command token create -policy=admin -orphan -period="${1:-15m}" | remove_colors > token.txt
  dos2unix token.txt
  gawk '$1 == "token" { print $2; exit}' token.txt
}

set_auth_methods() {
  log "Setting auth methods in vault"
  set_vault_admin_token

  execute_vault_command write sys/auth/token/tune listing_visibility=unauth

  revoke_self
}

seal_vault() {
  log "Sealing vault"
  if [ ! -f secret.txt ]; then
    exit 0
  fi
  set_vault_admin_token 1m
  curl -H "X-Vault-Token: ${VAULT_TOKEN}" -H 'X-Vault-Request: true' --request PUT http://active.vault.service.consul:8200/v1/sys/seal
}

set_vault_addr() {
  VAULT_ADDR='http://active.vault.service.consul:8200'
  export VAULT_ADDR
}

set_vault_admin_token() {
  set_vault_addr
  if [ "$#" -gt 0 ]; then
    VAULT_TOKEN="$(get_admin_token "$@")"
  else
    VAULT_TOKEN="$(get_admin_token)"
  fi
  export VAULT_TOKEN
}

set_vault_infra_token() {
  VAULT_TOKEN="$(get_infra_token)"
  export VAULT_TOKEN
}

get_infra_token() {
  execute_vault_command write auth/approle/login role_id=docker | \
    awk '$1 == "token" { print $2; exit }'
}
revoke_self() {
  execute_vault_command token revoke -self >&2
}

# --------------------------------------------------------------------------------------
# UTILITY FUNCTIONS

execute_vault_command() {
  if is_docker_swarm_manager; then
    if [ $# -gt 0 ]; then
        if [[ $1 == *":"* ]]; then
            SERVICE="$1"
            shift
        else
            SERVICE="core_vault"
        fi
        docker-service-exec "$SERVICE" "/bin/sh -c 'rm -f entrypoint.sh && echo \"export VAULT_ADDR=$VAULT_ADDR VAULT_TOKEN=$VAULT_TOKEN\" >> entrypoint.sh && echo \"vault $*\" >> entrypoint.sh && /bin/sh entrypoint.sh'"
    else
        docker-service-exec core_vault "/bin/sh -c 'rm -f entrypoint.sh && echo \"export VAULT_ADDR=$VAULT_ADDR VAULT_TOKEN=$VAULT_TOKEN\" >> entrypoint.sh && echo \"/bin/sh\" >> entrypoint.sh && /bin/sh entrypoint.sh'"
    fi
  else
    vault "$@"
  fi
}

is_docker_swarm_manager() {
  set +u
  [ -d "${DEPLOYMENT_DIR}" ]
}

random_password() {
  chars='-;.~,.<>[]{}!@#$%^&*()_+=`0-9a-zA-Z'
  if [ -n "${1:-}" ]; then
    chars="${1}"
  fi
  tr -dc -- "${chars}" < /dev/urandom | head -c64;echo
}
