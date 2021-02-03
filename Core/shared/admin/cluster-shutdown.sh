#!/bin/bash

set -e

source ../scripts/core.env
source ../scripts/admin-functions.sh

snapshot_file=$(take_consul_snapshot)
