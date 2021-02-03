#!/bin/sh

source ./core.env
source ./logging-functions.sh
source ./hosting-functions.sh
source ./consul-functions.sh

function add_path() {
  export PATH=$1:${PATH}
  log "PATH has been updated to ${PATH} "
}

