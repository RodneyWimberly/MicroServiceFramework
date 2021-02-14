#!/bin/sh


if [[ -d ~/msf ]]; then
  SCRIPT_DIR=~/msf/Core/shared/scripts
elif [[ -d /mnt/d/em ]]; then
  SCRIPT_DIR=/mnt/d/em/Core/shared/scripts
elif [[ -d /d/em ]]; then
  SCRIPT_DIR=/d/em/Core/shared/scripts
else
  SCRIPT_DIR=/usr/local/scripts
fi

source "${SCRIPT_DIR}"/core.env
source "${SCRIPT_DIR}"/colors.env
source "${SCRIPT_DIR}"/colors.sh
source "${SCRIPT_DIR}"/logging-functions.sh
source "${SCRIPT_DIR}"/hosting-functions.sh
source "${SCRIPT_DIR}"/consul-functions.sh

VAULT_SCRIPT_DIR="~/msf/Core/shared/vault"
export VAULT_SCRIPT_DIR

# --------------------------------------------------------------------------------------
# AUTH FUNCTIONS

function set_vault_addr() {
  VAULT_ADDR='http://active.vault.service.consul:8200'
  export VAULT_ADDR
}

function set_vault_admin_token() {
  if [ "$#" -gt 0 ]; then
    VAULT_TOKEN="$(get_admin_token "$@")"
  else
    VAULT_TOKEN="$(get_admin_token)"
  fi
  export VAULT_TOKEN
}

function set_vault_infra_token() {
  VAULT_TOKEN="$(get_infra_token)"
  export VAULT_TOKEN
}

function get_admin_token() (
  cd_vault
  ./get-admin-token.sh "$@"
)

function get_infra_token() (
  execute_vault_command write auth/approle/login role_id=docker | \
    awk '$1 == "token" { print $2; exit }'
)

function revoke_self() (
  execute_vault_command token revoke -self >&2
)

# --------------------------------------------------------------------------------------
# UTILITY FUNCTIONS

function execute_vault_command() (
  if vault_dir_available; then
    cd_vault
    docker-service-exec core_vault "/bin/sh -c 'rm -f entrypoint.sh && echo \"export VAULT_TOKEN="$VAULT_TOKEN" VAULT_ADDR="$VAULT_ADDR"\" >> entrypoint.sh && echo \"vault '$@'\" >> entrypoint.sh && /bin/sh entrypoint.sh'"
  else
    "vault $@"
  fi
)

function vault_dir_available() {
  [ -d "${VAULT_SCRIPT_DIR}" ]
}

function cd_vault() {
  cd "${VAULT_SCRIPT_DIR}"
}

function random_password() {
  local chars='-;.~,.<>[]{}!@#$%^&*()_+=`0-9a-zA-Z'
  if [ -n "${1:-}" ]; then
    chars="${1}"
  fi
  tr -dc -- "${chars}" < /dev/urandom | head -c64;echo
}
