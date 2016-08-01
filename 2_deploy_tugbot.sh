#!/bin/bash

echo "Deploying Tugbot Testing Framework ..."

docker-compose -f docker-compose-tugbot.yml up -d
