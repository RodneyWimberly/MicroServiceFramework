#!/bin/sh /bin/bash

if [ -d ~/msf ]; then
  SCRIPT_DIR=~/msf/scripts
elif [ -d /mnt/d/em ]; then
  SCRIPT_DIR=/mnt/d/em/Core/shared/scripts
else
  SCRIPT_DIR=/usr/local/scripts
fi
# shellcheck source=./core.env
. "${SCRIPT_DIR}"/core.env

set_static_ip() {
  if [ -z "${STATIC_IP}" ]; then
    echo "Using default IP from Docker"
  else
    echo "Found static IP: ${STATIC_IP} using it"
    ifconfig eth0 "${STATIC_IP}" netmask 255.255.0.0 up
  fi
}

get_ip_from_adapter() {
  ip -o -4 addr list "$1" | head -n1 | awk '{print $4}' | cut -d/ -f1
}

hostip() {
  ip -o ro get "$(ip ro | awk '$1 == "default" { print $3 }')" | awk '{print $5}'
}

update_dns_config() {
  log "Updating resolv.conf with DNS server addresses"
  echo "nameserver 192.168.100.2" >>/etc/resolv.conf
  echo "nameserver 192.168.100.3" >>/etc/resolv.conf
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
  log_detail "CONTAINER_IP: ${CONTAINER_IP}"

  log_header "Network Interface Environment Variables"
  log_detail "ETH0_IP: ${ETH0_IP}"
  log_detail "ETH1_IP: ${ETH1_IP}"
  log_detail "ETH2_IP: ${ETH2_IP}"
  log_detail "ETH3_IP: ${ETH3_IP}"
  log_detail "ETH4_IP: ${ETH4_IP}"
}

get_hosting_details() {
  NODE_INFO=$(docker_api "info")
  NUM_OF_MGR_NODES=$(echo "${NODE_INFO}" | jq -r -M '.Swarm.Managers')
  NODE_IP=$(echo "${NODE_INFO}" | jq -r -M '.Swarm.NodeAddr')
  NODE_ID=$(echo "${NODE_INFO}" | jq -r -M '.Swarm.NodeID')
  NODE_NAME=$(echo "${NODE_INFO}" | jq -r -M '.Name')
  NODE_IS_MANAGER=$(echo "${NODE_INFO}" | jq -r -M '.Swarm.ControlAvailable')
  CONTAINER_IP=$(hostip)
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
  docker_api_method="${2}"
  if [ -z "${docker_api_method}" ]; then
    docker_api_method="GET"
  fi

  curl -sS --connect-timeout 180 --unix-socket /var/run/docker.sock -X "${docker_api_method}" "${docker_api_url}"
}

add_path() {
  export PATH=$1:${PATH}
  log "PATH has been updated to ${PATH} "
}

keep_container_alive() {
  log_detail "Doing a wait loop to keep the container alive."
  while true ; do
    trap 'break' QUIT TERM EXIT
    wait
  done
  # while true ;do wait ;done
  # trap "exec sh -c 'while true ;do wait ;done'" QUIT TERM
}
