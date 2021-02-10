#!/bin/sh

source ./vault-functions.sh

set -e
export VAULT_TOKEN="$(gawk '$0 ~ /Initial Root Token/ { print $NF;exit }' secret.txt)"
docker-service-exec core_vault "/bin/sh -c export VAULT_TOKEN=$VAULT_TOKEN && vault policy write admin - < policies/admin.hcl"
