#!/bin/bash

# DESCRIPTION
# Provides an interactive shell to type commands directly into Vault.  The
# session is pre-authenticated with an admin token.

. ./vault-functions.sh
set_vault_addr
# shellcheck disable=SC2119
set_vault_admin_token
trap 'revoke_self' EXIT

execute_vault_command
