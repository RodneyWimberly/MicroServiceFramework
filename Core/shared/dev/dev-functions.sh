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
source "${SCRIPT_DIR}"/stacks.env
source "${SCRIPT_DIR}"/colors.sh
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
  image_name=$1
  current_dir=$pwd

  cd ./$image_name

  log_detail "Building image $image_owner/$image_name"
  docker build -t $image_owner/$image_name .

  log_detail "Adding tag $image_owner/$image_name:$image_tag to image $image_owner/$image_name"
  docker tag $image_owner/$image_name $image_owner/$image_name:$image_tag

  log_detail "Pushing image $image_owner/$image_name:$image_tag"
  docker push $image_owner/$image_name:$image_tag

  cd $current_dir
}
