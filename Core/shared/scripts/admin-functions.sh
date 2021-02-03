#!/bin/sh

source ~/msf/core/shared/scripts/core.env
source ~/msf/core/shared/scripts/logging-functions.sh
source ~/msf/core/shared/scripts/hosting-functions.sh
source ~/msf/core/shared/scripts/consul-functions.sh

function cd_admin ()
{
    cd ~/msf/core/shared/admin
}

function deploy_stack() {
  log_detail "Deploying $1 Stack to Swarm"
  docker stack deploy --compose-file=../../"$1"-stack.yml "$1"
}

function create_network() {
  log_detail "Creating attachable overlay network '$1'"
  if [[ -z "$2" ]]; then
    docker network create --driver=overlay --attachable $1
  else
    docker network create --driver=overlay --attachable --subnet=$2 $1
  fi
}

# These functions only work for tasks/services deployed to this node (not other nodes in the SWARM, use SSH)
function service_exec() {
  docker exec $(docker ps -q -f name=$1) $2
}

function service_shell() {
  docker exec -it $(docker ps -q -f name=$1) /bin/sh
}
