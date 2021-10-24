#!/bin/bash
clear 
set -ue
set +x

# shellcheck source=../../../shared/scripts/development-functions.sh
. /mnt/d/msf/shared/scripts/development-functions.sh
ssh "$MANAGER_SSH"