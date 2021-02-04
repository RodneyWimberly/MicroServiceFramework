#!/bin/bash

set -e

source ../scripts/core.env
source ../scripts/admin-functions.sh

log "Creating file links for shared files."

MSF_DIR=/mnt/d/em
CORE_DIR=$MSF_DIR/Core

log_detail "Making links for Core stack"
ln -f -v $CORE_DIR/.gitignore $MSF_DIR/.gitignore
ln -f -v $CORE_DIR/.dockerignore $MSF_DIR/.dockerignore

log_detail "Making links for Consul"
ln -f -v $CORE_DIR/consul/consul-agent-ca.pem $CORE_DIR/shared/certs/consul-agent-ca.pem
ln -f -v $CORE_DIR/consul/docker-client-consul-0.pem $CORE_DIR/shared/certs/docker-client-consul-0.pem
ln -f -v $CORE_DIR/consul/docker-client-consul-0-key.pem $CORE_DIR/shared/certs/docker-client-consul-0-key.pem
ln -f -v $CORE_DIR/consul/docker-server-consul-0.pem $CORE_DIR/shared/certs/docker-server-consul-0.pem
ln -f -v $CORE_DIR/consul/docker-server-consul-0-key.pem $CORE_DIR/shared/certs/docker-server-consul-0-key.pem
ln -f -v $CORE_DIR/consul/.dockerignore $MSF_DIR/.dockerignore
ln -f -v $CORE_DIR/consul/core.env $CORE_DIR/shared/scripts/core.env
ln -f -v $CORE_DIR/consul/common-functions.sh $CORE_DIR/shared/scripts/common-functions.sh
ln -f -v $CORE_DIR/consul/consul-functions.sh $CORE_DIR/shared/scripts/consul-functions.sh
ln -f -v $CORE_DIR/consul/hosting-functions.sh $CORE_DIR/shared/scripts/hosting-functions.sh
ln -f -v $CORE_DIR/consul/logging-functions.sh $CORE_DIR/shared/scripts/logging-functions.sh

log_detail "Making links for DNS"
ln -f -v $CORE_DIR/dns/.dockerignore $MSF_DIR/.dockerignore
ln -f -v $CORE_DIR/dns/core.env $CORE_DIR/shared/scripts/core.env
ln -f -v $CORE_DIR/dns/common-functions.sh $CORE_DIR/shared/scripts/common-functions.sh
ln -f -v $CORE_DIR/dns/consul-functions.sh $CORE_DIR/shared/scripts/consul-functions.sh
ln -f -v $CORE_DIR/dns/hosting-functions.sh $CORE_DIR/shared/scripts/hosting-functions.sh
ln -f -v $CORE_DIR/dns/logging-functions.sh $CORE_DIR/shared/scripts/logging-functions.sh

log_detail "Making links for Portal"
ln -f -v $CORE_DIR/portal/.dockerignore $MSF_DIR/.dockerignore
ln -f -v $CORE_DIR/portal/core.env $CORE_DIR/shared/scripts/core.env
ln -f -v $CORE_DIR/portal/common-functions.sh $CORE_DIR/shared/scripts/common-functions.sh
ln -f -v $CORE_DIR/portal/consul-functions.sh $CORE_DIR/shared/scripts/consul-functions.sh
ln -f -v $CORE_DIR/portal/hosting-functions.sh $CORE_DIR/shared/scripts/hosting-functions.sh
ln -f -v $CORE_DIR/portal/logging-functions.sh $CORE_DIR/shared/scripts/logging-functions.sh

log_detail "Making links for Vault"
ln -f -v $CORE_DIR/vault/consul-agent-ca.pem $CORE_DIR/shared/certs/consul-agent-ca.pem
ln -f -v $CORE_DIR/vault/docker-client-consul-0.pem $CORE_DIR/shared/certs/docker-client-consul-0.pem
ln -f -v $CORE_DIR/vault/docker-client-consul-0-key.pem $CORE_DIR/shared/certs/docker-client-consul-0-key.pem
ln -f -v $CORE_DIR/vault/docker-server-consul-0.pem $CORE_DIR/shared/certs/docker-server-consul-0.pem
ln -f -v $CORE_DIR/vault/docker-server-consul-0-key.pem $CORE_DIR/shared/certs/docker-server-consul-0-key.pem
ln -f -v $CORE_DIR/vault/.dockerignore $MSF_DIR/.dockerignore
ln -f -v $CORE_DIR/vault/core.env $CORE_DIR/shared/scripts/core.env
ln -f -v $CORE_DIR/vault/common-functions.sh $CORE_DIR/shared/scripts/common-functions.sh
ln -f -v $CORE_DIR/vault/consul-functions.sh $CORE_DIR/shared/scripts/consul-functions.sh
ln -f -v $CORE_DIR/vault/hosting-functions.sh $CORE_DIR/shared/scripts/hosting-functions.sh
ln -f -v $CORE_DIR/vault/logging-functions.sh $CORE_DIR/shared/scripts/logging-functions.sh
