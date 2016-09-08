#!/bin/bash

echo "Running Pumba Network Emulation ..."

docker run -it --rm -v /var/run/docker.sock:/var/run/docker.sock gaiaadm/pumba:master pumba --debug netem --duration 5m \
  delay --time 3000 "re2:(.+)result-app"
