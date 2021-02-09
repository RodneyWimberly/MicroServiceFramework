#!/bin/sh

if [[ -d ~/msf ]]; then
  SCRIPT_DIR=~/msf/Core/shared/scripts
elif [[ -d /mnt/d/em ]]; then
  SCRIPT_DIR=/mnt/d/em/Core/shared/scripts
else
  SCRIPT_DIR=/usr/local/scripts
fi

source "${SCRIPT_DIR}"/core.env
source "${SCRIPT_DIR}"/colors.env
source "${SCRIPT_DIR}"/logging-functions.sh
source "${SCRIPT_DIR}"/hosting-functions.sh
source "${SCRIPT_DIR}"/consul-functions.sh

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
