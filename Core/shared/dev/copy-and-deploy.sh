#!/bin/bash
. /mnt/d/em/Core/shared/dev/dev.env
eval "$(keychain --eval id_rsa)"
ssh -t $MANAGER_SSH ~/remove-deployment.sh
rsync -e "ssh" -avz /mnt/d/em/Core/shared/* $MANAGER_SSH:~/msf
rsync -e "ssh" -avz /mnt/d/em/Core/*.yml $MANAGER_SSH:~/msf
rsync -e "ssh" -avz /mnt/d/em/Core/shared/scripts/docker-* $MANAGER_SSH:/bin
ssh -t $MANAGER_SSH chmod -R 755 ~/msf/*
ssh -t $MANAGER_SSH ~/msf/admin/deploy-cluster.sh