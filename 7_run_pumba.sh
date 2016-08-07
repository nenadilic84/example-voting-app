#!/bin/bash

echo "Running Pumba Network Emulation ..."

# shellcheck disable=SC1091
source ./set_network.sh

exec docker-compose -f docker-compose-pumba.yml up 
