#!/bin/bash

set -e
echo "Deploying DevOps Stack to Swarm"
docker stack deploy --compose-file=./devops-stack.yml devops
