#!/bin/bash
set -ueo pipefail
set +x

# shellcheck source=../../scripts/development.env
. /mnt/d/msf/scripts/development.env
# shellcheck source=./common-functions.sh
. /mnt/d/msf/shared/scripts/common-functions.sh

build_and_deploy_image() {
  image_tag=${2:-dev}
  image_owner=microserviceframework
  image_name=$1
  if [ -z "$image_name" ]; then
    exit 1
  fi

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

link_common_functions() {
  LINK_DIR=$1
  if [ -z "$LINK_DIR" ]; then
    log_error "You must pass the path to the link folder"
    exit 1
  fi
  if [ ! -d "$LINK_DIR" ]; then
    log_error "Link folder $LINK_DIR does not exist"
    exit 1
  fi
  log_info "Linking shared scripts to folder $LINK_DIR"
  link_file $SHARED_SCRIPTS/color-functions.sh $LINK_DIR/color-functions.sh
  link_file $SHARED_SCRIPTS/common-functions.sh $LINK_DIR/common-functions.sh
  link_file $SHARED_SCRIPTS/consul-functions.sh $LINK_DIR/consul-functions.sh
  link_file $SHARED_SCRIPTS/hosting-functions.sh $LINK_DIR/hosting-functions.sh
  link_file $SHARED_SCRIPTS/json-functions.sh $LINK_DIR/json-functions.sh
  link_file $SHARED_SCRIPTS/logging-functions.sh $LINK_DIR/logging-functions.sh
  link_file $SHARED_SCRIPTS/vault-functions.sh $LINK_DIR/vault-functions.sh
  link_file $SHARED_SCRIPTS/wait-for-it.sh $LINK_DIR/wait-for-it.sh
  link_file $SHARED_CONFIG/resolv.conf $LINK_DIR/resolv.conf
  link_file $SHARED_CONFIG/rsyslog.conf $LINK_DIR/rsyslog.conf
  link_file $SHARED_CONFIG/consul-service.json $LINK_DIR/consul-service.json
}

link_certs() {
    LINK_DIR=$1
  if [ -z "$LINK_DIR" ]; then
    log_error "You must pass the path to the link folder"
    exit 1
  fi
  if [ ! -d "$LINK_DIR" ]; then
    log_error "Link folder $LINK_DIR does not exist"
    exit 1
  fi
  log_info "Linking shared certs to folder $LINK_DIR"
  link_file $SHARED_CERTS/consul-agent-ca.pem $LINK_DIR/consul-agent-ca.pem
  link_file $SHARED_CERTS/docker-client-consul-0.pem $LINK_DIR/docker-client-consul-0.pem
  link_file $SHARED_CERTS/docker-client-consul-0-key.pem $LINK_DIR/docker-client-consul-0-key.pem
  link_file $SHARED_CERTS/docker-server-consul-0.pem $LINK_DIR/docker-server-consul-0.pem
  link_file $SHARED_CERTS/docker-server-consul-0-key.pem $LINK_DIR/docker-server-consul-0-key.pem
}
