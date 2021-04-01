#!/bin/bash
set -ueo pipefail
set +x

# shellcheck source=./common-functions.sh
. ~/msf/common-functions.sh

push_dir() {
  log_detail "Pushing $1 to the directory stack"
  pushd "$1" >/dev/null 2>&1
}

pop_dir() {
  log_detail "Popping directory off of the directory stack"
  popd >/dev/null 2>&1
}

remove_volume() {
  log "Removing volume $1"
  until docker volume rm -f "$1"; do 
    log_warning "Removal of $1 failed. Retrying in 1 second"
    sleep 1
  done
  log_success "Volume $1 removed"
}

remove_network() {
  log_detail "Removing network $1"
  while ! docker network rm "$1" >/dev/null 2>&1;
  do
    log_warning "Removal of $1 failed. Retrying in 5 second"
    sleep 5
  done
  log_success "Network $1 was removed"
}

deploy_stack() {
  COMPOSE_FILE=~/msf/"$1"/docker-compose.yml
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

# pushd() {
#   dirname=$1
#   DIR_STACK="$dirname ${DIR_STACK:-$PWD' '}"
#   cd "${dirname:?"missing directory name."}" || exit 1
#   echo "$DIR_STACK"
# }

# popd() {
#   DIR_STACK=${DIR_STACK#* }
#   cd "${DIR_STACK%% *}" || exit 1
#   echo "$PWD"
# }