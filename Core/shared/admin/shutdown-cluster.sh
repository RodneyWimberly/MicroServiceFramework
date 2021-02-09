#!/bin/bash

set -e

source ./admin-functions.sh
../vault/stop-vault.sh

SNAPSHOT_FILE=$(take_consul_snapshot)

for SERVICE in $(docker-node-ps -a core_consul); do
  docker-service-exec $SERVICE "consul leave"
done


