#!/bin/bash
set -ueo pipefail
set +x

if true; then
    docker stack rm logs
fi
if [ -f ~/msf/core/shutdown-cluster.sh ]; then
    ~/msf/core/shutdown-cluster.sh
fi
cd ~ || exit 1  >/dev/null 2>&1
rm -fr ~/msf >/dev/null 2>&1
mkdir ~/msf >/dev/null 2>&1