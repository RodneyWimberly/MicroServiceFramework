#!/bin/sh


cd ~/msf/vault
. vault-functions.sh

log "Initializing the Vault"
set -e

if [ ! -f secret.txt ]; then
  touch secret.txt
  chmod 600 secret.txt
  docker-service-exec core_vault vault operator init > secret.txt
fi

for SERVICE in $(docker-node-ps -a core_vault); do
  awk '
  BEGIN {
    x=0
  }
  $0 ~ /Unseal Key/= {
    print $NF;
    x++;
    if(x>2) {
      exit
    }
  }' secret.txt | \
    xargs -n1 -- docker-service-exec $SERVICE "vault operator unseal"
done

# set up initial authorization schemes for local infra
# ./apply-admin-policy.sh
# ./apply-all-policies.sh
# ./enable-docker-approle.sh
# ./enable-docker-secrets-store.sh
# ./set-auth-methods.sh
