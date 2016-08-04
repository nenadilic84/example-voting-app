#!/bin/bash

echo "Running Pumba Network Emulation ..."

source ./set_network.sh

docker-compose -f docker-compose-pumba.yml up
