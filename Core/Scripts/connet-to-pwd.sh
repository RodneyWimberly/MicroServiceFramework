#!/bin/bash
clear
echo "Deploying core stack to swarm"


if [ $PWD_URL == "" ]; then
    echo "PWD_URL should not be blank to connect to Play With Docker"
else
    echo "Connecting to Play With Docker instance ${PWD_URL}"
    docker-machine create -d pwd pwd-node1
    eval $(docker-machine env pwd-node1)
    
fi

