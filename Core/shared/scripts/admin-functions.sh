#!/bin/sh

if [[ -d ~/msf ]]; then
  SCRIPT_DIR=~/msf/Core/shared/scripts
elif [[ -d /mnt/d/em ]]; then
  SCRIPT_DIR=/mnt/d/em/Core/shared/scripts
else
  SCRIPT_DIR=/usr/local/scripts
fi

source "${SCRIPT_DIR}"/core.env
source "${SCRIPT_DIR}"/logging-functions.sh
source "${SCRIPT_DIR}"/hosting-functions.sh
source "${SCRIPT_DIR}"/consul-functions.sh

function curl_api() {
  curl --socks5-hostname localhost:1080
  "$@"
}

function build_and_deploy_image() {
  if [[ -z $2 ]]; then
    image_tag=dev
  else
    image_tag=$2
  fi
  image_owner=microserviceframework
  cd ./$1
  log_detail "Building image $image_owner/$1"
  docker build -t $image_owner/$1 .
  log_detail "Adding tag $image_owner/$1:$image_tag to image $image_owner/$1"
  docker tag $image_owner/$1 $image_owner/$1:$image_tag
  log_detail "Pushing image $image_owner/$1:$image_tag"
  docker push $image_owner/$1:$image_tag
  cd ..
}

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
