#!/bin/bash

# Setup environment
# Ignore non existent vars
# set -u
set -o nounset
# Terminate on command error
# set -e
set -o errexit
# Apply -e to pipe commands
set -o pipefail
# Output commands
# set -x
# set -oxtrace

apk add screen git gettext curl jq rsync gawk
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa
echo "$WORKER_IP worker1" >> /etc/hosts
echo "$MANAGER_IP manager1" >> /etc/hosts
echo "caption always \"%{= kc}Screen session %S on %H %-20=%{= .m}%D %d.%m.%Y %0c\"" > ~/.screenrc
screen -q -t stack-deployment -S stack-deployment
