#!/bin/bash
# DESCRIPTION
# Starts the core docker stack

clear

source ./Scripts/common.sh

echo -e "${GREEN} ******* Updating Docker Secrets / Configs ******* ${NC}"
# Common
add_config registry-agent.sh ./Dns/registry-agent.sh

# DNS
add_config dns-containerpilot.json5 ./Dns/containerpilot.json5
add_config dns-dnsmasq.conf ./Dns/dnsmasq.conf


# Portal
#echo -e "${LT_GREEN} Adding portal configs and secrets ${NC}"
#docker config create portal-containerpilot.json5 ./Portal/root/etc/containerpilot.json5
#docker config create portal-fastcgi_parms ./Portal/root/etc/nginx/fastcgi_parms
#docker config create portal-gzip.conf ./Portal/root/etc/nginx/gzip.conf
#docker config create portal-http.conf ./Portal/root/etc/nginx/http.conf
#docker config create portal-mime.types ./Portal/root/etc/nginx/mime.types
#docker config create portal-nginx.conf ./Portal/root/etc/nginx/nginx.conf
#docker config create portal-proxy.conf ./Portal/root/etc/nginx/proxy.conf
#docker config create portal-ssl.conf ./Portal/root/etc/nginx/ssl.conf
#docker config create portal-nginx-template.conf ./Portal/root/etc/nginx/tmp/nginx.conf
#docker secret create portal-ca-cert ./Portal/root/etc/nginx/certs/cacerts.pem
#docker secret create portal-server-cert ./Portal/root/etc/nginx/certs/consul.pfx
#docker secret create portal-server-cert-key ./Portal/root/etc/nginx/certs/consul.key

# Registry
#echo -e "${LT_GREEN} Adding registry configs and secrets ${NC}"
#docker secret create registry-ca-cert ./configs/consul-agent-ca.pem
#docker secret create registry-server-cert ./configs/docker-server-consul-0.pem
#docker secret create registry-server-cert-key ./configs/docker-server-consul-0-key.pem
#docker secret create registry-client-cert ./configs/docker-client-consul-0.pem
#docker secret create registry-client-cert-key ./configs/docker-client-consul-0-key.pem
