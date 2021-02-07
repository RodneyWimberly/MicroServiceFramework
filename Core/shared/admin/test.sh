for SERVICE in $(docker-node-ps.sh -a core_consul); do
  NODE=${SERVICE%%:*}
  CONTAINER=${SERVICE#*:}
  echo "Node: $NODE"
  echo "Container: $CONTAINER"
done
