#!/bin/bash

echo "Deploying Tugbot Testing Framework ..."

source ./set_network.sh

docker-compose -f docker-compose-tugbot.yml up -d
