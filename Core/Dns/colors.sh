CONSUL_DOMAIN=consul
CONSUL_DATACENTER=docker

CONSUL_CONFIG_DIR=/consul/config
CONSUL_DATA_DIR=/consul/data
CONSUL_CERT_DIR=/consul/certs
CONSUL_TEMPLATES_DIR=/consul/templates
VAULT_CERT_DIR=/vault/certs
CORE_SCRIPT_DIR=/usr/local/scripts

CONSUL_SERVER=tasks.core_consul
CONSUL_ENDPOINT="${CONSUL_SERVER}:8500"
CONSUL_API="http://${CONSUL_ENDPOINT}/v1/"
CONSUL_AGENT_API="${CONSUL_API}agent/"
CONSUL_KV_API="${CONSUL_API}kv/"

CORE_STACK_NAME=core
AGENT_CLUSTER_ADDR=tasks.core_portainer-agent:9001

LOGS_ENABLED=true
LOGS_TOKEN=177434fe-0862-43e4-a162-de767c346723
LOGS_RECEIVER_URL=http://tasks.log_api:9200
