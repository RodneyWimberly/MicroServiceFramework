#!/bin/sh

if [ -d ~/msf ]; then
  SCRIPT_DIR=~/msf/Core/shared/scripts
elif [ -d /mnt/d/em ]; then
  SCRIPT_DIR=/mnt/d/em/Core/shared/scripts
else
  SCRIPT_DIR=/usr/local/scripts
fi

. "${SCRIPT_DIR}"/core.env
. "${SCRIPT_DIR}"/colors.env
. "${SCRIPT_DIR}"/logging-functions.sh
. "${SCRIPT_DIR}"/hosting-functions.sh
. "${SCRIPT_DIR}"/consul-functions.sh

deploy_stack() {
  log_detail "Deploying $1 Stack to Swarm"
  docker stack deploy --compose-file=../../"$1"-stack.yml "$1"
}

create_network() {
  log_detail "Creating attachable overlay network '$1'"
  if [ -z "$2" ]; then
    docker network create --driver=overlay --attachable $1
  else
    docker network create --driver=overlay --attachable --subnet=$2 $1
  fi
}
