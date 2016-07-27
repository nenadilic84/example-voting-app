#!/bin/bash

echo "Demo setup. Overwrite DEMO_TAG, DEMO_REP, DEMO_NET and DEMO_DB_VOL to customize demo environment."

[ -z "$DEMO_TAG" ] && DEMO_TAG="latest"
[ -z "$DEMO_REP" ] && DEMO_REP="gaiadocker"
[ -z "$DEMO_NET" ] && DEMO_NET="voteapp"
[ -z "$DEMO_DB_VOL" ] && DEMO_DB_VOL="db-data"

# init swarm (need for service command); if not created
docker node ls 2> /dev/null | grep "Leader"
if [ $? -ne 0 ]; then
  docker swarm init
fi

# create network, if not exists
docker network ls --filter "name=${DEMO_NET}" | grep "${DEMO_NET}"
if [ $? -ne 0 ]; then
  docker network create --driver overlay --subnet 10.20.0.1/24 ${DEMO_NET}
fi

# create database volumes
docker volume ls --filter "name=db-data" | grep "db-data"
if [ $? -ne 0 ]; then
  docker volume create --name ${DEMO_DB_VOL}
fi

# create postgresql service
docker service ls --filter "name=db" | grep "db"
if [ $? -ne 0 ]; then
  docker service create --name db --network ${DEMO_NET} --mount type=volume,source=${DEMO_DB_VOL},target=/var/lib/postgresql/data postgres:9.4
fi

# create redis service
docker service ls --filter "name=redis" | grep "redis"
if [ $? -ne 0 ]; then
  docker service create --name redis --network ${DEMO_NET} redis:3.2-alpine
fi

# create voting-app
docker service ls --filter "name=voting-app" | grep "voting-app"
if [ $? -ne 0 ]; then
  docker service create --name voting-app --network ${DEMO_NET} --publish 5000:80 ${DEMO_REP}/example-voting-app-vote:${DEMO_TAG}
fi

# create result-app
docker service ls --filter "name=result-app" | grep "result-app"
if [ $? -ne 0 ]; then
  docker service create --name result-app --network ${DEMO_NET} --publish 5001:80 ${DEMO_REP}/example-voting-app-result:${DEMO_TAG}
fi

# create worker-app
docker service ls --filter "name=worker" | grep "worker"
if [ $? -ne 0 ]; then
  docker service create --name worker --network ${DEMO_NET} ${DEMO_REP}/example-voting-app-worker:${DEMO_TAG}
fi
