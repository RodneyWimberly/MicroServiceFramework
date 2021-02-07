#!/bin/bash

set -e
docker-service-exec.sh core_consul consul catalog services | grep -- '^vault$'
docker-service-exec.sh core_consul consul catalog nodes -service=vault | wc -l
docker-service-exec.sh --index=1 core_vault /bin/sh
run_consul=(docker-service-exec.sh -T core_consul consul)
run_vault=(docker-service-exec.sh -T core_vault)

until "${run_consul[@]}" catalog services | grep -- '^vault$' > /dev/null; do
  sleep 3
done

count=$("${run_consul[@]}" catalog nodes -service=vault | wc -l)
((count=count-1))

if [ ! -f secret.txt ]; then
  touch secret.txt
  chmod 600 secret.txt
  "${run_vault[@]}" operator init > secret.txt
fi
for x in $(eval echo {1..$count}); do
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
    xargs -n1 -- "${run[@]}" --index="$x" vault vault operator unseal
done

# set up initial authorization schemes for local infra
./scripts/apply-admin-policy.sh
./scripts/apply-all-policies.sh
./scripts/enable-docker-approle.sh
./scripts/enable-docker-secrets-store.sh
./scripts/set-auth-methods.sh
