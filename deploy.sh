#!/bin/bash

# init swarm (need for service command)
docker swarm init

# create network
docker network create --driver overlay --subnet 10.20.0.1/24 voteapp

# create database volumes
docker volume create --name db-data

# create postgresql service
docker service create --name db --network voteapp --mount type=volume,source=db-data,target=/var/lib/postgresql/data postgres:9.4

# create redis service
docker service create --name redis --network voteapp redis:3.2-alpine

# create voting-app
docker service create --name voting-app --network voteapp --publish 5000:80 gaiaadm/example-voting-app-vote

# create result-app
docker service create --name result-app --network voteapp --publish 5001:80 gaiaadm/example-voting-app-result

# create worker-app
docker service create --name worker --network voteapp gaiaadm/example-voting-app-worker
