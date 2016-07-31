#!/bin/bash

echo "Deploying Vote app example ..."

if [ -z "$1" ]; then 
  export VOTE_TAG=good
else 
  export VOTE_TAG=$1
fi;

docker-compose -f docker-compose-voteapp.yml up -d
