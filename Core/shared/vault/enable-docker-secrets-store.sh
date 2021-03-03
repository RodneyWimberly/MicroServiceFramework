#!/bin/bash
. ./vault-functions.sh

log "Enabling docker secrets store to vault"
set_vault_admin_token

log_detail "Checking if docker secret store is already enabled in vault"
if execute_vault_command secrets list | grep '^docker/'; then
  exit
fi

log_detail 'Enable KV v2 secrets engine for docker infra.'
execute_vault_command secrets enable -path=docker/ -version=2 kv

revoke_self
