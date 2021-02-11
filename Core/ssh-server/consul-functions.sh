#!/bin/sh

function get_consul_ip() {
  log "Looking up IP address for ${CONSUL_SERVER}"
  CONSUL_IP=
  while [[ -z "${CONSUL_IP}" ]]; do
    CONSUL_IP=$(get_ip_from_name "${CONSUL_SERVER}")
    if [[ -z "${CONSUL_IP}" ]]; then
      log_warning "Unable to locate ${CONSUL_SERVER}, retrying in 1 second."
      sleep 1
    fi
  done
  export CONSUL_IP
  export CONSUL_HTTP_ADDR=http://${CONSUL_IP}:8500
  log_header "Consul Details"
  log_detail "Consul IP: ${CONSUL_IP}"
  log_detail "Consul HTTP Addr: ${CONSUL_HTTP_ADDR}"
}

function get_consul_service_health() {
  log "Getting Consul service health for $1"
  curl -sS  "${CONSUL_AGENT_API}"health/service/name/$1?format=text
}

function list_consul_services() {
  log "Listing Consul services"
  curl -sS  "${CONSUL_AGENT_API}"services
}

function get_consul_service() {
  log "Getting Consul service $1"
  curl -sS  "${CONSUL_AGENT_API}"service/$1
}

function add_consul_service() {
  export SERVICE_NAME="$1"
  export SERVICE_PORT="$2"
  export SERVICE_ID="$SERVICE_NAME:$ETH0_IP:$SERVICE_PORT"
  if [[ $# > 2 ]]; then
    export SERVICE_TAGS="$3"
  else
    export SERVICE_TAGS=
  fi
  cat /etc/templates/consul-service.json | envsubst > /etc/templates/"$SERVICE_NAME-$SERVICE_PORT".json
  log_header "Consul service registration"
  log_detail "Service ID: $SERVICE_ID"
  log_detail "Service Name: $SERVICE_NAME"
  log_detail "Service Address: $ETH0_IP"
  log_detail "Service Port: $SERVICE_PORT"
  log_detail "Service Tags: $SERVICE_TAGS"
  if [[ "${SERVICE_NAME}" == "consul" ]]; then
    cp /etc/templates/"$SERVICE_NAME-$SERVICE_PORT".json /consul/config/"$SERVICE_NAME-$SERVICE_PORT".json
  else
    curl -sS \
      --request PUT \
      --data @/etc/templates/"$SERVICE_NAME-$SERVICE_PORT".json \
      "${CONSUL_AGENT_API}"service/register?replace-existing-checks=true
  fi
  #echo "$SERVICE_ID"
}

function remove_consul_service() {
  log "Deregistering service ${1}"
  curl -sS  \
    --request PUT \
    "${CONSUL_AGENT_API}"service/deregister/$1
}

function mark_consul_service_maintance() {
  log "Set maintance mode: Service=$1 Enabled=$2 Reason=$3"
  curl -sS  \
    --request PUT \
    "${CONSUL_AGENT_API}"service/maintenance/$1?enable=$2&reason=$3
}

function get_consul_kv() {
  log "Getting value for key $1 from KV store"
  curl -sS  "${CONSUL_KV_API}"$1
}

function put_consul_kv() {
  log "Saving value for key $1 to KV store"
  curl -sS  \
      --request PUT \
      --data @$2 \
      "${CONSUL_KV_API}"$1
}

function delete_consul_kv() {
  log "Removing value for key $1 to KV store"
  curl -sS  \
      --request DELETE \
      "${CONSUL_KV_API}"%1
}

function take_consul_snapshot() {
  if [[ -z "$1" ]]; then
    snapshot_file="snapshot_$(date +%Y-%m-%d-%s).tar"
  else
    snapshot_file=$1
  fi
  log "Taking Consul cluster snapshot to file $snapshot_file"
  curl -sS "${CONSUL_API}"snapshot?dc=${CONSUL_DATACENTER} -o ${snapshot_file}
  if [[ -f "backups/latest_snapshot.tar" ]]; then
    rm -f "backups/latest_snapshot.tar"
  fi
  cp $snapshot_file "backups/latest_snapshot.tar"
  echo $snapshot_file
}

function restore_consul_snapshot() {
  if [[ -z "$1" ]]; then
    snapshot_file="backups/latest_snapshot.tar"
  else
    snapshot_file=$1
  fi
  if [[ -f "${snapshot_file}" ]]; then
    log "Restoring Consul cluster snapshot from file $snapshot_file"
    curl -sS  --request PUT --data-binary @$snapshot_file "${CONSUL_API}"snapshot
  else
    log_warning "Restore snapshot failed! Snapshot file '${snapshot_file}' could not be found."
  fi
}

function run_consul_template() {
  # $1 is the source file
  # $2 is the template file name
  # $3 is the destination
  # $4 is the reload command and may not exist
  template_dir=/usr/local/tmp
  if [[ ! -d "${template_dir}" ]]; then
    mkdir $template_dir
  fi
  cp $1 $template_dir/$2
  if [ -z "$4" ]; then
    log "Processing Consul template $1"
    /bin/sh -c "sleep 30;nohup consul-template -consul-addr="${CONSUL_ENDPOINT}" --vault-addr=http://active.vault.service.consul:8200 -template=$template_dir/$2:$3 -retry 30s -consul-retry -wait 30s -consul-retry-max-backoff=15s &"
  else
    log "Processing Consul template $1 and running $4"
    /bin/sh -c "nohup consul-template -consul-addr="${CONSUL_ENDPOINT}" --vault-addr=http://active.vault.service.consul:8200 -template=$template_dir/$2:$3:'$4' -retry 30s -consul-retry -wait 30s -consul-retry-max-backoff=15s &"
  fi
}

function expand_consul_config_from() {
  set +e
  log "Updating ${CONSUL_TEMPLATES_DIR}/$1 with variable value substitution and saving to ${CONSUL_CONFIG_DIR}/$1"
  rm -f "${CONSUL_CONFIG_DIR}/$1"
  cat "${CONSUL_TEMPLATES_DIR}/$1" | envsubst > "${CONSUL_CONFIG_DIR}/$1"
  set -e
}

