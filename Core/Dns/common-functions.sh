#!/bin/sh

if [[ -f ./core.env ]]; then
  source ./core.env
elif [[ -f /usr/local/scripts/core.env ]]; then
  source /usr/local/scripts/core.env
elif [[ -f /tmp/consul/scripts/core.env ]]; then
  source /tmp/consul/scripts/core.env
fi

#################################################################################
function expand_config_file_from() {
  set +e
  log "Processing ${CONSUL_TEMPLATES_DIR}/$1 with variable expansion to ${CONSUL_CONFIG_DIR}/$1"
  rm -f "${CONSUL_CONFIG_DIR}/$1"
  cat "${CONSUL_TEMPLATES_DIR}/$1" | envsubst > "${CONSUL_CONFIG_DIR}/$1"
  set -e
}

function add_path() {
  export PATH=$1:${PATH}
  log "PATH has been updated to ${PATH} "
}

#################################################################################
function get_ip_from_adapter() {
  ip -o -4 addr list $1 | head -n1 | awk '{print $4}' | cut -d/ -f1
}

function hostip() {
  ip -o ro get $(ip ro | awk '$1 == "default" { print $3 }') | awk '{print $5}'
}

function get_ip_from_name() {
  dig +short $1 | tail -n1
}

function show_hosting_details() {
  log "-----------------------------------------------------------"
  log "- Swarm Details"
  log "-----------------------------------------------------------"
  log_detail "Node Id: ${NODE_ID}"
  log_detail "Node Name: ${NODE_NAME}"
  log_detail "Node Address: ${NODE_IP}"
  log_detail "Manager Node: ${NODE_IS_MANAGER}"
  log_detail "Manager Node Count: ${NUM_OF_MGR_NODES}"
  log ""
  log "-----------------------------------------------------------"
  log "- Container Details"
  log "-----------------------------------------------------------"
  log_detail "Container Name: ${CONTAINER_NAME}"
  log_detail "Container Address: ${CONTAINER_IP}"
  log ""
  log "-----------------------------------------------------------"
  log "- Network Details"
  log "-----------------------------------------------------------"
  log_detail "eth0 Address: ${ETH0_IP}"
  log_detail "eth1 Address: ${ETH1_IP}"
  log_detail "eth2 Address: ${ETH2_IP}"
  log_detail "eth3 Address: ${ETH3_IP}"
  log_detail "eth4 Address: ${ETH4_IP}"
  log ""
}

function get_hosting_details() {
  NODE_INFO=$(docker_api "info")
  export NUM_OF_MGR_NODES=$(echo ${NODE_INFO} | jq -r -M '.Swarm.Managers')
  export NODE_IP=$( echo ${NODE_INFO} | jq -r -M '.Swarm.NodeAddr')
  export NODE_ID=$(echo ${NODE_INFO} | jq -r -M '.Swarm.NodeID')
  export NODE_NAME=$(echo ${NODE_INFO} | jq -r -M '.Name')
  export NODE_IS_MANAGER=$(echo ${NODE_INFO} | jq -r -M '.Swarm.ControlAvailable')
  export CONTAINER_IP=$(hostip)
  export CONTAINER_NAME=$(hostname)
  export ETH0_IP=$(get_ip_from_adapter eth0)
  export ETH1_IP=$(get_ip_from_adapter eth1)
  export ETH2_IP=$(get_ip_from_adapter eth2)
  export ETH3_IP=$(get_ip_from_adapter eth3)
  export ETH4_IP=$(get_ip_from_adapter eth4)
}

function hosting_details() {
  get_hosting_details
  show_hosting_details
}


function docker_api() {
  docker_api_url="http://localhost/${1}"
  docker_api_method="${2}"
  if [[ -z "${docker_api_method}" ]]; then
    docker_api_method="GET"
  fi

  curl -sS --connect-timeout 180 --unix-socket /var/run/docker.sock -X "${docker_api_method}" "${docker_api_url}"
}

#################################################################################
# G.et J.SON V.alue
function gjv() {
  if [[ -f "$2" ]]; then
    cat $2 | jq -r -M '.$1'
  else
    echo $2 | jq -r -M '.$1'
  fi
}

# S.et J.SON V.alue
function sjv() {
  if [[ -f "$3" ]]; then
    cat $3 | jq ". + { \"$1\": \"$2\" }" > $3
  else
    echo $3 | jq ". + { \"$1\": \"$2\" }" > $3
  fi
}

#################################################################################
function log() {
  log_raw "[INF] $1"
}

function log_detail() {
  log_raw "[DTL]  ====> $1"
}

function log_error() {
  log_raw "[ERR] $1"
}

function log_warning() {
  log_raw "[WAR] $1"
}

function log_raw() {
  echo "$(date +"%T"): $1"
}

#################################################################################
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

function run_consul_template() {
  # $1 is the source file
  # $2 is the template file name
  # $3 is the destination
  # $4 is the reload command and may not exist
  template_dir=/etc/template
  if [[ ! -d "${template_dir}" ]]; then
    mkdir $template_dir
  fi
  cp $1 $template_dir/$2
  if [ -z "$4" ]; then
    /bin/sh -c "sleep 30;nohup consul-template -template=$template_dir/$2:$3 -retry 30s -consul-retry -wait 30s -consul-retry-max-backoff=15s &"
  else
    /bin/sh -c "nohup consul-template -template=$template_dir/$2:$3:'$4' -retry 30s -consul-retry -wait 30s -consul-retry-max-backoff=15s &"
  fi
}

#################################################################################
# These functions only work for tasks/services deployed to this node (not other nodes in the SWARM, use SSH)
function exec_service() {
  docker exec $(docker ps -q -f name=$1) $2
}

function service_shell() {
  docker exec -it $(docker ps -q -f name=$1) /bin/sh
}
