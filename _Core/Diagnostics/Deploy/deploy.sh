#!/bin/bash

set -e
echo "Deploying Diagnostics Stack to Swarm"
docker stack deploy --compose-file=./diagnostics-stack.yml diagnostics
