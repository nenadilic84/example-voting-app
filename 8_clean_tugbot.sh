#!/bin/bash

# remove pumba
docker-compose -f docker-compose-pumba.yml down -v

# remove tests
docker-compose -f docker-compose-tests.yml down -v

# remove tugbot
if ([ $1 ] && [ $1 = "all" ]); then 
  rv="-v"
fi;
docker-compose -f docker-compose-tugbot.yml down $rv
