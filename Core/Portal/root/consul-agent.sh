#!/usr/bin/dumb-init /bin/sh
set -ex
consul_host=consul
consul_prefix=/consul
bin_path=/bin

add_consul_service() {
  (
    if [ -f "$1" ]; then
      app_name="$(jq -r '.service.name' < "$1")"
    else
      app_name="$(echo "$1" | jq -r '.service.name')"
    fi
    service_file="$consul_prefix"/config/"$app_name".json
    [ -f "$service_file" ] || (
      if [ -f "$1" ]; then
        cp "$1" "$service_file"
      else
        echo "$1" > "$service_file"
      fi
    )
  )
}

run_consul_template() {
  # $1 is the source file
  # $2 is the template file name
  # $3 is the destination
  # $4 is the reload command and may not exist
  mkdir -p "$consul_prefix"/template
  cp "$1" "$consul_prefix"/template/"$2"
  if [ -z "$4" ]; then
    /bin/sh -c "sleep 30;nohup consul-template -template=$consul_prefix/template/$2:$3 -retry 30s -consul-retry -wait 30s -consul-retry-max-backoff=15s &"
  else
    /bin/sh -c "nohup consul-template -template=$consul_prefix/template/$2:$3:'$4' -retry 30s -consul-retry -wait 30s -consul-retry-max-backoff=15s &"
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

# CONSUL_DATA_DIR is exposed as a volume for possible persistent storage. The
# CONSUL_CONFIG_DIR isn't exposed as a volume but you can compose additional
# config files in there if you use this image as a base, or use CONSUL_LOCAL_CONFIG
# below.
CONSUL_DATA_DIR=/consul/data
CONSUL_CONFIG_DIR=/consul/config

# You can also set the CONSUL_LOCAL_CONFIG environemnt variable to pass some
# Consul configuration JSON without having to bind any volumes.
if [ -n "$CONSUL_LOCAL_CONFIG" ]; then
    echo "$CONSUL_LOCAL_CONFIG" > "$CONSUL_CONFIG_DIR/local.json"
fi


PATH="${bin_path}:${PATH}"
export PATH bin_path
export IP=$$(ip -o ro get $$(ip ro | awk '$$1 == "default" { print $$3 }') | awk '{print $$5}')
export is_root_user consul_prefix
export datacenter=docker

while [ "$#" -gt 0 ];do
  case "$1" in
    --advertise)
      shift
      advertise_address="$1"
      shift
      ;;
    --consul-host)
      shift
      consul_host="$1"
      shift
      ;;
    --no-consul)
      shift
      no_consul=true
      ;;
    --service)
      shift
      add_consul_service "$1"
      shift
      ;;
    --consul-template-file)
      shift
      run_consul_template "$1" "$2" "$3"
      shift
      shift
      shift
      ;;
    --consul-template-file-cmd)
      shift
      run_consul_template "$1" "$2" "$3" "$4"
      shift
      shift
      shift
      shift
      ;;
    --datacenter)
      shift
      datacenter="$1"
      shift
      ;;
    *)
      set +x
      echo 'USAGE:'
      echo '  consul-agent.sh [options]'
      echo 'OPTIONS:'
      echo '  --consul-host'
      echo '    the remote consul hostname to connect the agent'
      echo
      echo '  --no-consul'
      echo '    skips running consul'
      echo '    useful to troubleshoot consul-template'
      echo
      echo '  --service "{consul service json}"'
      echo '    install consul service where arg is json string'
      echo
      echo '  --service "file.json"'
      echo '    install consul service where arg is json file'
      echo
      echo '  --consul-template-file "{service lock}" "{consul template}"'
      echo '    install template for consul-template as with'
      echo
      echo '  --consul-template-file "{source file}" "{template name}" "{destination file}"'
      echo '    install template for consul-template'
      echo
      echo '  --consul-template-file-cmd "{source file}" "{template name}" "{destination file}" "{reload command}"'
      echo '    install template for consul-template'
      echo '    also runs a command when template is written'
      echo
      echo '  --datacenter "{datacenter}"'
      echo '    customize the datacenter; default to docker'
      exit 1
  esac
done

if [ "$no_consul" = true ]; then
  exit
fi

additional_opts=""
if [ -n "$advertise_address" ]; then
additional_opts="$additional_opts -advertise=$advertise_address"
fi

# start consul agent
su -s /bin/sh -c "nohup consul agent -config-dir=$consul_prefix/config -data-dir=$consul_prefix/data $CONSUL_BIND $CONSUL_CLIENT $additional_opts &" - registry-leader
