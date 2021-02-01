#!/usr/bin/env bash

# {{ ansible_managed }}

# Easily exec into a random task of your service running on any container in your swarm. (uses dockernodeps in PATH as a dependency)

# ==== Examples ====

# manager1# dockerserviceexec monitoring_influxdb influx
# + ssh -t worker2 docker exec -it 8bca5bbc65c0 influx
# Connected to http://localhost:8086 version 1.4.2
# InfluxDB shell version: 1.4.2
# >
# manager1# dockerserviceexec base_reverseproxy openresty -s reload
# + ssh -t worker2 docker exec -it 8d52e578543a openresty -s reload
# Connection to worker2 closed.

set -e
set -o pipefail
set -u

# --------------------------------------------------------------------------------------
# parse parameters

if [[ $# < 2 ]] ; then
    echo ""
    echo "Usage:"
    echo "$0 <SERVICE_NAME> <EXEC_COMMAND>"
    echo ""
    echo "Examples:"
    echo "$0 base_reverseproxy openresty -s reload"
    echo "$0 base_reverseproxy bash"
    echo ""
    echo "Allows exec in a container running on another node in this swarm by using ssh."
    exit 1
else
    SERVICE="$1"
    shift
    COMMAND="$@"
fi

# --------------------------------------------------------------------------------------
# look for dependencies

if ! which dockernodeps > /dev/null ; then
    echo "dependency 'dockernodeps' not found in PATH. exiting."
    exit 1
fi

# --------------------------------------------------------------------------------------

if PAIR=$(dockernodeps $SERVICE) ; then
  NODE=${PAIR%%:*}
  CONTAINER=${PAIR#*:}
else
  exit 1
fi

# --------------------------------------------------------------------------------------

# check if tty is present (because no tty is present when running from gitlab-deployment with gitlab-runner and docker-in-docker)
if [ -t 0 ] ; then
        set -x
        ssh -t $NODE docker exec -it $CONTAINER $COMMAND
else
        set -x
        echo ssh $NODE docker exec -i $CONTAINER $COMMAND
        ssh $NODE docker exec -i $CONTAINER $COMMAND
fi
