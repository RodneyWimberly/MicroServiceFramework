#!/bin/sh

source /usr/local/scripts/core.env
source /usr/local/scripts/colors.env
source /usr/local/scripts/logging-functions.sh
source /usr/local/scripts/hosting-functions.sh
source /usr/local/scripts/consul-functions.sh

function add_path() {
  export PATH=$1:${PATH}
  log "PATH has been updated to ${PATH} "
}

function keep_container_alive() {
  log_detail "Doing a wait loop to keep the container alive."
  exec sh -c 'while true ;do wait ;done'
}

