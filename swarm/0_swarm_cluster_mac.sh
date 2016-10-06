#!/bin/bash

# vars
NUM_WORKERS=3
[ -z "$NUM_WORKERS" ] && NUM_WORKERS=3

# init Swarm master
docker swarm init

# get join token
SWARM_TOKEN=$(docker swarm join-token -q worker)

# get Swarm master IP (Docker for Mac xhyve VM IP)
SWARM_MASTER=$(docker info | grep -w 'Node Address' | awk '{print $3}')

# run NUM_WORKERS workers with SWARM_TOKEN
for i in $(seq "${NUM_WORKERS}"); do
  docker run -d --privileged --name worker-${i} --hostname=worker-${i} -p ${i}2375:2375 docker:1.12.1-dind
  docker --host=localhost:${i}2375 swarm join --token ${SWARM_TOKEN} ${SWARM_MASTER}:2377
done

# show swarm cluster
echo "Local Swarm Cluster"
echo "==================="

docker node ls
