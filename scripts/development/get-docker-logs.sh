#!/bin/bash
set -ueo pipefail
set +x

# shellcheck source=../../shared/scripts/development-functions.sh
. /mnt/d/msf/shared/scripts/development-functions.sh
eval "$(keychain --eval id_rsa id_dsa)"
ssh -tt $MANAGER_SSH docker service logs "$1"