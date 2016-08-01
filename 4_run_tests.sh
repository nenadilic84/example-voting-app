#!/bin/bash

echo "Running Functional and Integration Tests ..."

docker-compose -f docker-compose-tests.yml up -d
