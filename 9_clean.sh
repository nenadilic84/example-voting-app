#!/bin/bash

docker-compose -f docker-compose-voteapp.yml kill
docker-compose -f docker-compose-voteapp.yml rm -f -v

# cleanup volumes
docker volume rm $(docker volume ls -q)

# cleanup network
docker network rm $(docker network ls --filter "name=example" -q)
