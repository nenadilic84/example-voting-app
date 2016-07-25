#!/bin/sh

# create tugbot service
docker service ls --filter "name=tugbot-run" | grep "tugbot-run"
if [ $? -ne 0 ]; then
  docker service create --name tugbot-run --network voteapp --mount type=bind,source=/var/run/docker.sock,target=/var/run/docker.sock gaiadocker/tugbot:latest
fi

# create tugbot collect
docker service ls --filter "name=tugbot-collect" | grep "tugbot-collect"
if [ $? -ne 0 ]; then
  docker service create --name tugbot-collect --network voteapp --mount type=bind,source=/var/run/docker.sock,target=/var/run/docker.sock gaiadocker/tugbot-collect:latest
fi

# create tugbot result-service
docker service ls --filter "name=tugbot-result-service" | grep "tugbot-result-service"
if [ $? -ne 0 ]; then
  docker service create --name tugbot-result-service --network voteapp --publish 8080:8080 gaiadocker/tugbot-result-service:latest
fi
