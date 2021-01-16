#!/bin/bash
# DESCRIPTION
# Starts the core docker stack

clear

source ./Scripts/common.sh

echo -e "${GREEN} ******* Assigning Docker Secrets / Configs ******* ${NC}"

# DNS
assign_config "registry-agent.sh" "/bin/registry-agent.sh" "core_dns-primary"
assign_config dns-dnsmasq.conf /etc/dnsmasq/consul.conf core_dns-primary
assign_config dns-containerpilot.json5 /etc/containerpilot.json5 core_dns-primary
