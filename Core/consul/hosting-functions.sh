#!/bin/sh /bin/bash

if [ -d ~/msf ]; then
  SCRIPT_DIR=~/msf/Core/shared/scripts
elif [ -d /mnt/d/em ]; then
  SCRIPT_DIR=/mnt/d/em/Core/shared/scripts
else
  SCRIPT_DIR=/usr/local/scripts
fi
. "${SCRIPT_DIR}"/core.env

get_ip_from_adapter() {
  ip -o -4 addr list $1 | head -n1 | awk '{print $4}' | cut -d/ -f1
}

hostip() {
  ip -o ro get "$(ip ro | awk '$1 == "default" { print $3 }')" | awk '{print $5}'
}

update_dns_config() {
  log "Looking up IP address for dns.service.consul"
  DNS_IP=
  while [ -z "${DNS_IP}" ]; do
    DNS_IP=$(get_ip_from_name "dns.service.consul")
    if [ -z "${DNS_IP}" ]; then
      log_warn "Unable to locate dns.service.consul, retrying in 1 second."
      sleep 1
    fi
  done
  export DNS_IP
  echo "nameserver ${DNS_IP}" >>/etc/resolv.conf
  log_header "DNS Details"
  log_detail "DNS IP: ${CONSUL_IP}"
}

get_ip_from_name() {
  dig +short $1 | tail -n1
}

show_hosting_details() {
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

get_hosting_details() {
  NODE_INFO=$(docker_api "info")
  export NUM_OF_MGR_NODES=$(echo ${NODE_INFO} | jq -r -M '.Swarm.Managers')
  export NODE_IP=$(echo ${NODE_INFO} | jq -r -M '.Swarm.NodeAddr')
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
