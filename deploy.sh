#!/bin/bash

# init swarm (need for service command); if not created
docker node ls | grep "moby"
if [ $? -ne 0 ]; then
  docker swarm init
fi

# create network, if not exists
docker network ls --filter "name=voteapp" | grep "voteapp"
if [ $? -ne 0 ]; then
  docker network create --driver overlay --subnet 10.20.0.1/24 voteapp
fi

# create database volumes
docker volume ls --filter "name=db-data" | grep "db-data"
if [ $? -ne 0 ]; then
  docker volume create --name db-data
fi

# create postgresql service
docker service ls --filter "name=db" | grep "db"
if [ $? -ne 0 ]; then
  docker service create --name db --network voteapp --mount type=volume,source=db-data,target=/var/lib/postgresql/data postgres:9.4
fi

# create redis service
docker service ls --filter "name=redis" | grep "redis"
if [ $? -ne 0 ]; then
  docker service create --name redis --network voteapp redis:3.2-alpine
fi

# create voting-app
docker service ls --filter "name=voting-app" | grep "voting-app"
if [ $? -ne 0 ]; then
  docker service create --name voting-app --network voteapp --publish 5000:80 gaiaadm/example-voting-app-vote
fi

# create result-app
docker service ls --filter "name=result-app" | grep "result-app"
if [ $? -ne 0 ]; then
  docker service create --name result-app --network voteapp --publish 5001:80 gaiaadm/example-voting-app-result
fi

# create worker-app
docker service ls --filter "name=worker" | grep "worker"
if [ $? -ne 0 ]; then
  docker service create --name worker --network voteapp gaiaadm/example-voting-app-worker
fi
