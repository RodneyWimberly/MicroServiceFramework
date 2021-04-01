#!/bin/sh
set +e
set +x

# shellcheck source=./core-functions.sh
. "${CORE_SCRIPT_DIR}"/core-functions.sh

# Put our script folder in the path
add_path "${CORE_SCRIPT_DIR}"

# Set static IP
set_static_ip

# Get Docker/Node/Hosting information from the Docker API for use in configuration
hosting_details

# Get Consul address so we can register our service and resolve other services
get_consul_ip

log_detail "Merging expanded variables and updating configuration based on Consul cluster deployment"
envsubst < /etc/templates/1.consul.conf > /etc/templates/1.consul-template.conf
envsubst < /etc/templates/containerpilot.json5 > /etc/containerpilot.json5
export CONTAINERPILOT=/etc/containerpilot.json5

log_detail "Starting ContainerPilot"
/bin/containerpilot
