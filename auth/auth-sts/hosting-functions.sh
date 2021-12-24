#!/bin/sh /bin/bash

restart_if_reserved_ip() {
  INTERFACE=${1:-eth0}
  log "Checking IP address on interface ${INTERFACE} to ensure it is not reserved"
  IP=$(get_ip_from_adapter "${INTERFACE}")
  if [ "${IP}" = "192.168.100.2" ] | [ "${IP}" = "192.168.100.3" ] ; then
    log_error "This container is using a reserved IP address on interface ${INTERFACE}. Killing container so it can be restarted"
    exit 1
  fi
  exit 0;
}

set_static_ip() {
  INTERFACE=${1:-eth0}
  if [ -z "${STATIC_IP}" ]; then
    restart_if_reserved_ip "${INTERFACE}"
    echo "Using default IP on interface ${INTERFACE} from Docker"
  else
    echo "Found static IP: ${STATIC_IP} using it for interface ${INTERFACE}"
    ifconfig "${INTERFACE}" "${STATIC_IP}" netmask 255.255.0.0 up
  fi
}

get_ip_from_adapter() {
  INTERFACE=${1:-eth0}
  ip -o -4 addr list "$INTERFACE" | head -n1 | awk '{print $4}' | cut -d/ -f1
}

hostip() {
  ip -o ro get "$(ip ro | awk '$1 == "default" { print $3 }')" | awk '{print $5}'
}

hostid() {
  basename "$(head /proc/1/cgroup)"
}

update_dns_config() {
  log "Updating resolv.conf with DNS server addresses"
  cat /etc/templates/resolv.conf > /etc/resolv.conf
}

get_ip_from_name() {
  dig +short "$1" | tail -n1
}

show_hosting_details() {
  log_header "Swarm Environment Variables"
  log_detail "NODE_ID: ${NODE_ID}"
  log_detail "NODE_NAME: ${NODE_NAME}"
  log_detail "NODE_IP: ${NODE_IP}"
  log_detail "NODE_IS_MANAGER: ${NODE_IS_MANAGER}"
  log_detail "NUM_OF_MGR_NODES: ${NUM_OF_MGR_NODES}"

  log_header "Container Environment Variables"
  log_detail "CONTAINER_NAME: ${CONTAINER_NAME}"
  log_detail "CONTAINER_ID: ${CONTAINER_ID}"
  log_detail "CONTAINER_IP: ${CONTAINER_IP}"

  log_header "Network Interface Environment Variables"
  log_detail "ETH0_IP: ${ETH0_IP}"
  log_detail "ETH1_IP: ${ETH1_IP}"
  log_detail "ETH2_IP: ${ETH2_IP}"
  log_detail "ETH3_IP: ${ETH3_IP}"
  log_detail "ETH4_IP: ${ETH4_IP}"
}

get_hosting_details() {
  docker_api "info"
  NUM_OF_MGR_NODES=$(jq -r -M '.Swarm.Managers' < /usr/local/scripts/docker-api.json)
  NODE_IP=$(jq -r -M '.Swarm.NodeAddr' < /usr/local/scripts/docker-api.json)
  NODE_ID=$(jq -r -M '.Swarm.NodeID' < /usr/local/scripts/docker-api.json)
  NODE_NAME=$(jq -r -M '.Name' < /usr/local/scripts/docker-api.json)
  NODE_IS_MANAGER=$(jq -r -M '.Swarm.ControlAvailable' < /usr/local/scripts/docker-api.json)
  CONTAINER_IP=$(hostip)
  CONTAINER_ID=$(hostid)
  CONTAINER_NAME=$(hostname)
  ETH0_IP=$(get_ip_from_adapter eth0)
  ETH1_IP=$(get_ip_from_adapter eth1)
  ETH2_IP=$(get_ip_from_adapter eth2)
  ETH3_IP=$(get_ip_from_adapter eth3)
  ETH4_IP=$(get_ip_from_adapter eth4)
  export NUM_OF_MGR_NODES
  export NODE_IP
  export NODE_ID
  export NODE_NAME
  export NODE_IS_MANAGER
  export CONTAINER_IP
  export CONTAINER_ID
  export CONTAINER_NAME
  export ETH0_IP
  export ETH1_IP
  export ETH2_IP
  export ETH3_IP
  export ETH4_IP
}

hosting_details() {
  get_hosting_details
  show_hosting_details
}

docker_api() {
  docker_api_url="http://localhost/${1}"
  docker_api_method="${2:-GET}"
  rm -f /usr/local/scripts/docker-api.json
  curl -o /usr/local/scripts/docker-api.json -sS --connect-timeout 180 --unix-socket /var/run/docker.sock -X "${docker_api_method}" "${docker_api_url}"
}

add_path() {
  export PATH=$1:${PATH}
  log "PATH has been updated to ${PATH} "
}

keep_container_alive() {
  log_detail "Starting a process to keep the container alive."
  while true ; do
    trap 'break' QUIT TERM EXIT
    wait
  done
}
