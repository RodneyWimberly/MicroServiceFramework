#!/bin/bash
# DESCRIPTION
# Starts the core docker stack

clear
set +e

source ./Scripts/common.sh


echo -e "${LT_BLUE} Building dns image for core stack"
docker build -t ${DOCKER_REGISTRY}dns:${DOCKERFILE_VERSION} Dns/.

echo -e "Building hello image for core stack"
docker build -t ${DOCKER_REGISTRY}hello:${DOCKERFILE_VERSION} Hello/.

echo -e "Building portal image for core stack"
docker build -t ${DOCKER_REGISTRY}portal:${DOCKERFILE_VERSION} Portal/.

echo -e "Building registry image for core stack"
docker build -t ${DOCKER_REGISTRY}registry:${DOCKERFILE_VERSION} Registry/.

echo -e "Building world image for core stack ${NC}"
docker build -t ${DOCKER_REGISTRY}world:${DOCKERFILE_VERSION} World/.


echo -e "${LT_CYAN} Logging in to repository ${DOCKER_REGISTRY}"
docker login https://docker.pkg.github.com --username=RodneyWimberly --password=5a45a7688ea36d4572100a47f894435fef6b2aa5

set -e
echo -e "Deploying image dns for core stack"
docker push ${DOCKER_REGISTRY}dns:${DOCKERFILE_VERSION}

echo -e "Deploying image hello for core stack"
docker push ${DOCKER_REGISTRY}hello:${DOCKERFILE_VERSION}

echo -e "Deploying image portal for core stack"
docker push ${DOCKER_REGISTRY}portal:${DOCKERFILE_VERSION}

echo -e "Deploying image registry for core stack"
docker push ${DOCKER_REGISTRY}registry:${DOCKERFILE_VERSION}

echo -e "Deploying image world for core stack ${NC}"
docker push ${DOCKER_REGISTRY}world:${DOCKERFILE_VERSION}

echo -e "Deploying image diag-tools to ${DOCKER_REGISTRY}"
docker push ${DOCKER_REGISTRY}diag-tools:${DOCKERFILE_VERSION}
