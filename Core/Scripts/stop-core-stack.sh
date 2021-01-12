#!/bin/bash
# DESCRIPTION
#   This script performs a graceful shutdown of the consul cluster.

set -ex

run=(docker exec)
scale=(docker service scale)

count="$(docker stack ps -q core_consul-worker | wc -l)"

./Vault/scripts/stop-vault.sh

# Create a backup before shutdown
backup_file="backup_$(date +%Y-%m-%d-%s).snap"
if [ ! -d backups ]; then
  mkdir backups
fi
"${run[@]}" core_consul consul snapshot save "${backup_file}"
consul_container="$(docker stack ps -q -f name=core_consul core)"
docker cp "${consul_container}:${backup_file}" ./backups/
# Poweroff consul cluster
for x in $(eval echo {1..$count}); do
  "${run[@]}" --index="$x" core_consul-worker consul leave
done
"${run[@]}" core_consul-worker consul leave
"${run[@]}" core_consul consul leave

# Already stopped above
#"${scale[@]}" core_vault=0
"${scale[@]}" core_registry=0
"${scale[@]}" core_registry-follower=0

"${scale[@]}" core_dns-primary=0
"${scale[@]}" core_dns-secondary=0

"${scale[@]}" core_portal=0
"${scale[@]}" core_hello=0
"${scale[@]}" core_world=0

"${scale[@]}" core_jump-box=0
"${scale[@]}" core_log-viewer=0
"${scale[@]}" core_proxy=0
"${scale[@]}" core_swarm-visualizer=0
docker stack down core
