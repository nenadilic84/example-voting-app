#!/bin/bash

echo "Running Functional and Integration Tests ..."

source ./set_network.sh

docker-compose -f docker-compose-tests.yml up -d
