#!/bin/bash
# DESCRIPTION
# Starts the core docker stack

clear
set +e

source ./Scripts/common.sh

echo -e "${LT_BLUE} Building diag-tools image for diag stack"
docker build -t ${DOCKER_REGISTRY}diag-tools:${DOCKERFILE_VERSION} Diagnostics/.

echo -e "${LT_CYAN} Logging in to repository ${DOCKER_REGISTRY}"
docker login https://docker.pkg.github.com --username=RodneyWimberly --password=5a45a7688ea36d4572100a47f894435fef6b2aa5

echo -e "Deploying image diag-tools to ${DOCKER_REGISTRY}"
docker push ${DOCKER_REGISTRY}diag-tools:${DOCKERFILE_VERSION}
