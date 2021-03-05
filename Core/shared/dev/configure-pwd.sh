#!/bin/bash
# Ignore non existent vars
set -u
# Terminate on command error
#set -e
# Apply -e to pipe commands
set -o pipefail
# Output commands
# set -x

cd /mnt/d/em/Core/shared/dev || exit 1
. dev.env

eval "$(keychain --eval id_rsa)"

envsubst < /mnt/d/em/Core/shared/admin/configure-host-template.sh > /mnt/d/em/Core/shared/admin/configure-host.sh
scp /mnt/d/em/Core/shared/admin/configure-host.sh $MANAGER_SSH:~/configure-host.sh
scp /mnt/d/em/Core/shared/admin/remove-deployment.sh $MANAGER_SSH:~/remove-deployment.sh
ssh -t $MANAGER_SSH chmod -R 755 ~/*
ssh -t $MANAGER_SSH ~/configure-host.sh
