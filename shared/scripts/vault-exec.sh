#!/usr/bin/env bash
# shellcheck source=./vault-functions.sh
. "${CORE_SCRIPT_DIR}"/vault-functions.sh
execute_vault_command "$@"