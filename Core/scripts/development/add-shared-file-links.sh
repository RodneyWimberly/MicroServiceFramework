#!/bin/bash
set -ueo pipefail
set +x

# shellcheck source=../../../shared/scripts/development-functions.sh
. /mnt/d/msf/shared/scripts/development-functions.sh

log "core: Creating file links for shared files."

link_file $MSF_DIR/.gitignore $CORE_DIR/.gitignore
link_file $MSF_DIR/.dockerignore $CORE_DIR/.dockerignore

log_detail "Making links for Deployment"
link_file $CORE_DIR/docker-compose.yml $CORE_DIR/scripts/deployment/package/docker-compose.yml
link_file $CORE_DIR/scripts/core.env $CORE_DIR/scripts/deployment/package/core.env
link_file $CORE_DIR/scripts/core-functions.sh $CORE_DIR/scripts/deployment/package/core-functions.sh
link_file $MSF_DIR/shared/scripts/deployment-functions.sh $CORE_DIR/scripts/deployment/package/deployment-functions.sh
link_file $CORE_DIR/scripts/deployment/deploy-cluster.sh $CORE_DIR/scripts/deployment/package/deploy-cluster.sh
link_file $CORE_DIR/scripts/deployment/shutdown-cluster.sh $CORE_DIR/scripts/deployment/package/shutdown-cluster.sh
link_file $CORE_DIR/scripts/deployment/portainer/add-portainer.sh $CORE_DIR/scripts/deployment/package/add-portainer.sh
link_file $CORE_DIR/scripts/deployment/portainer/kill-portainer.sh $CORE_DIR/scripts/deployment/package/kill-portainer.sh
link_common_functions $CORE_DIR/scripts/deployment/package

log_detail "Making links for Consul"
link_file $MSF_DIR/.dockerignore $CORE_DIR/consul/.dockerignore
link_file $CORE_DIR/scripts/core.env $CORE_DIR/consul/core.env
link_file $CORE_DIR/scripts/core-functions.sh $CORE_DIR/consul/core-functions.sh
link_file $SHARED_CONFIG/consul-service.json $CORE_DIR/consul/consul-service.json
link_certs $CORE_DIR/consul
link_common_functions $CORE_DIR/consul

log_detail "Making links for DNS"
link_file $MSF_DIR/.dockerignore $CORE_DIR/dns/.dockerignore
link_file $CORE_DIR/scripts/core.env $CORE_DIR/dns/core.env
link_file $CORE_DIR/scripts/core-functions.sh $CORE_DIR/dns/core-functions.sh
link_file $SHARED_CONFIG/consul-service.json $CORE_DIR/dns/consul-service.json
link_common_functions $CORE_DIR/dns

log_detail "Making links for Portainer"
link_file $MSF_DIR/.dockerignore $CORE_DIR/portainer/.dockerignore
link_file $CORE_DIR/scripts/core.env $CORE_DIR/portainer/core.env
link_file $CORE_DIR/scripts/core-functions.sh $CORE_DIR/portainer/core-functions.sh
link_file $SHARED_CONFIG/consul-service.json $CORE_DIR/portainer/consul-service.json
link_common_functions $CORE_DIR/portainer

log_detail "Making links for Portainer-Agent"
link_file $MSF_DIR/.dockerignore $CORE_DIR/portainer-agent/.dockerignore
link_file $CORE_DIR/scripts/core.env $CORE_DIR/portainer-agent/core.env
link_file $CORE_DIR/scripts/core-functions.sh $CORE_DIR/portainer-agent/core-functions.sh
link_file $SHARED_CONFIG/consul-service.json $CORE_DIR/portainer-agent/consul-service.json
link_common_functions $CORE_DIR/portainer-agent

log_detail "Making links for Portal"
link_file $MSF_DIR/.dockerignore $CORE_DIR/portal/.dockerignore
link_file $CORE_DIR/scripts/core.env $CORE_DIR/portal/core.env
link_file $CORE_DIR/scripts/core-functions.sh $CORE_DIR/portal/core-functions.sh
link_file $SHARED_CONFIG/consul-service.json $CORE_DIR/portal/consul-service.json
link_common_functions $CORE_DIR/portal

log_detail "Making links for SSH Server"
link_file $MSF_DIR/.dockerignore $CORE_DIR/ssh-server/.dockerignore
link_file $CORE_DIR/scripts/core.env $CORE_DIR/ssh-server/core.env
link_file $CORE_DIR/scripts/core-functions.sh $CORE_DIR/ssh-server/core-functions.sh
link_file $SHARED_CONFIG/consul-service.json $CORE_DIR/ssh-server/consul-service.json
link_common_functions $CORE_DIR/ssh-server

log_detail "Making links for Vault"
link_file $MSF_DIR/.dockerignore $CORE_DIR/vault/.dockerignore
link_file $CORE_DIR/scripts/core.env $CORE_DIR/vault/core.env
link_file $CORE_DIR/scripts/core-functions.sh $CORE_DIR/vault/core-functions.sh
link_file $SHARED_SCRIPTS/vault-exec.sh $CORE_DIR/vault/vault-exec.sh
link_file $SHARED_CONFIG/consul-service.json $CORE_DIR/vault/consul-service.json
link_certs $CORE_DIR/vault
link_common_functions $CORE_DIR/vault
