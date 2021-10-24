#!/bin/sh
set +e
set +x

# shellcheck source=./core-functions.sh
. "${CORE_SCRIPT_DIR}"/core-functions.sh

# Put our script folder in the path
add_path "${CORE_SCRIPT_DIR}"

# Set static IP
set_static_ip

# Start SysLog so we can forward logs to Graylog. 
# open-rc should start this service but it doesn't
# log_info "Starting rsyslog"
# su-exec root rc-status
# su-exec root rc-service rsyslog start
# until nc -z 127.0.0.1 514;
# do
#   log_warning "Rsyslog isn't responsing yet, Retrying in 1 sec."
#   sleep 1
# done
# log_success "Rsyslog started"

# Get Docker/Node/Hosting information from the Docker API for use in configuration
hosting_details

# Get Consul address so we can register our service and resolve other services
get_consul_ip

# update_dns_config

log_detail "Merging expanded variables and updating configuration based on Consul cluster deployment"
envsubst < /etc/templates/1.consul.conf > /etc/templates/1.consul-template.conf
envsubst < /etc/templates/containerpilot.json5 > /etc/containerpilot.json5
export CONTAINERPILOT=/etc/containerpilot.json5

log_detail "Starting ContainerPilot"
/bin/containerpilot
