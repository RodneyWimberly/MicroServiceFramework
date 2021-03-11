#!/bin/bash
set -ueo pipefail
set +x

# shellcheck source=../../../shared/scripts/development-functions.sh
. /mnt/d/msf/shared/scripts/development-functions.sh

log "Creating file links for shared files."
/mnt/d/msf/core/scripts/development/add-shared-file-links.sh
/mnt/d/msf/logs/scripts/development/add-shared-file-links.sh