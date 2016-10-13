#!/bin/sh

echo "Deploy Tugbot services ..."

# create tugbot service (global)
docker service ls --filter "name=tugbot-run" | grep "tugbot-run"
if [ $? -ne 0 ]; then
  docker service create --name tugbot-run \
    --network voteapp \
    --mode global \
    --mount type=bind,source=/var/run/docker.sock,target=/var/run/docker.sock \
    gaiadocker/tugbot:latest
fi

# create tugbot leader service (on each Swarm master)
docker service ls --filter "name=tugbot-leader" | grep "tugbot-leader"
if [ $? -ne 0 ]; then
  docker service create --constraint "node.role == manager" --name tugbot-leader \
    --env "TUGBOT_LEADER_INTERVAL=10s"\
    --network voteapp \
    --mount type=bind,source=/var/run/docker.sock,target=/var/run/docker.sock \
    gaiadocker/tugbot-leader:latest
fi

# create tugbot collect (global)
docker service ls --filter "name=tugbot-collect" | grep "tugbot-collect"
if [ $? -ne 0 ]; then
  docker service create --name tugbot-collect \
    --network voteapp \
    --mode global \
    --mount type=bind,source=/var/run/docker.sock,target=/var/run/docker.sock \
    gaiadocker/tugbot-collect:latest tugbot-collect -g null -c http://tugbot-result-service-es:8081/results
fi

# create tugbot result-service-es
docker service ls --filter "name=tugbot-result-service-es" | grep "tugbot-result-service-es"
if [ $? -ne 0 ]; then
  docker service create --name tugbot-result-service-es --network voteapp --publish 8081:8081 gaiadocker/tugbot-result-service-es:latest ./tugbot-result-service-es -e http://es:9200
fi

# create es service
docker service ls --filter "name=es" | grep "es"
if [ $? -ne 0 ]; then
  docker service create --name es --network voteapp --publish 9200:9200 --publish 9300:9300 elasticsearch:2.3.4
fi

# create kibana service
docker service ls --filter "name=kibana" | grep "kinaba"
if [ $? -ne 0 ]; then
  docker service create --name kibana --network voteapp --env ELASTICSEARCH_URL="http://es:9200" --publish 5601:5601 kibana:4.5.1
fi
