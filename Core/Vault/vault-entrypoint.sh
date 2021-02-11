#!/bin/sh

# Make our stuff available
source "${CORE_SCRIPT_DIR}"/common-functions.sh
add_path "${CORE_SCRIPT_DIR}"
set +e

# Get Docker/Node/Hosting information from the Docker API for use in configuration
hosting_details
export VAULT_ADDR="http://${ETH0_IP}:8200"
export VAULT_API_ADDR="http://${ETH0_IP}:8200"
export VAULT_CLUSTER_ADDR="https://${ETH0_IP}:8201"
log_header "Vault Details"
log_detail "Vault Address: ${VAULT_ADDR}"
log_detail "Vault API Address: ${VAULT_API_ADDR}"
log_detail "Vault Cluster Address: ${VAULT_CLUSTER_ADDR}"
get_consul_ip
# update_dns_config

log_detail "merging expanded variables with configuration templates and placing in the config folder"
cat /vault/templates/vault.json | envsubst > /vault/config/vault.json

SERVICE_ID=$(add_consul_service "vault" 8200 "\"portal\"")
docker-entrypoint.sh vault server -config=/vault/config
remove_consul_service $SERVICE_ID
