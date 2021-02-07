#!/bin/sh

if [[ -d ~/msf ]]; then
  SCRIPT_DIR=~/msf/Core/shared/scripts
elif [[ -d /mnt/d/em ]]; then
  SCRIPT_DIR=/mnt/d/em/Core/shared/scripts
else
  SCRIPT_DIR=/usr/local/scripts
fi
source "${SCRIPT_DIR}"/core.env

function get_ip_from_adapter() {
  ip -o -4 addr list $1 | head -n1 | awk '{print $4}' | cut -d/ -f1
}

function hostip() {
  ip -o ro get $(ip ro | awk '$1 == "default" { print $3 }') | awk '{print $5}'
}

function update_dns_config() {
  echo " "
  log "Looking up IP address for tasks.core_dns"
  DNS_IP=
  while [[ -z "${DNS_IP}" ]]; do
    DNS_IP=$(get_ip_from_name "tasks.core_dns")
    if [[ -z "${DNS_IP}" ]]; then
      log_warn "Unable to locate tasks.core_dns, retrying in 1 second."
      sleep 1
    fi
  done
  export DNS_IP
  echo "nameserver ${DNS_IP}" > /etc/resolv.conf
  echo "nameserver 127.0.0.1" >> /etc/resolv.conf
  log_header "DNS Details"
  log_detail "DNS IP: ${CONSUL_IP}"
}

function get_consul_ip() {
  echo " "
  log "Looking up IP address for consul.service.consul"
  CONSUL_IP=
  while [[ -z "${CONSUL_IP}" ]]; do
    CONSUL_IP=$(get_ip_from_name "consul.service.consul")
    if [[ -z "${CONSUL_IP}" ]]; then
      log_warn "Unable to locate consul.service.consul, retrying in 1 second."
      sleep 1
    fi
  done
  export CONSUL_IP
  export CONSUL_HTTP_ADDR=http://${CONSUL_IP}:8500
  log_header "Consul Details"
  log_detail "Consul IP: ${CONSUL_IP}"
  log_detail "Consul HTTP Addr: ${CONSUL_HTTP_ADDR}"
}

function get_ip_from_name() {
  dig +short $1 | tail -n1
}

function show_hosting_details() {
  log_header "Swarm Details"
  log_detail "Node Id: ${NODE_ID}"
  log_detail "Node Name: ${NODE_NAME}"
  log_detail "Node Address: ${NODE_IP}"
  log_detail "Manager Node: ${NODE_IS_MANAGER}"
  log_detail "Manager Node Count: ${NUM_OF_MGR_NODES}"
  log_header "Container Details"
  log_detail "Container Name: ${CONTAINER_NAME}"
  log_detail "Container Address: ${CONTAINER_IP}"
  log_header "Network Details"
  log_detail "eth0 Address: ${ETH0_IP}"
  log_detail "eth1 Address: ${ETH1_IP}"
  log_detail "eth2 Address: ${ETH2_IP}"
  log_detail "eth3 Address: ${ETH3_IP}"
  log_detail "eth4 Address: ${ETH4_IP}"
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
