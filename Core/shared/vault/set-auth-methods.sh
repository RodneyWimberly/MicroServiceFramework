#!/bin/bash

. ./vault-functions.sh

log "Setting auth methods in vault"
set_vault_admin_token

execute_vault_command write sys/auth/token/tune listing_visibility=unauth

revoke_self
