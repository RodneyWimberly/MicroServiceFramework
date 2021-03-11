#!/bin/sh

if [ -d ~/msf ]; then
  # Deployment Environment
  SCRIPT_DIR=.
elif [ -d /mnt/d/msf ]; then
  # Development Environment
  SCRIPT_DIR=/mnt/d/msf/shared/scripts
else
  # Container Environment
  SCRIPT_DIR=/usr/local/scripts
fi

# shellcheck source=./color-functions.sh
. $SCRIPT_DIR/color-functions.sh
# shellcheck source=./logging-functions.sh
. $SCRIPT_DIR/logging-functions.sh
# shellcheck source=./hosting-functions.sh
. $SCRIPT_DIR/hosting-functions.sh
# shellcheck source=./consul-functions.sh
. $SCRIPT_DIR/consul-functions.sh
# shellcheck source=./vault-functions.sh
. $SCRIPT_DIR/vault-functions.sh