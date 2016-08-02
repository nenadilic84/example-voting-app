#!/bin/bash

docker-compose -f docker-compose-voteapp.yml down --remove-orphans 

# cleanup volumes
if ([ $1 ] && [ $1 = "all" ]); then
  docker volume rm $(docker volume ls -q)
else 
  docker volume rm $(docker volume ls -q | grep -v examplevotingapp_es)
fi;

# cleanup network
docker network rm $(docker network ls --filter "name=example" -q)
