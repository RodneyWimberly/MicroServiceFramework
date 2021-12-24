#!/bin/sh /bin/bash

get_consul_ip() {
  # Setup vars
  start_ts=$(date +%s)
  NODE_NAME=${NODE_NAME:-api}
  # CONSUL_LOCAL_SERVER="${NODE_NAME}.${CONSUL_SERVER}"
  CONSUL_LOCAL_SERVER="${NODE_NAME}.node.${CONSUL_DOMAIN}"
  log "Waiting for for ${CONSUL_LOCAL_SERVER} to respond"
  end1_ts=$(date +%s)
  # use dig response to query IP, we are querying consul not dns as this will be called by the dns server
  log_detail "Waiting on dig to respond to ${CONSUL_LOCAL_SERVER}"
  until dig @"${CONSUL_SERVER}" +short "${CONSUL_LOCAL_SERVER}" >/dev/null 2>&1;
  do
    sleep 1
    end2_ts=$(date +%s)
    new_seconds2=$((end2_ts - end1_ts))
    if [ $new_seconds2 -gt 120 ]; then
      log_error "${CONSUL_LOCAL_SERVER} hasn't responded to dig requests in over 60 $new_seconds2. Killing container"
      exit 1
    elif [ $new_seconds2 -gt 60 ]; then
      log_warning "${CONSUL_LOCAL_SERVER} hasn't responded to dig requests in over $new_seconds2 seconds."
    fi
  done
  CONSUL_IP=$(dig @"${CONSUL_SERVER}" +short "${CONSUL_LOCAL_SERVER}" | tail -n1)
  if [ -z "${CONSUL_IP}" ] || [ "${CONSUL_IP}" = ";; connection timed out; no servers could be reached" ]; then
   log_error "No IP address could be obtained for ${CONSUL_LOCAL_SERVER}. Killing container"
   exit 1
  fi
  end2_ts=$(date +%s)
  new_seconds2=$((end2_ts - end1_ts))
  new_seconds1=$((end2_ts - start_ts))
  log_success "$CONSUL_LOCAL_SERVER responded to dig requests with IP $CONSUL_IP in $new_seconds2 seconds."

  # export data
  export CONSUL_IP
  export CONSUL_AGENT="${CONSUL_IP}:8500"
  export CONSUL_HTTP_ADDR="http://${CONSUL_IP}:8500"
  export CONSUL_HTTPS_ADDR="https://${CONSUL_IP}:8501"
  export CONSUL_RPC_ADDR="rpc://${CONSUL_IP}:8400"
  export CONSUL_API="${CONSUL_HTTP_ADDR}/v1"
  export CONSUL_AGENT_API="${CONSUL_API}/agent"
  export CONSUL_KV_API="${CONSUL_API}/kv"

  # display data for debugging
  log_header "Consul Environment Variables"
  log_detail "CONSUL_IP: ${CONSUL_IP}"
  log_detail "CONSUL_AGENT: ${CONSUL_AGENT}"
  log_detail "CONSUL_HTTP_ADDR: ${CONSUL_HTTP_ADDR}"
  log_detail "CONSUL_HTTPS_ADDR: ${CONSUL_HTTPS_ADDR}"
  log_detail "CONSUL_RPC_ADDR: ${CONSUL_RPC_ADDR}"
  log_detail "CONSUL_API: ${CONSUL_API}"
  log_detail "CONSUL_AGENT_API: ${CONSUL_AGENT_API}"
  log_detail "CONSUL_KV_API: ${CONSUL_KV_API}"

  # update hosts so the local.consul.service.consul is always your local agent
  log "Adding 'local.consul.service.consul ${CONSUL_IP}' to /etc/hosts"
  echo "${CONSUL_IP} local.consul.service.consul" >> /etc/hosts

  end2_ts=$(date +%s)
  new_seconds1=$((end2_ts - start_ts))
  log_success "Consul IP ${CONSUL_IP} was found in $new_seconds1 seconds"
}

get_consul_service_health() {
  log "Getting Consul service health for $1"
  curl -sS "${CONSUL_AGENT_API}"/health/service/name/"$1"?format=text
}

list_consul_services() {
  log "Listing Consul services"
  curl -sS "${CONSUL_AGENT_API}"/services
}

get_consul_service() {
  log "Getting Consul service $1"
  curl -sS "${CONSUL_AGENT_API}"/service/"$1"
}

