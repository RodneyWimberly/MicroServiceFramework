#!/bin/bash

set -e

source ../scripts/core.env
source ../scripts/admin-functions.sh

MSF_DIR=/mnt/d/em
CORE_DIR=$MSF_DIR/core

log_detail "Making links for Core stack"
ln /H $CORE_DIR\.gitignore d:\em\.gitignore
ln /H $CORE_DIR\.dockerignore d:\em\.dockerignore

log_detail "Making links for Consul"
ln /H $CORE_DIR\consul\consul-agent-ca.pem $CORE_DIR\shared\certs\consul-agent-ca.pem
ln /H $CORE_DIR\consul\docker-client-consul-0.pem $CORE_DIR\shared\certs\docker-client-consul-0.pem
ln /H $CORE_DIR\consul\docker-client-consul-0-key.pem $CORE_DIR\shared\certs\docker-client-consul-0-key.pem
ln /H $CORE_DIR\consul\docker-server-consul-0.pem $CORE_DIR\shared\certs\docker-server-consul-0.pem
ln /H $CORE_DIR\consul\docker-server-consul-0-key.pem $CORE_DIR\shared\certs\docker-server-consul-0-key.pem
ln /H $CORE_DIR\consul\.dockerignore $MSF_DIR\.dockerignore
ln /H $CORE_DIR\consul\core.env $CORE_DIR\shared\scripts\core.env
ln /H $CORE_DIR\consul\common-functions.sh $CORE_DIR\shared\scripts\common-functions.sh
ln /H $CORE_DIR\consul\consul-functions.sh $CORE_DIR\shared\scripts\consul-functions.sh
ln /H $CORE_DIR\consul\hosting-functions.sh $CORE_DIR\shared\scripts\hosting-functions.sh
ln /H $CORE_DIR\consul\logging-functions.sh $CORE_DIR\shared\scripts\logging-functions.sh

log_detail "Making links for DNS"
ln /H $CORE_DIR\dns\.dockerignore $MSF_DIR\.dockerignore
ln /H $CORE_DIR\dns\core.env $CORE_DIR\shared\scripts\core.env
ln /H $CORE_DIR\dns\common-functions.sh $CORE_DIR\shared\scripts\common-functions.sh
ln /H $CORE_DIR\dns\consul-functions.sh $CORE_DIR\shared\scripts\consul-functions.sh
ln /H $CORE_DIR\dns\hosting-functions.sh $CORE_DIR\shared\scripts\hosting-functions.sh
ln /H $CORE_DIR\dns\logging-functions.sh $CORE_DIR\shared\scripts\logging-functions.sh

log_detail "Making links for Portal"
ln /H $CORE_DIR\portal\.dockerignore $MSF_DIR\.dockerignore
ln /H $CORE_DIR\portal\core.env $CORE_DIR\shared\scripts\core.env
ln /H $CORE_DIR\portal\common-functions.sh $CORE_DIR\shared\scripts\common-functions.sh
ln /H $CORE_DIR\portal\consul-functions.sh $CORE_DIR\shared\scripts\consul-functions.sh
ln /H $CORE_DIR\portal\hosting-functions.sh $CORE_DIR\shared\scripts\hosting-functions.sh
ln /H $CORE_DIR\portal\logging-functions.sh $CORE_DIR\shared\scripts\logging-functions.sh

log_detail "Making links for Vault"
ln /H $CORE_DIR\vault\consul-agent-ca.pem $CORE_DIR\shared\certs\consul-agent-ca.pem
ln /H $CORE_DIR\vault\docker-client-consul-0.pem $CORE_DIR\shared\certs\docker-client-consul-0.pem
ln /H $CORE_DIR\vault\docker-client-consul-0-key.pem $CORE_DIR\shared\certs\docker-client-consul-0-key.pem
ln /H $CORE_DIR\vault\docker-server-consul-0.pem $CORE_DIR\shared\certs\docker-server-consul-0.pem
ln /H $CORE_DIR\vault\docker-server-consul-0-key.pem $CORE_DIR\shared\certs\docker-server-consul-0-key.pem
ln /H $CORE_DIR\vault\.dockerignore $MSF_DIR\.dockerignore
ln /H $CORE_DIR\vault\core.env $CORE_DIR\shared\scripts\core.env
ln /H $CORE_DIR\vault\common-functions.sh $CORE_DIR\shared\scripts\common-functions.sh
ln /H $CORE_DIR\vault\consul-functions.sh $CORE_DIR\shared\scripts\consul-functions.sh
ln /H $CORE_DIR\vault\hosting-functions.sh $CORE_DIR\shared\scripts\hosting-functions.sh
ln /H $CORE_DIR\vault\logging-functions.sh $CORE_DIR\shared\scripts\logging-functions.sh
