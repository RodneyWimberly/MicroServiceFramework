#!/bin/bash
set -ueo pipefail
set +x

docker rm -f portainer
docker volume rm -f portainer_data