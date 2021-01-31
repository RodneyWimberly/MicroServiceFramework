#!/bin/bash
# DESCRIPTION
#   This script performs a graceful shutdown of the consul cluster.  Before
#   final shutdown of consul, a backup of the cluster is taken.

set -e

if [ ! -f "${1:-}" -a ! -d backups/ ]; then
  echo 'ERROR: No consul snapshot specified from backups/ directory.' >&2
  exit 1
fi
if [ -n "${1-}" -a ! -f "${1:-}" ]; then
  echo "ERROR: The file '${1:-}' does not exist." >&2
  exit 1
else
  local_file="${1:-}"
fi
if [ -z "${local_file:-}" ] ; then
  local_file="$(ls -t backups/* | head -n1)"
fi

run=(docker exec)
set -x

backup_file="${local_file##*/}"
consul_container="$(docker stack ps -q -f name=core_consul core)"
docker cp "${local_file}" "${consul_container}:${backup_file}"
"${run[@]}" core_consul consul snapshot restore "${backup_file}"
