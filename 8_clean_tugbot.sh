#!/bin/bash

# remove pumba
docker-compose -f docker-compose-pumba.yml kill
docker-compose -f docker-compose-pumba.yml rm -f
# remove tests
docker-compose -f docker-compose-tests.yml kill
docker-compose -f docker-compose-tests.yml rm -f
# remove tugbot
docker-compose -f docker-compose-tugbot.yml kill
docker-compose -f docker-compose-tugbot.yml rm -f
