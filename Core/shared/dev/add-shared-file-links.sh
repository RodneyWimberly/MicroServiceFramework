#!/bin/sh

set -e

. /mnt/d/em/Core/shared/dev/dev-functions.sh

log "Creating file links for shared files."

MSF_DIR=/mnt/d/em
CORE_DIR=$MSF_DIR/Core

log_detail "Making links for Core stack"
link_file $MSF_DIR/.gitignore $CORE_DIR/.gitignore
link_file $MSF_DIR/.dockerignore $CORE_DIR/.dockerignore

log_detail "Making links for Consul"
link_file $CORE_DIR/shared/certs/consul-agent-ca.pem $CORE_DIR/consul/consul-agent-ca.pem
link_file $CORE_DIR/shared/certs/docker-client-consul-0.pem $CORE_DIR/consul/docker-client-consul-0.pem
link_file $CORE_DIR/shared/certs/docker-client-consul-0-key.pem $CORE_DIR/consul/docker-client-consul-0-key.pem
link_file $CORE_DIR/shared/certs/docker-server-consul-0.pem $CORE_DIR/consul/docker-server-consul-0.pem
link_file $CORE_DIR/shared/certs/docker-server-consul-0-key.pem $CORE_DIR/consul/docker-server-consul-0-key.pem
link_file $MSF_DIR/.dockerignore $CORE_DIR/consul/.dockerignore
link_file $CORE_DIR/shared/scripts/core.env $CORE_DIR/consul/core.env
link_file $CORE_DIR/shared/scripts/common-functions.sh $CORE_DIR/consul/common-functions.sh
link_file $CORE_DIR/shared/scripts/consul-functions.sh $CORE_DIR/consul/consul-functions.sh
link_file $CORE_DIR/shared/scripts/hosting-functions.sh $CORE_DIR/consul/hosting-functions.sh
link_file $CORE_DIR/shared/scripts/logging-functions.sh $CORE_DIR/consul/logging-functions.sh
link_file $CORE_DIR/shared/scripts/colors.env $CORE_DIR/consul/colors.env
link_file $CORE_DIR/shared/scripts/colors.sh $CORE_DIR/consul/colors.sh
link_file $CORE_DIR/shared/config/consul-service.json $CORE_DIR/consul/consul-service.json
link_file $CORE_DIR/shared/scripts/health-entrypoint.sh $CORE_DIR/consul/health-entrypoint.sh

log_detail "Making links for DNS"
link_file $MSF_DIR/.dockerignore $CORE_DIR/dns/.dockerignore
link_file $CORE_DIR/shared/scripts/core.env $CORE_DIR/dns/core.env
link_file $CORE_DIR/shared/scripts/common-functions.sh $CORE_DIR/dns/common-functions.sh
link_file $CORE_DIR/shared/scripts/consul-functions.sh $CORE_DIR/dns/consul-functions.sh
link_file $CORE_DIR/shared/scripts/hosting-functions.sh $CORE_DIR/dns/hosting-functions.sh
link_file $CORE_DIR/shared/scripts/logging-functions.sh $CORE_DIR/dns/logging-functions.sh
link_file $CORE_DIR/shared/scripts/colors.env $CORE_DIR/dns/colors.env
link_file $CORE_DIR/shared/scripts/colors.sh $CORE_DIR/dns/colors.sh
link_file $CORE_DIR/shared/config/consul-service.json $CORE_DIR/dns/consul-service.json
link_file $CORE_DIR/shared/scripts/health-entrypoint.sh $CORE_DIR/dns/health-entrypoint.sh

log_detail "Making links for Portainer"
link_file $MSF_DIR/.dockerignore $CORE_DIR/portainer/.dockerignore
link_file $CORE_DIR/shared/scripts/core.env $CORE_DIR/portainer/core.env
link_file $CORE_DIR/shared/scripts/common-functions.sh $CORE_DIR/portainer/common-functions.sh
link_file $CORE_DIR/shared/scripts/consul-functions.sh $CORE_DIR/portainer/consul-functions.sh
link_file $CORE_DIR/shared/scripts/hosting-functions.sh $CORE_DIR/portainer/hosting-functions.sh
link_file $CORE_DIR/shared/scripts/logging-functions.sh $CORE_DIR/portainer/logging-functions.sh
link_file $CORE_DIR/shared/scripts/colors.env $CORE_DIR/portainer/colors.env
link_file $CORE_DIR/shared/scripts/colors.sh $CORE_DIR/portainer/colors.sh
link_file $CORE_DIR/shared/config/consul-service.json $CORE_DIR/portainer/consul-service.json
link_file $CORE_DIR/shared/scripts/health-entrypoint.sh $CORE_DIR/portainer/health-entrypoint.sh

