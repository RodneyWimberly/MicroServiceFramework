#!/bin/bash
set -ueo pipefail
set +x

# shellcheck source=../../../shared/scripts/development-functions.sh
. /mnt/d/msf/shared/scripts/development-functions.sh

log_header "Creating file links for shared files."
link_common_functions $MSF_DIR/scripts/deployment/package
link_file $MSF_DIR/shared/scripts/deployment-functions.sh  $MSF_DIR/scripts/deployment/package/deployment-functions.sh
link_file $MSF_DIR/shared/scripts/vault-exec.sh  $MSF_DIR/scripts/deployment/package/vault-exec
link_file $MSF_DIR/shared/scripts/vault-shell.sh  $MSF_DIR/scripts/deployment/package/vault-shell
link_file $MSF_DIR/shared/scripts/consul-exec  $MSF_DIR/scripts/deployment/package/consul-exec
link_file $MSF_DIR/shared/scripts/consul-shell  $MSF_DIR/scripts/deployment/package/consul-shell
link_file $MSF_DIR/shared/scripts/service-shell  $MSF_DIR/scripts/deployment/package/service-shell
/mnt/d/msf/core/scripts/development/add-shared-file-links.sh
/mnt/d/msf/logs/scripts/development/add-shared-file-links.sh
log_success "Completed create file links"