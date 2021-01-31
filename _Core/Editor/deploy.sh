#!/bin/bash
# DESCRIPTION
# Starts the core docker stack

clear
set +e

source ../Scripts/common.sh

echo -e "${LT_BLUE} Building editor image "
docker build -t ${DOCKER_REGISTRY}code-editor:${DOCKERFILE_VERSION} .

echo -e "${LT_CYAN} Logging in to repository ${DOCKER_REGISTRY}"
docker login https://docker.pkg.github.com --username=RodneyWimberly --password=5a45a7688ea36d4572100a47f894435fef6b2aa5

echo -e "Deploying image diag-tools to ${DOCKER_REGISTRY}"
docker push ${DOCKER_REGISTRY}code-editor:${DOCKERFILE_VERSION}


docker run -v /path/to/root:/srv -v /path/filebrowser.db:/database.db -v /path/.filebrowser.json:/.filebrowser.json -p 8081:80 filebrowser/filebrowser

    docker image pull adrientoub/file-explorer:latest
docker run -p 127.0.0.1:8689:3000 -e SECRET_KEY_BASE=RAILS_SECRET -e BASE_DIRECTORY=/ -it adrientoub/file-explorer:latest



docker run -d -p 8080:80 -e BRIDGE=php-local -v $PWD:/var/www/files  elboletaire/angular-filemanager
