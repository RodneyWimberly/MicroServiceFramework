#!/bin/bash
# Ignore non existent vars
set -u
# Terminate on command error
set -e
# Apply -e to pipe commands
set -o pipefail
# Output commands
# set -x

cd /mnt/d/em/Core/shared/dev || exit 1
. dev.env
eval "$(keychain --eval id_rsa)"

ssh -t "$MANAGER_SSH" ~/remove-deployment.sh
set +e
rsync -e "ssh" -avz /mnt/d/em/Core/shared/* "$MANAGER_SSH":~/msf
rsync -e "ssh" -avz /mnt/d/em/Core/*.yml "$MANAGER_SSH":~/msf
rsync -e "ssh" -avz /mnt/d/em/Core/shared/scripts/docker-* "$MANAGER_SSH":/bin
set -e
ssh -t "$MANAGER_SSH" chmod -R 755 ~/msf/*
ssh -t "$MANAGER_SSH" ~/msf/admin/deploy-cluster.sh