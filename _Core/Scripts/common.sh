#!/bin/bash
BLACK='\033[0;30m' RED='\033[0;31m' GREEN='\033[0;32m' ORANGE='\033[0;33m'
BLUE='\033[0;34m' PURPLE='\033[0;35m' CYAN='\033[0;36m' LT_GRAY='\033[0;37m'
DK_GRAY='\033[1;30m' LT_RED='\033[1;31m' LT_GREEN='\033[1;32m'
YELLOW='\033[1;33m' LT_BLUE='\033[1;34m' LT_PURPLE='\033[1;35m'
LT_CYAN='\033[1;36m' WHITE='\033[1;37m' NC='\033[0m'
DOCKERFILE_VERSION=1.0
DOCKER_REGISTRY="docker.pkg.github.com/rodneywimberly/dockerrepositories/"

assign_config() {
    echo -e "${LT_GREEN} Assigning config ${GREEN} ${1} ${NC}"
    docker service update --secret-add source="$1", target="$2" "$3" 2> /dev/null | true
}

unassign_config() {
    echo -e "${LT_GREEN} Un-assigning config ${GREEN} ${1} ${NC}"
    docker service update --secret-rm "$1" "$2" 2> /dev/null | true
    docker service update --secret-rm "$1"-dummy "$2" 2> /dev/null | true
}

assign_dummy_config() {
    echo -e "${LT_GREEN} Assigning config ${GREEN} ${1}-dummy ${NC}"
    docker service update --secret-rm "$1" --secret-add source="$1"-dummy, target="$2" "$3" 2> /dev/null | true
}

assign_real_config() {
    echo -e "${LT_GREEN} Assigning config ${GREEN} ${1} ${NC}"
    docker service update --secret-rm "$1"-dummy --secret-add source="$1", target="$2" "$3" 2> /dev/null | true
}

add_secret() {
    echo -e "${LT_GREEN} Adding secret ${GREEN} ${1} ${NC}"
    docker secret rm "$1" 2> /dev/null | true
    docker secret rm "$1"-dummy 2> /dev/null | true
    docker secret create "$1" "$2" 2> /dev/null | true
    docker secret create "$1"-dummy "$2" 2> /dev/null | true
}

add_config() {
    CONFIG_NAME=$1
    CONTAINER_NAME=$2
    echo -e "${LT_GREEN} Adding config${GREEN} ${CONFIG_NAME} ${NC}"
    docker config rm "$CONFIG_NAME" 2> /dev/null | true
    docker config rm "$CONFIG_NAME"-dummy 2> /dev/null | true
    docker config create "${CONFIG_NAME}" "${CONTAINER_NAME}" 2> /dev/null
    docker config create "${CONFIG_NAME}"-dummy "${CONTAINER_NAME}" 2> /dev/null
}
