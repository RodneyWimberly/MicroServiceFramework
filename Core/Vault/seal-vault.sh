#!/bin/bash
# shellcheck source=./common-functions.sh
. "${CORE_SCRIPT_DIR}"/common-functions.sh
set +e
if [ "$(curl -o /dev/null -s -w "%{http_code}" http://localhost:8200/v1/sys/health)" -eq 200 ]; then
    seal_vault
fi