#!/bin/bash
. ./vault-functions.sh

log "Applying admin policy to vault"
set -e
VAULT_TOKEN="$(gawk '$0 ~ /Initial Root Token/ { print $NF;exit }' secret.txt)"
export VAULT_TOKEN
./vault-exec policy write admin /usr/local/policies/admin.hcl