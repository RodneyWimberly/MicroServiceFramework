#!/bin/bash
set -ueo pipefail
set +x

if [ -d ~/msf ]; then
  # Docker Host
  SCRIPT_DIR=~/msf/core
elif [ -d /mnt/d/msf ]; then
  # Development
  SCRIPT_DIR=/mnt/d/msf/shared/scripts
else
  # Container
  SCRIPT_DIR=/usr/local/scripts
fi

# shellcheck source=../../../shared/scripts/core.env
. "${SCRIPT_DIR}"/core.env
# shellcheck source=../../../shared/scripts/colors.env
. "${SCRIPT_DIR}"/colors.env
# shellcheck source=../../../shared/scripts/colors.sh
. "${SCRIPT_DIR}"/colors.sh
# shellcheck source=../../../shared/scripts/logging-functions.sh
. "${SCRIPT_DIR}"/logging-functions.sh
# shellcheck source=../../../shared/scripts/hosting-functions.sh
. "${SCRIPT_DIR}"/hosting-functions.sh
# shellcheck source=../../../shared/scripts/consul-functions.sh
. "${SCRIPT_DIR}"/consul-functions.sh


deploy_stack() {
  COMPOSE_FILE=~/msf/$1/docker-compose.yml
  if [ -f "${COMPOSE_FILE}" ]; then
    log_detail "Deploying $COMPOSE_FILE as $1 Stack to Swarm"
    docker stack deploy --compose-file="$COMPOSE_FILE" "$1"
  else
    log_error "Unable to locate file $COMPOSE_FILE"
    exit 1
  fi
}

create_network() {
  log_detail "Creating attachable overlay network '$1'"
  if [ $# -eq 1 ]; then
    docker network create --driver=overlay --attachable "$1"
  else
    if [ $# -eq 2 ]; then
      docker network create --driver=overlay --attachable --subnet="$2" "$1"
    else
      docker network create --driver=overlay --attachable --subnet="$2" --ip-range="$3" "$1"
    fi
  fi
}

pushd() {
  dirname=$1
  DIR_STACK="$dirname ${DIR_STACK:-$PWD' '}"
  cd "${dirname:?"missing directory name."}" || exit 1
  echo "$DIR_STACK"
}

popd() {
  DIR_STACK=${DIR_STACK#* }
  cd "${DIR_STACK%% *}" || exit 1
  echo "$PWD"
}
