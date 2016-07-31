#!/bin/bash

# remove pumba
docker-compose -f docker-compose-pumba.yml down --remove-orphans -v

# remove tests
docker-compose -f docker-compose-tests.yml down --remove-orphans -v

# remove tugbot
docker-compose -f docker-compose-tugbot.yml down --remove-orphans -v
