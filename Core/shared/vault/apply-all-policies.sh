#!/bin/bash
. ./vault-functions.sh

log "Applying policies to vault"
set_vault_admin_token

log_detail "Applying admin policy to vault"
./vault-exec policy write admin /usr/local/policies/admin.hcl
log_detail "Applying docker policy to vault"
./vault-exec policy write docker /usr/local/policies/docker.hcl
revoke_self