log_detail "Making links for Portainer-Agent"
link_file $MSF_DIR/.dockerignore $CORE_DIR/portainer-agent/.dockerignore
link_file $CORE_DIR/shared/scripts/core.env $CORE_DIR/portainer-agent/core.env
link_file $CORE_DIR/shared/scripts/common-functions.sh $CORE_DIR/portainer-agent/common-functions.sh
link_file $CORE_DIR/shared/scripts/consul-functions.sh $CORE_DIR/portainer-agent/consul-functions.sh
link_file $CORE_DIR/shared/scripts/hosting-functions.sh $CORE_DIR/portainer-agent/hosting-functions.sh
link_file $CORE_DIR/shared/scripts/logging-functions.sh $CORE_DIR/portainer-agent/logging-functions.sh
link_file $CORE_DIR/shared/scripts/colors.env $CORE_DIR/portainer-agent/colors.env
link_file $CORE_DIR/shared/scripts/colors.sh $CORE_DIR/portainer-agent/colors.sh
link_file $CORE_DIR/shared/config/consul-service.json $CORE_DIR/portainer-agent/consul-service.json
link_file $CORE_DIR/shared/scripts/health-entrypoint.sh $CORE_DIR/portainer-agent/health-entrypoint.sh

log_detail "Making links for Portal"
link_file $MSF_DIR/.dockerignore $CORE_DIR/portal/.dockerignore
link_file $CORE_DIR/shared/scripts/core.env $CORE_DIR/portal/core.env
link_file $CORE_DIR/shared/scripts/common-functions.sh $CORE_DIR/portal/common-functions.sh
link_file $CORE_DIR/shared/scripts/consul-functions.sh $CORE_DIR/portal/consul-functions.sh
link_file $CORE_DIR/shared/scripts/hosting-functions.sh $CORE_DIR/portal/hosting-functions.sh
link_file $CORE_DIR/shared/scripts/logging-functions.sh $CORE_DIR/portal/logging-functions.sh
link_file $CORE_DIR/shared/scripts/colors.env $CORE_DIR/portal/colors.env
link_file $CORE_DIR/shared/scripts/colors.sh $CORE_DIR/portal/colors.sh
link_file $CORE_DIR/shared/config/consul-service.json $CORE_DIR/portal/consul-service.json
link_file $CORE_DIR/shared/scripts/health-entrypoint.sh $CORE_DIR/portal/health-entrypoint.sh

log_detail "Making links for Socks-Proxy"
link_file $MSF_DIR/.dockerignore $CORE_DIR/ssh-server/.dockerignore
link_file $CORE_DIR/shared/scripts/core.env $CORE_DIR/ssh-server/core.env
link_file $CORE_DIR/shared/scripts/common-functions.sh $CORE_DIR/ssh-server/common-functions.sh
link_file $CORE_DIR/shared/scripts/consul-functions.sh $CORE_DIR/ssh-server/consul-functions.sh
link_file $CORE_DIR/shared/scripts/hosting-functions.sh $CORE_DIR/ssh-server/hosting-functions.sh
link_file $CORE_DIR/shared/scripts/logging-functions.sh $CORE_DIR/ssh-server/logging-functions.sh
link_file $CORE_DIR/shared/scripts/colors.env $CORE_DIR/ssh-server/colors.env
link_file $CORE_DIR/shared/scripts/colors.sh $CORE_DIR/ssh-server/colors.sh
link_file $CORE_DIR/shared/config/consul-service.json $CORE_DIR/ssh-server/consul-service.json
link_file $CORE_DIR/shared/scripts/health-entrypoint.sh $CORE_DIR/ssh-server/health-entrypoint.sh

log_detail "Making links for Vault"
link_file $CORE_DIR/shared/certs/consul-agent-ca.pem $CORE_DIR/vault/consul-agent-ca.pem
link_file $CORE_DIR/shared/certs/docker-client-consul-0.pem $CORE_DIR/vault/docker-client-consul-0.pem
link_file $CORE_DIR/shared/certs/docker-client-consul-0-key.pem $CORE_DIR/vault/docker-client-consul-0-key.pem
link_file $CORE_DIR/shared/certs/docker-server-consul-0.pem $CORE_DIR/vault/docker-server-consul-0.pem
link_file $CORE_DIR/shared/certs/docker-server-consul-0-key.pem $CORE_DIR/vault/docker-server-consul-0-key.pem
link_file $MSF_DIR/.dockerignore $CORE_DIR/vault/.dockerignore
link_file $CORE_DIR/shared/scripts/core.env $CORE_DIR/vault/core.env
link_file $CORE_DIR/shared/scripts/common-functions.sh $CORE_DIR/vault/common-functions.sh
link_file $CORE_DIR/shared/scripts/consul-functions.sh $CORE_DIR/vault/consul-functions.sh
link_file $CORE_DIR/shared/scripts/hosting-functions.sh $CORE_DIR/vault/hosting-functions.sh
link_file $CORE_DIR/shared/scripts/logging-functions.sh $CORE_DIR/vault/logging-functions.sh
link_file $CORE_DIR/shared/scripts/colors.env $CORE_DIR/vault/colors.env
link_file $CORE_DIR/shared/scripts/colors.sh $CORE_DIR/vault/colors.sh
link_file $CORE_DIR/shared/config/consul-service.json $CORE_DIR/vault/consul-service.json
link_file $CORE_DIR/shared/scripts/health-entrypoint.sh $CORE_DIR/vault/health-entrypoint.sh
link_file $CORE_DIR/shared/scripts/vault-functions.sh $CORE_DIR/vault/vault-functions.sh
link_file $CORE_DIR/shared/scripts/vault-exec.sh $CORE_DIR/vault/vault-exec.sh
