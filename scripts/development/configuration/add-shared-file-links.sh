#!/bin/bash
set -ueo pipefail
set +x

# shellcheck source=../development.env
. /mnt/d/msf/scripts/development/development.env
# shellcheck source=../development-functions.sh
. /mnt/d/msf/scripts/development/development-functions.sh

log "Creating file links for shared files."
/mnt/d/msf/core/scripts/development/add-shared-file-links.sh
