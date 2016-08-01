#!/bin/bash

docker-compose -f docker-compose-voteapp.yml down --remove-orphans -v

# cleanup volumes
docker volume rm $(docker volume ls -q)

# cleanup network
docker network rm $(docker network ls --filter "name=example" -q)
