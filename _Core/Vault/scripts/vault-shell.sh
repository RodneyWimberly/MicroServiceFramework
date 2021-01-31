#!/bin/bash
# DESCRIPTION
# Provides an interactive shell to type commands directly into Vault.  The
# session is pre-authenticated with an admin token.

source ./vault-functions.sh
set_vault_addr
set_vault_admin_token
trap 'revoke_self' EXIT

docker exec -e VAULT_TOKEN -e VAULT_ADDR core_vault /bin/sh
