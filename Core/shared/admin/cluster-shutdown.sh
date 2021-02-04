#!/bin/bash

set -e

source ../scripts/core.env
source ../scripts/admin-functions.sh
# stop vault

snapshot_file=$(take_consul_snapshot)

while [[ ! -z $(docker-node-ps core_consul) ]]; do
    docker-service-ps core_consul consul leave
done


