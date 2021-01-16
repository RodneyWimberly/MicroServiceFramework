#!/usr/bin/dumb-init /bin/sh
set +e


# CONSUL_DATA_DIR is exposed as a volume for possible persistent storage. The
# CONSUL_CONFIG_DIR isn't exposed as a volume but you can compose additional
# config files in there if you use this image as a base, or use CONSUL_LOCAL_CONFIG
# below.
BIN_DIR=/bin
CONSUL_DIR=/consul
CONSUL_DATA_DIR=$CONSUL_DIR/data
CONSUL_CONFIG_DIR=$CONSUL_DIR/config
CONSUL_TEMPLATE_DIR=$CONSUL_DIR/template

mkdir -p "$CONSUL_DATA_DIR"
mkdir -p "$CONSUL_CONFIG_DIR"
mkdir -p "$CONSUL_TEMPLATE_DIR"

register_service() {
    # $1 is JSON string/file with service registration information
  (
    if [ -f "$1" ]; then
      service_name="$(jq -r '.service.name' < "$1")"
    else
      service_name="$(echo "$1" | jq -r '.service.name')"
    fi
    service_file="$CONSUL_DIR"/config/"$service_name".json
    [ -f "$service_file" ] || (
      if [ -f "$1" ]; then
        cp "$1" "$service_file"
      else
        echo "$1" > "$service_file"
      fi
    )
  )
}

process_template() {
  # $1 is the source file
  # $2 is the template file name
  # $3 is the destination
  # $4 is the reload command and may not exist
  cp "$1" "$CONSUL_TEMPLATE_DIR"/"$2"
  if [ -z "$4" ]; then
    /bin/sh -c "sleep 30;nohup consul-template -template=$CONSUL_TEMPLATE_DIR/$2:$3 -retry 30s -consul-retry -wait 30s -consul-retry-max-backoff=15s &"
  else
    /bin/sh -c "nohup consul-template -template=$CONSUL_TEMPLATE_DIR/$2:$3:'$4' -retry 30s -consul-retry -wait 30s -consul-retry-max-backoff=15s &"
  fi
}

# Note above that we run dumb-init as PID 1 in order to reap zombie processes
# as well as forward signals to all processes in its session. Normally, sh
# wouldn't do either of these functions so we'd leak zombies as well as do
# unclean termination of all our sub-processes.
# As of docker 1.13, using docker run --init achieves the same outcome.

# You can set CONSUL_BIND_INTERFACE to the name of the interface you'd like to
# bind to and this will look up the IP and pass the proper -bind= option along
# to Consul.
CONSUL_BIND=
if [ -n "$CONSUL_BIND_INTERFACE" ]; then
  CONSUL_BIND_ADDRESS=$(ip -o -4 addr list $CONSUL_BIND_INTERFACE | head -n1 | awk '{print $4}' | cut -d/ -f1)
  if [ -z "$CONSUL_BIND_ADDRESS" ]; then
    echo "Could not find IP for interface '$CONSUL_BIND_INTERFACE', exiting"
    exit 1
  fi

  CONSUL_BIND="-bind=$CONSUL_BIND_ADDRESS"
  echo "==> Found address '$CONSUL_BIND_ADDRESS' for interface '$CONSUL_BIND_INTERFACE', setting bind option..."
fi

# You can set CONSUL_CLIENT_INTERFACE to the name of the interface you'd like to
# bind client intefaces (HTTP, DNS, and RPC) to and this will look up the IP and
# pass the proper -client= option along to Consul.
CONSUL_CLIENT=
if [ -n "$CONSUL_CLIENT_INTERFACE" ]; then
  CONSUL_CLIENT_ADDRESS=$(ip -o -4 addr list $CONSUL_CLIENT_INTERFACE | head -n1 | awk '{print $4}' | cut -d/ -f1)
  if [ -z "$CONSUL_CLIENT_ADDRESS" ]; then
    echo "Could not find IP for interface '$CONSUL_CLIENT_INTERFACE', exiting"
    exit 1
  fi

  CONSUL_CLIENT="-client=$CONSUL_CLIENT_ADDRESS"
  echo "==> Found address '$CONSUL_CLIENT_ADDRESS' for interface '$CONSUL_CLIENT_INTERFACE', setting client option..."
fi

# You can set CONSUL_ADVERTISE_INTERFACE to the name of the interface you'd like to
# advertise to and this will look up the IP and pass the proper -advertise= option along
# to Consul.
CONSUL_ADVERTISE=
if [ -n "$CONSUL_ADVERTISE_INTERFACE" ]; then
  CONSUL_ADVERTISE_ADDRESS=$(ip -o -4 addr list $CONSUL_ADVERTISE_INTERFACE | head -n1 | awk '{print $4}' | cut -d/ -f1)
  if [ -z "$CONSUL_ADVERTISE_ADDRESS" ]; then
    echo "Could not find IP for interface '$CONSUL_ADVERTISE_INTERFACE', exiting"
    exit 1
  fi

  CONSUL_ADVERTISE="-advertise=$CONSUL_ADVERTISE_ADDRESS"
  echo "==> Found address '$CONSUL_ADVERTISE_ADDRESS' for interface '$CONSUL_ADVERTISE_INTERFACE', setting advertise option..."
fi

# You can also set the CONSUL_LOCAL_CONFIG environemnt variable to pass some
# Consul configuration JSON without having to bind any volumes.
if [ -n "$CONSUL_LOCAL_CONFIG" ]; then
    echo "$CONSUL_LOCAL_CONFIG" > "$CONSUL_CONFIG_DIR/local.json"
fi

PATH="${BIN_DIR}:${PATH}"
export PATH BIN_DIR
export IP=$(ip -o ro get $(ip ro | awk '$1 == "default" { print $3 }') | awk '{print $5}')

while [ "$#" -gt 0 ];do
  case "$1" in
    --service)
      shift
      register_service "$1"
      shift
      ;;
    --template-file)
      shift
      process_template "$1" "$2" "$3"
      shift
      shift
      shift
      ;;
    --template-file-reload)
      shift
      process_template "$1" "$2" "$3" "$4"
      shift
      shift
      shift
      shift
      ;;
    *)
      set +x
      echo 'USAGE:'
      echo '  registry-agent.sh [options]'
      echo 'OPTIONS:'
      echo '  --service "{registry service json}"'
      echo '    install registry service where arg is json string'
      echo
      echo '  --service "file.json"'
      echo '    install registry service where arg is json file'
      echo
      echo '  --template-file "{service lock}" "{consul template}"'
      echo '    install template for consul-template as with'
      echo
      echo '  --template-file "{source file}" "{template name}" "{destination file}"'
      echo '    install template for consul-template'
      echo
      echo '  --template-file-reload "{source file}" "{template name}" "{destination file}" "{reload command}"'
      echo '    install template for consul-template'
      echo '    also runs a command when template is written'
      exit 1
  esac
done

#consul agent -config-dir="${CONSUL_CONFIG_DIR}" -data-dir="${CONSUL_DATA_DIR} ${CONSUL_BIND} ${CONSUL_CLIENT} ${CONSUL_ADVERTISE}"

su -s /bin/sh -c "nohup consul agent -log-level debug -config-dir=$CONSUL_CONFIG_DIR -data-dir=$CONSUL_DATA_DIR $CONSUL_BIND $CONSUL_CLIENT $CONSUL_ADVERTISE &"
