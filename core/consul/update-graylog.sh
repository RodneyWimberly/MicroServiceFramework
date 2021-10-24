#!/usr/bin/env sh
set +e
set +x

# Make our stuff available
# shellcheck source=./common-functions.sh
. "${CORE_SCRIPT_DIR}"/common-functions.sh

wait_time=${1:-0}
log_info "Waiting $wait_time seconds before looking for Graylog service"
sleep "$wait_time"
start_ts=$(date +%s)
log_info "Looking for Graylog service"
until dig @127.0.0.1 graylog.service.consul >/dev/null 2>&1;
do
  log_detail "Graylog service is not responding, waiting 15 seconds before retrying"
  sleep 15
done
while true; 
do
  GRAYLOG_IP=$(dig @127.0.0.1 +short graylog.service.consul | tail -n1)
  if [ -z "${GRAYLOG_IP}" ] || [ "${GRAYLOG_IP}" = ";; connection timed out; no servers could be reached" ]; then
    log_warning "Graylog IP was blank, retrying in 1 second."
    sleep 1
  else
    break; 
  fi
done
export GRAYLOG_IP

log_info "Looking for Graylog Syslog TCP input"
until nc -z "${GRAYLOG_IP}" 1514;
do
  log_warning "Greylog Syslog TCP input isn't responsing yet, Retrying in 1 sec."
  sleep 1
done
log_success "Greylog Syslog TCP input started. Updating /etc/rsyslog.conf"

echo "*.* @@${GRAYLOG_IP}:1514;RSYSLOG_SyslogProtocol23Format" >> /etc/rsyslog.conf
su-exec root rc-service rsyslog restart
log_success "Graylog service responded with IP $GRAYLOG_IP and rsyslog was updated!" "$start_ts"
