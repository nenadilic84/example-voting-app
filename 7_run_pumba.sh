#!/bin/bash

echo "Running Pumba Network Emulation ..."

docker run -it --rm -v /var/run/docker.sock:/var/run/docker.sock gaiaadm/pumba:master pumba --debug \
        --interval 1m \
        --random netem \
        --duration 30s \
        delay --amount 3000 re2:^result
