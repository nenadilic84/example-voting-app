#!/bin/bash

# remove all services
docker service rm $(docker service ls -q)

# remove network
docker network rm voteapp

#remove volume; wait some time before remove
sleep 5
docker volume rm db-data

# remove swarm cluster
docker swarm leave --force
