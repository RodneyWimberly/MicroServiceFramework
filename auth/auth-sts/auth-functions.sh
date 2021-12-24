#!/bin/sh

if [ -d ~/msf ]; then
  # Deployment Environment
  SCRIPT_DIR=~/msf/auth
elif [ -d /mnt/d/msf ]; then
  # Development Environment
  SCRIPT_DIR=/mnt/d/msf/shared/scripts
else
  # Container Environment
  SCRIPT_DIR=/usr/local/scripts
fi

# shellcheck source=../../shared/scripts/common-functions.sh
. $SCRIPT_DIR/common-functions.sh
# shellcheck source=./auth.env
. $SCRIPT_DIR/auth.env

wait_for_auth_db() {
  while true; 
  do
    AUTH_DB_IP=$(dig @127.0.0.1 +short auth_db.service.consul | tail -n1)
    if [ -z "${AUTH_DB_IP}" ] || [ "${AUTH_DB_IP}" = ";; connection timed out; no servers could be reached" ]; then
      log_warning "Auth-Db IP was blank, retrying in 1 second."
      sleep 1
    else
      break;
    fi
  done
}

wait_for_auth_db1() {
  until nc -z auth_db.service.consul 1433;
  do
    log_warning "Auth-Db isn't responsing yet, Retrying in 1 sec."
    sleep 1
  done
  log_success "Auth-Db started"
}