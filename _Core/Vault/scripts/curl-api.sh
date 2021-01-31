#!/bin/bash
# DESCRIPTION
#   This script sets up curl to talk with Vault using temporary admin
#   credentials.

source ./vault-functions.sh
if [ -z "${VAULT_TOKEN:-}" ]; then
  set_vault_admin_token 1m
  trap 'revoke_self' EXIT
fi
curl --socks5-hostname localhost:1080 \
  -H "X-Vault-Token: ${VAULT_TOKEN}" \
  -H 'X-Vault-Request: true' \
  "$@"
