#!/bin/sh
set +e
set +x

# Make our stuff available
# shellcheck source=./core-functions.sh
. "${CORE_SCRIPT_DIR}"/core-functions.sh
add_path "${CORE_SCRIPT_DIR}"
update_dns_config

# Get Docker/Node/Hosting information from the Docker API for use in configuration
hosting_details
export VAULT_ADDR=http://127.0.0.1:8200
export VAULT_API_ADDR=http://"${ETH0_IP}":8200
export VAULT_CLUSTER_ADDR=https://"${ETH0_IP}":8201
log_header "Vault Details"
log_detail "Vault Address: ${VAULT_ADDR}"
log_detail "Vault API Address: ${VAULT_API_ADDR}"
log_detail "Vault Cluster Address: ${VAULT_CLUSTER_ADDR}"
log_detail "Waiting 15 seconds for the cluster to hold an election before we try to join the cluster."
get_consul_ip

log_detail "Linking the /vault/templates folder to the /etc/templates folder"
ln -s /vault/templates /etc/templates

log_detail "merging expanded variables with configuration templates and placing in the config folder"
envsubst < /vault/templates/vault.json > /vault/config/vault.json

docker-entrypoint.sh vault server -config=/vault/config
