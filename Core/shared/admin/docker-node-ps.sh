#!/usr/bin/env bash

# Returns the docker node-id and the container-id in format NODE-ID:CONTAINER-ID
#   running the given service as parameter

# docker-node-ps [-a] <SERVICE_NAME>
# ==== Examples ====
# manager1# docker-node-ps monitoring_influxdb
# worker2:8bca5bbc65c0

# manager1# docker-node-ps -a base_dnsmasq
# manager1:b83fa2105cbf
# worker1:29ff6539d824
# worker2:489d1cb42f1e

set -u
set -e
set -o pipefail

ALL=false
CONTAINERFOUND=false

# --------------------------------------------------------------------------------------

# parse parameters

if [[ $# = 0 ]] ; then
    echo ""
    echo "Usage:"
    echo "$0 [-a] <SERVICE_NAME>"
    echo ""
    echo "Example:"
    echo "$0 stack1_influxdb"
    echo "$0 -a stack1_influxdb"
    echo ""
    echo "Returns the docker node-id and the container-id in format NODE-ID:CONTAINER-ID running the given service as parameter."
    echo "If the option '-a' is not used, the search exits with the first pair found."
    exit 1
fi

for PARAMETER in $@ ; do
    case $1 in
        -a)
            ALL=true
        shift
            ;;
        *_*)
              SERVICENAME=$1
              shift
        ;;
    *)
            echo "$1 is not a valid parameter. Run $0 without parameters to get usage."
            exit 1
            ;;
    esac
done

# --------------------------------------------------------------------------------------

# check if ssh-agent contains key
if ! ssh-add -l >/dev/null ; then
    echo ssh-agent does not contain key. Be sure to use key-forwarding with ssh.
    exit 1
fi

# --------------------------------------------------------------------------------------


# --------------------------------------------------------------------------------------
# parse docker nodes running the service
for NODEID in $(docker node ls -q) ; do
        if [[ $(docker service ps -f "node=$NODEID" --format "{{.CurrentState}}" "$SERVICENAME" 2>/dev/null | grep -cw 'Running') > 0 ]] ; then
        NODENAME=$(docker node ls --format {{.Hostname}} -f id=$NODEID)
        CONTAINERIDCOMMAND="docker ps -q -f status=running --filter name=$SERVICENAME 2>/dev/null"
        CONTAINERID=$(ssh "$NODENAME" "$CONTAINERIDCOMMAND")
        CONTAINERFOUND=true
        if $ALL ; then
          echo "${NODENAME}:${CONTAINERID}"
    else
      RETURN="${NODENAME}:${CONTAINERID}"
        fi
    fi
done

# --------------------------------------------------------------------------------------
# OUTPUT

if $CONTAINERFOUND ; then
  if ! $ALL ; then
    echo $RETURN
  fi
    exit 0
else
    echo "no container with running $SERVICENAME found in this swarm."
    exit 1
fi