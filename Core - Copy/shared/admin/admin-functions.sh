#!/bin/sh

if [[ -d ~/msf ]]; then
  SCRIPT_DIR=~/msf/Core/shared/scripts
elif [[ -d /mnt/d/em ]]; then
  SCRIPT_DIR=/mnt/d/em/Core/shared/scripts
elif [[ -d /d/em ]]; then
  SCRIPT_DIR=/d/em/Core/shared/scripts
else
  SCRIPT_DIR=/usr/local/scripts
fi

source "${SCRIPT_DIR}"/core.env
source "${SCRIPT_DIR}"/colors.env
source "${SCRIPT_DIR}"/colors.sh
source "${SCRIPT_DIR}"/logging-functions.sh
source "${SCRIPT_DIR}"/hosting-functions.sh
source "${SCRIPT_DIR}"/consul-functions.sh

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
