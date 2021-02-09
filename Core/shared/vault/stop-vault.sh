#!/bin/bash

set -ex

source ./vault-functions.sh
set_vault_admin_token 1m

./scripts/curl-api.sh \
  --request PUT \
  http://active.vault.service.consul:8200/v1/sys/seal

docker service scale core_vault=0
