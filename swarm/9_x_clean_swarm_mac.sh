#!/bin/bash

# vars
[ -z "$NUM_WORKERS" ] && NUM_WORKERS=3

# remove nodes
# run NUM_WORKERS workers with SWARM_TOKEN
for i in $(seq "${NUM_WORKERS}"); do
  docker --host localhost:${i}2375 swarm leave > /dev/null 2>&1
  docker rm --force worker-${i} > /dev/null 2>&1
done

# remove swarm cluster master
docker swarm leave --force > /dev/null 2>&1

# remove swarm visuzalizer
docker rm --force swarm_visualizer > /dev/null 2>&1
