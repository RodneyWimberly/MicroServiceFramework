#!/bin/bash
# DESCRIPTION
# Starts the core docker stack

clear

source ./Scripts/common.sh

echo -e "${GREEN} ******* Unassigning Docker Secrets / Configs ******* ${NC}"

# DNS
unassign_config registry-agent.sh core_dns-primary
unassign_config dns-dnsmasq.conf core_dns-primary
unassign_config dns-containerpilot.json5 core_dns-primary
