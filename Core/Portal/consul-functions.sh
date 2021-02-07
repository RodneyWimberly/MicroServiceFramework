#!/bin/sh

function get_consul_service_health() {
  curl http://consul.service.consul:8500/v1/agent/health/service/name/$1?format=text
}

function list_consul_services() {
  curl http://consul.service.consul:8500/v1/agent/services
}

function get_consul_service() {
  curl http://consul.service.consul:8500/v1/agent/service/$1
}

function add_consul_service() {
  (
    if [ -f "$1" ]; then
      app_name="$(jq -r '.service.name' < "$1")"
    else
      app_name="$(echo "$1" | jq -r '.service.name')"
    fi
    if [[ ! -d "/usr/local/tmp" ]]; then
      mkdir /usr/local/tmp/
    fi
    service_file=/usr/local/tmp/"$app_name".json
    [ -f "$service_file" ] || (
      if [ -f "$1" ]; then
        cp "$1" "$service_file"
      else
        echo "$1" > "$service_file"
      fi
    )
    curl \
    --request PUT \
    --data @"$service_file" \
    http://consul.service.consul:8500/v1/agent/service/register?replace-existing-checks=true
  )
}

function remove_consul_service() {
  curl \
    --request PUT \
    http://consul.service.consul:8500/v1/agent/service/deregister/$1
}

function mark_consul_service_maintance() {
  curl \
    --request PUT \
    http://consul.service.consul:8500/v1/agent/service/maintenance/$1?enable=$2&reason=$3
}

function get_consul_kv() {
  curl http://consul.service.consul:8500/v1/kv/%1
}

function put_consul_kv() {
  curl \
      --request PUT \
      --data @$2 \
      http://consul.service.consul:8500/v1/kv/$1
}

function delete_consul_kv() {
  curl \
      --request DELETE \
      http://consul.service.consul:8500/v1/kv/%1
}

function take_consul_snapshot() {
  if [[ -z "$1" ]]; then
    snapshot_file="snapshot_$(date +%Y-%m-%d-%s).tar"
  else
    snapshot_file=$1
  fi

  curl -sS http://consul.service.consul/v1/snapshot?dc=docker -o ${snapshot_file}
  if [[ -f "latest_snapshot.tar" ]]; then
    rm -f "latest_snapshot.tar"
  fi
  cp $snapshot_file "latest_snapshot.tar"
  echo snapshot_file
}

function restore_consul_snapshot() {
  if [[ -z "$1" ]]; then
    snapshot_file="latest_snapshot.tar"
  else
    snapshot_file=$1
  fi
  if [[ -f "${snapshot_file}" ]]; then
    curl --request PUT --data-binary @$snapshot_file http://consul.service.consul:8500/v1/snapshot
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
    /bin/sh -c "sleep 30;nohup consul-template -consul-addr=consul.service.consul:8500 --vault-addr=http://active.vault.service.consul:8200 -template=$template_dir/$2:$3 -retry 30s -consul-retry -wait 30s -consul-retry-max-backoff=15s &"
  else
    /bin/sh -c "nohup consul-template -consul-addr=consul.service.consul:8500 --vault-addr=http://active.vault.service.consul:8200 -template=$template_dir/$2:$3:'$4' -retry 30s -consul-retry -wait 30s -consul-retry-max-backoff=15s &"
  fi
}

function expand_consul_config_from() {
  set +e
  log "Processing ${CONSUL_TEMPLATES_DIR}/$1 with variable expansion to ${CONSUL_CONFIG_DIR}/$1"
  rm -f "${CONSUL_CONFIG_DIR}/$1"
  cat "${CONSUL_TEMPLATES_DIR}/$1" | envsubst > "${CONSUL_CONFIG_DIR}/$1"
  set -e
}

