#!/bin/bash

# remove all services
docker service rm $(docker service ls -q)

# remove network
docker network rm voteapp

#remove volume; wait some time before remove
docker volume rm db-data
while [ $? -ne 0 ]; do
  sleep 2
  docker volume rm db-data
done

# remove swarm cluster
docker swarm leave --force
