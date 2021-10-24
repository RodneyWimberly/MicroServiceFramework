#!/bin/sh
set +e
set +x

# Make our stuff available
# shellcheck source=./common-functions.sh
. "${CORE_SCRIPT_DIR}"/common-functions.sh
add_path "${CORE_SCRIPT_DIR}"

# Restart container if the current IP address is a reserved IP
if [ "$(restart_if_reserved_ip)" -eq 1 ]; then
  log_error "The IP of this container is a reserved address. Restarting"
  exit 1
fi

# Start SysLog so we can forward logs to Graylog. 
# open-rc should start this service but it doesn't
cp /consul/templates/rsyslog.conf /etc/rsyslog.conf
log_info "Starting rsyslog"
su-exec root rc-status
su-exec root rc-service rsyslog start
until nc -z 127.0.0.1 514;
do
  log_warning "Rsyslog isn't responsing yet, Retrying in 1 sec."
  sleep 1
done
log_success "Rsyslog started"

# Get Docker/Node/Hosting information from the Docker API for use in configuration
hosting_details
export DOCKER_HOST=tcp://$NODE_IP:2375
log_detail "DOCKER_HOST: $DOCKER_HOST"

# Merge expanded variables with configuration templates and place in the config folder
log_detail "Linking the /consul/templates folder to the /etc/templates folder"
ln -s /consul/templates /etc/templates

# update_dns_config depends on /etc/templates folder so this must come after the linking of /etc/templates
# update_dns_config
# log "Starting Graylog watcher"
# /bin/sh -c "/usr/local/scripts/update-graylog.sh 120" &
export CONSUL_IP="127.0.0.1"
export CONSUL_AGENT="${CONSUL_IP}:8500"
export CONSUL_HTTP_ADDR="http://${CONSUL_IP}:8500"
export CONSUL_HTTPS_ADDR="https://${CONSUL_IP}:8501"
export CONSUL_RPC_ADDR="rpc://${CONSUL_IP}:8400"
export CONSUL_API="${CONSUL_HTTP_ADDR}/v1"
export CONSUL_AGENT_API="${CONSUL_API}/agent"
export CONSUL_KV_API="${CONSUL_API}/kv"
run_consul_template /consul/templates/rsyslog.conf rsyslog.conf /etc/rsyslog.conf "rc-service rsyslog restart"

expand_consul_config_from "common.json"
if [ "${NODE_IS_MANAGER}" = "true" ]; then
  agent_mode="server"
  expand_consul_config_from "server.json"
else
  agent_mode="client"
  expand_consul_config_from "client.json"
fi

export SERVICE_CHECK_URL=http://${ETH0_IP}:8500/v1/status/leader
export SERVICE_CHECK_METHOD=GET
export SERVICE_CHECK_BODY={}
add_consul_service "consul" 8500 "\"api\", \"www\"" SERVICE_ID1 consul-http-service.json
add_consul_service "consul" 53 "\"dns\"" SERVICE_ID2
log "Starting Consul in ${agent_mode} mode."

/bin/sh -c "nohup update-graylog.sh 300 &"
docker-entrypoint.sh "$@"
remove_consul_service "$SERVICE_ID2"
remove_consul_service "$SERVICE_ID1"
