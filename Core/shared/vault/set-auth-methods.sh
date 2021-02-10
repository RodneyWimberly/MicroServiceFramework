#!/bin/sh
source ./vault-functions.sh

set_vault_admin_token

execute_vault_command write sys/auth/token/tune listing_visibility=unauth

revoke_self
