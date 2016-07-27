#!/bin/sh

# create tugbot service
docker service ls --filter "name=tugbot-run" | grep "tugbot-run"
if [ $? -ne 0 ]; then
  docker service create --name tugbot-run --network voteapp --mount type=bind,source=/var/run/docker.sock,target=/var/run/docker.sock gaiadocker/tugbot:latest
fi

# create tugbot collect
docker service ls --filter "name=tugbot-collect" | grep "tugbot-collect"
if [ $? -ne 0 ]; then
  docker service create --name tugbot-collect --network voteapp --mount type=bind,source=/var/run/docker.sock,target=/var/run/docker.sock gaiadocker/tugbot-collect:latest tugbot-collect -g null -c http://tugbot-result-service-es:8081/results
fi

# create tugbot result-service
#docker service ls --filter "name=tugbot-result-service" | grep "tugbot-result-service"
#if [ $? -ne 0 ]; then
#  docker service create --name tugbot-result-service --network voteapp --publish 8080:8080 gaiadocker/tugbot-result-service:latest
#fi

# create tugbot result-service-es
docker service ls --filter "name=tugbot-result-service-es" | grep "tugbot-result-service-es"
if [ $? -ne 0 ]; then
  docker service create --name tugbot-result-service-es --network voteapp --publish 8081:8081 gaiadocker/tugbot-result-service-es:latest ./tugbot-result-service-es -e http://es:9200
fi

# create es service
docker service ls --filter "name=es" | grep "es"
if [ $? -ne 0 ]; then
  docker service create --name es --network voteapp --publish 9200:9200 --publish 9300:9300 elasticsearch:latest
fi


