#!/bin/bash
set -ueo pipefail
set +x

pushd ~/msf/core || exit 1

# shellcheck source=package/deployment-functions.sh
. ~/msf/core/deployment-functions.sh
# shellcheck source=package/core.env
. ~/msf/core/core.env

if [ -z "$(docker ps -q -f status=running --filter name=core_consul)" ]; then
  exit 0
fi

log_header "Shutting down vault cluster"
docker-service-exec core_vault /usr/local/scripts/seal-vault.sh
log_detail "Stopping all instances of vault"
docker service scale core_vault=0

log_header "Shutting down consul cluster"
log_detail "Taking a cluster snapshot"
SNAPSHOT_FILE=$(take_consul_snapshot "$@")
export SNAPSHOT_FILE

for SERVICE in $(docker-node-ps -a core_consul); do
  log_detail "$SERVICE leaving the cluster"
  docker-service-exec "$SERVICE" "consul leave"
done

set +e
log_detail "Removing stacks:"
docker stack rm "${CORE_STACK_NAME}"

log_detail "Waiting 15 seconds for stack deletion to finalize"
sleep 15

log_detail "Removing volumes:"
docker volume rm "${CORE_STACK_NAME}"_consul_data
docker volume rm "${CORE_STACK_NAME}"_portainer_data

log_detail "Waiting 5 seconds for volume deletion to finalize"
sleep 5

popd
