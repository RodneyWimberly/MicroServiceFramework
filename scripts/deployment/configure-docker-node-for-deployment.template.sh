#!/bin/bash
set -ueo pipefail
set +x

apk add \
    screen \
    git \
    gettext \
    curl \
    jq \
    rsync \
    gawk
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa
echo "$WORKER_IP worker1" >> /etc/hosts
echo "$MANAGER_IP manager1" >> /etc/hosts
ssh -t worker1 'echo "Connected!"'
ssh -t manager1 'echo "Connected!"'
echo "caption always \"%{= kc}Screen session %S on %H %-20=%{= .m}%D %d.%m.%Y %0c\"" > ~/.screenrc
screen -q -t stack-deployment -S stack-deployment