#!/bin/bash
set -ueo pipefail
set +x

# shellcheck source=../../../shared/scripts/development-functions.sh
. /mnt/d/msf/shared/scripts/development-functions.sh

log "logs: Creating file links for shared files."

link_file $MSF_DIR/.gitignore $LOGS_DIR/.gitignore
link_file $MSF_DIR/.dockerignore $LOGS_DIR/.dockerignore

log_detail "Making links for Deployment"
link_file $LOGS_DIR/scripts/logs.env $LOGS_DIR/scripts/deployment/package/logs.env
link_file $LOGS_DIR/scripts/deployment/deploy-logs-stack.sh $LOGS_DIR/scripts/deployment/package/deploy-logs-stack.sh
link_file $LOGS_DIR/docker-compose.yml $LOGS_DIR/scripts/deployment/package/docker-compose.yml
link_file $LOGS_DIR/scripts/logs-functions.sh $LOGS_DIR/scripts/deployment/package/logs-functions.sh

log_detail "Making links for LogAgent"
link_file $MSF_DIR/.dockerignore $LOGS_DIR/logagent/.dockerignore
link_file $LOGS_DIR/scripts/logs.env $LOGS_DIR/logagent/logs.env
link_common_functions $LOGS_DIR/logagent

log_detail "Making links for Mongo"
link_file $MSF_DIR/.dockerignore $LOGS_DIR/mongo/.dockerignore
link_file $LOGS_DIR/scripts/logs.env $LOGS_DIR/mongo/logs.env
link_file $SHARED_CONFIG/consul-service.json $LOGS_DIR/mongo/consul-service.json
link_common_functions $LOGS_DIR/mongo

log_detail "Making links for ElasticSearch"
link_file $MSF_DIR/.dockerignore $LOGS_DIR/elasticsearch/.dockerignore
link_file $LOGS_DIR/scripts/logs.env $LOGS_DIR/elasticsearch/logs.env
link_file $SHARED_CONFIG/consul-service.json $LOGS_DIR/elasticsearch/consul-service.json
link_common_functions $LOGS_DIR/elasticsearch

log_detail "Making links for GrayLog"
link_file $MSF_DIR/.dockerignore $LOGS_DIR/graylog/.dockerignore
link_file $LOGS_DIR/scripts/logs.env $LOGS_DIR/graylog/logs.env
link_file $SHARED_CONFIG/consul-service.json $LOGS_DIR/graylog/consul-service.json
link_common_functions $LOGS_DIR/graylog  

