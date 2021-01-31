#!/bin/bash

docker stack ps -q -f name="$1" core | xargs docker rm -f
docker stack deploy core --compose-file=./docker-compose.yml