add_consul_service() {
  export SERVICE_NAME="$1"
  export SERVICE_PORT="$2"
  export SERVICE_IP="$ETH0_IP"
  export SERVICE_ID="$SERVICE_NAME:$SERVICE_IP:$SERVICE_PORT"
  if [ $# -gt 2 ]; then
    export SERVICE_TAGS="$3"
  else
    export SERVICE_TAGS=
  fi
  __resultvar="$4"
  SERVICE_TEMPLATE=${5:-consul-service.json}
  envsubst < /etc/templates/"$SERVICE_TEMPLATE" > /etc/templates/"$SERVICE_NAME-$SERVICE_PORT".json
  log_header "Consul service registration"
  log_detail "SERVICE_ID: $SERVICE_ID"
  log_detail "SERVICE_NAME: $SERVICE_NAME"
  log_detail "SERVICE_IP: $SERVICE_IP"
  log_detail "SERVICE_PORT: $SERVICE_PORT"
  log_detail "SERVICE_TAGS: $SERVICE_TAGS"
  if [ "${SERVICE_NAME}" = "consul" ]; then
      /bin/sh -c "while true; do sleep 15; if curl -sS --request PUT --data @/etc/templates/$SERVICE_NAME-$SERVICE_PORT.json http://127.0.0.1:8500/v1/agent/service/register?replace-existing-checks=true; then break; fi; done" &
  else
    curl -sS \
      --request PUT \
      --data @/etc/templates/"$SERVICE_NAME-$SERVICE_PORT".json \
      "${CONSUL_AGENT_API}"/service/register?replace-existing-checks=true
  fi
  if [ "$__resultvar" ]; then
    eval $__resultvar="'$SERVICE_ID'"
  else
    echo "$SERVICE_ID"
  fi
}

remove_consul_service() {
  log "Deregister service ${1}"
  curl -sS \
    --request PUT \
    "${CONSUL_AGENT_API}"/service/deregister/"$1"
}

mark_consul_service_maintenance() {
  log "Set maintenance mode: Service=$1 Enabled=$2 Reason=$3"
  curl -sS \
    --request PUT \
    "${CONSUL_AGENT_API}"/service/maintenance/"$1"?enable="$2"\&reason="$3" --
}

get_consul_kv() {
  log "Getting value for key $1 from KV store"
  curl -sS "${CONSUL_KV_API}$1"
}

put_consul_kv() {
  log "Saving value for key $1 to KV store"
  curl -sS \
    --request PUT \
    --data @"$2" \
    "${CONSUL_KV_API}$1"
}

delete_consul_kv() {
  log "Removing value for key $1 to KV store"
  curl -sS \
    --request DELETE \
    "${CONSUL_KV_API}$1"
}

take_consul_snapshot() {
  if [ $# -eq 0 ]; then
    snapshot_file="snapshot_$(date +%Y-%m-%d-%s).tar"
  else
    snapshot_file=$1
  fi
  CONTAINER=$(docker ps -q -f status=running --filter name=core_consul)
  log "Taking Consul cluster snapshot from container $CONTAINER to file $snapshot_file"
  docker exec "$CONTAINER" consul snapshot save "/consul/data/$snapshot_file"
  docker cp "$CONTAINER:/consul/data/$snapshot_file" "./$snapshot_file"
  if [ ! -d ~/backups ]; then
    mkdir ~/backups
  fi
  if [ -f ~/backups/latest_snapshot.tar ]; then
    rm -f ~/backups/latest_snapshot.tar
  fi
  cp "./$snapshot_file" ~/backups/latest_snapshot.tar
  echo "./$snapshot_file"
}

restore_consul_snapshot() {
  if [ -z "$1" ]; then
    snapshot_file="backups/latest_snapshot.tar"
  else
    snapshot_file=$1
  fi
  if [ -f "${snapshot_file}" ]; then
    log "Restoring Consul cluster snapshot from file $snapshot_file"
    curl -sS --request PUT --data-binary @"$snapshot_file" http://consul.service.consul:8500/v1/snapshot
  else
    log_warning "Restore snapshot failed! Snapshot file '${snapshot_file}' could not be found."
  fi
}

run_consul_template() {
  # $1 is the source file
  # $2 is the template file name
  # $3 is the destination
  # $4 is the reload command and may not exist
  template_dir=/usr/local/tmp
  if [ ! -d "${template_dir}" ]; then
    mkdir $template_dir
  fi
  cp "$1" "$template_dir/$2"
  command=${4:-NONE}
  if [ "$command" = "NONE" ]; then
    log "Processing Consul template $1"
    /bin/sh -c "sleep 5;nohup consul-template -consul-addr=${CONSUL_AGENT} --vault-addr=http://active.vault.service.consul:8200 -template=$template_dir/$2:$3 -retry 30s -consul-retry -wait 30s -consul-retry-max-backoff=15s &"
  else
    log "Processing Consul template $1 and running $command"
    /bin/sh -c "nohup consul-template -consul-addr=${CONSUL_AGENT} --vault-addr=http://active.vault.service.consul:8200 -template=$template_dir/$2:$3:'$command' -retry 30s -consul-retry -wait 30s -consul-retry-max-backoff=15s &"
  fi
}

expand_consul_config_from() {
  set +e
  log "Updating ${CONSUL_TEMPLATES_DIR}/$1 with variable value substitution and saving to ${CONSUL_CONFIG_DIR}/$1"
  rm -f "${CONSUL_CONFIG_DIR}/$1"
  envsubst <"${CONSUL_TEMPLATES_DIR}/$1" >"${CONSUL_CONFIG_DIR}/$1"
  set -e
}

execute_consul_command() {
  docker-service-exec core_consul "consul $*"
}

remove_unhealthy_services() {
  leader="$(curl http://consul.service.consul:8500/v1/status/leader | sed 's/:8300//' | sed 's/"//g')"
  while :
  do
    serviceID="$(curl http://$leader:8500/v1/health/state/critical | ./jq '.[0].ServiceID' | sed 's/"//g')"
    node="$(curl http://$leader:8500/v1/health/state/critical | ./jq '.[0].Node' | sed 's/"//g')"
    echo "serviceID=$serviceID, node=$node"
    size=${#serviceID}
    echo "size=$size"
    if [ $size -ge 7 ]; then
      curl --request PUT http://$node:8500/v1/agent/service/deregister/$serviceID
    else
      break
    fi
  done
  curl http://$leader:8500/v1/health/state/critical
}