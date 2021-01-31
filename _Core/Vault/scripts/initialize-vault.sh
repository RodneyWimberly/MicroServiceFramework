#!/bin/bash

set -e

run=(docker-compose exec)

until "${run[@]}" core_consul consul catalog services | grep -- '^vault$' > /dev/null; do
  sleep 3
done

count=$(docker exec core_consul consul catalog nodes -service=vault | wc -l)
((count=count-1))

if [ ! -f secret.txt ]; then
  touch secret.txt
  chmod 600 secret.txt
  "${run[@]}" core_vault vault operator init > secret.txt
fi
for x in $(eval echo {1..$count}); do
  awk '
  BEGIN {
    x=0
  }
  $0 ~ /Unseal Key/ {
    print $NF;
    x++;
    if(x>2) {
      exit
    }
  }' secret.txt | \
    xargs -n1 -- "${run[@]}" --index="$x" core_vault vault operator unseal
done

# set up initial authorization schemes for local infra
./apply-admin-policy.sh
./apply-all-policies.sh
./enable-docker-approle.sh
./enable-docker-secrets-store.sh
./set-auth-methods.sh
