#!/bin/bash

echo "Deploying Vote app example ..."

docker-compose -f docker-compose-voteapp.yml up -d
