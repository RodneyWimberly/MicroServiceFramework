#!/bin/bash
set -ue
set +x


# shellcheck source=../development.env
. /mnt/d/msf/scripts/development/development.env
# shellcheck source=../development-functions.sh
. /mnt/d/msf/scripts/development/development-functions.sh

eval "$(keychain --eval id_rsa)"

envsubst < /mnt/d/msf/scripts/deployment/configure-docker-node-for-deployment.template.sh > /mnt/d/msf/scripts/deployment/configure-docker-node-for-deployment.sh
set +e
scp /mnt/d/msf/scripts/deployment/configure-docker-node-for-deployment.sh $MANAGER_SSH:~/configure-docker-node-for-deployment.sh
scp /mnt/d/msf/scripts/deployment/remove-deployment.sh $MANAGER_SSH:~/remove-deployment.sh
set -e
ssh -t $MANAGER_SSH chmod -R 755 ~/*
ssh -t $MANAGER_SSH ~/configure-docker-node-for-deployment.sh
