#!/bin/sh

if [ -d ~/msf ]; then
  # Deployment Environment
  SCRIPT_DIR=~/msf/logs
elif [ -d /mnt/d/msf ]; then
  # Development Environment
  SCRIPT_DIR=/mnt/d/msf/shared/scripts
else
  # Container Environment
  SCRIPT_DIR=/usr/local/scripts
fi

# shellcheck source=../../shared/scripts/common-functions.sh
. $SCRIPT_DIR/common-functions.sh
# shellcheck source=./logs.env
. $SCRIPT_DIR/logs.env
