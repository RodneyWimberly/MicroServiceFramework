#!/bin/bash
set -ueo pipefail
set +x

# shellcheck source=../../../shared/scripts/deployment-functions.sh
. ~/msf/deployment-functions.sh
# shellcheck source=package/core.env
. ~/msf/core/core.env

push_dir ~/msf/core || exit 1  >/dev/null 2>&1

if ! docker ps -f status=running --filter name=core_consul | grep -- '^consul' > /dev/null; then
  log_detail "Consul not running, continueing deployment"
  exit 0
fi
# if [ -z "$(docker ps -q -f status=running --filter name=core_consul)" ]; then
#   exit 0
# fi

log_header "Shutting down consul cluster"

log "Sealing the vault cluster"
set +e
docker-service-exec core_vault /usr/local/scripts/seal-vault.sh

log "Taking a cluster snapshot"
SNAPSHOT_FILE=$(take_consul_snapshot "$@")
export SNAPSHOT_FILE

log "Making each instance leave the cluster"
for SERVICE in $(docker-node-ps -a core_consul); do
  log_detail "$SERVICE leaving the cluster"
  docker-service-exec "$SERVICE" "consul leave"
done

set -e
log "Removing stacks:"
docker stack rm "${CORE_STACK_NAME}"  >/dev/null 2>&1

remove_volume "${CORE_STACK_NAME}"_consul_data
remove_volume "${CORE_STACK_NAME}"_portainer_data

# log "Removing networks:"
# remove_network admin_network

pop_dir || exit 1
