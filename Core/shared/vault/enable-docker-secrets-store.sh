#!/bin/sh

source ./vault-functions.sh

set_vault_admin_token

if execute_vault_command secrets list | grep '^docker/'; then
  exit
fi

echo 'Enable KV v2 secrets engine for docker infra.'
execute_vault_command secrets enable -path=docker/ -version=2 kv

revoke_self
