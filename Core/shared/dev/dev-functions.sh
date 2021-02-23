#!/bin/bash
if [ -d ~/msf ]; then
  SCRIPT_DIR=~/msf/scripts
elif [ -d /mnt/d/em ]; then
  SCRIPT_DIR=/mnt/d/em/Core/shared/scripts
else
  SCRIPT_DIR=/usr/local/scripts
fi

# shellcheck source=../scripts/core.env
. "${SCRIPT_DIR}"/core.env
# shellcheck source=../scripts/colors.env
. "${SCRIPT_DIR}"/colors.env
# shellcheck source=../scripts/colors.sh
. "${SCRIPT_DIR}"/colors.sh
# shellcheck source=../scripts/logging-functions.sh
. "${SCRIPT_DIR}"/logging-functions.sh
# shellcheck source=../scripts/hosting-functions.sh
. "${SCRIPT_DIR}"/hosting-functions.sh
# shellcheck source=../scripts/consul-functions.sh
. "${SCRIPT_DIR}"/consul-functions.sh

build_and_deploy_image() {
  if [ -z $2 ]; then
    image_tag=dev
  else
    image_tag=$2
  fi
  image_owner=microserviceframework
  image_name=$1

  pushd ./"$image_name" || exit 1

  if [ $# -gt 2 ]; then
    log_detail "Building image $image_owner/$image_name with build-args $3"
    docker build  --build-arg "$3" --tag "$image_owner/$image_name" .
  else
    log_detail "Building image $image_owner/$image_name"
    docker build -t "$image_owner/$image_name" .
  fi

  log_detail "Adding tag $image_owner/$image_name:$image_tag to image $image_owner/$image_name"
  docker tag "$image_owner/$image_name" "$image_owner/$image_name:$image_tag"

  log_detail "Pushing image $image_owner/$image_name:$image_tag"
  docker push "$image_owner/$image_name:$image_tag"

  popd || exit 1
}

link_file() {
  if [ ! -f "$1" ]; then
    log_error "File $1 cannot be located"
    exit 1
  fi
  source_file=$1
  target_file=$2
  log_detail "Linking source file ${source_file} to target file ${target_file}"
  ln -f "$source_file" "$target_file"
}
