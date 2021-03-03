#!/bin/bash

# This script uses the Vault root token to create a temporary token associated
# with the admin policy.  This is better than using the root token for
# everything in order to perform initial scripting admin tasks.
. ./vault-functions.sh

set -e
if [ "$#" -gt 1 ]; then
  echo 'ERROR: must pass zero or one arguments.' >&2
  exit 1
fi

VAULT_TOKEN="$(gawk '$0 ~ /Initial Root Token/ { print $NF;exit }' secret.txt)"
export VAULT_TOKEN
./vault-exec token create -policy=admin -orphan -period="${1:-15m}" | remove_colors > token.txt
dos2unix token.txt
gawk '$1 == "token" { print $2; exit}' token.txt
