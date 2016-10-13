#!/bin/bash

echo "Deploy example voting application."
echo "Overwrite DEMO_TAG, DEMO_REP, DEMO_NET and DEMO_DB_VOL to customize demo environment."

[ -z "$VOTE_TAG_GOOD" ] && VOTE_TAG_GOOD="good"
[ -z "$DEMO_TAG" ] && DEMO_TAG="latest"
[ -z "$DEMO_REP" ] && DEMO_REP="gaiadocker"
[ -z "$DEMO_NET" ] && DEMO_NET="voteapp"
[ -z "$DEMO_DB_VOL" ] && DEMO_DB_VOL="db-data"


# create network, if not exists
docker network ls --filter "name=${DEMO_NET}" | grep -w "${DEMO_NET}"
if [ $? -ne 0 ]; then
  docker network create --driver overlay --subnet 10.20.0.1/24 ${DEMO_NET}
fi

# create database volumes
docker volume ls --filter "name=${DEMO_DB_VOL}" | grep -w "${DEMO_DB_VOL}"
if [ $? -ne 0 ]; then
  docker volume create --name ${DEMO_DB_VOL}
fi

# create postgresql service
docker service ls --filter "name=db" | grep -w "db"
if [ $? -ne 0 ]; then
  docker service create --name db --network ${DEMO_NET} --mount type=volume,source=${DEMO_DB_VOL},target=/var/lib/postgresql/data postgres:9.4
fi

# create redis service
docker service ls --filter "name=redis" | grep -w "redis"
if [ $? -ne 0 ]; then
  docker service create --name redis --network ${DEMO_NET} redis:3.2-alpine
fi

# create voting-app
docker service ls --filter "name=voting-app" | grep -w "voting-app"
if [ $? -ne 0 ]; then
  docker service create --name voting-app --network ${DEMO_NET} --publish 5000:80 ${DEMO_REP}/example-voting-app-vote:${VOTE_TAG_GOOD}
fi

# create result-app
docker service ls --filter "name=result-app" | grep -w "result-app"
if [ $? -ne 0 ]; then
  docker service create --name result-app --network ${DEMO_NET} --publish 5001:80 ${DEMO_REP}/example-voting-app-result:${DEMO_TAG}
fi

# create worker-app
docker service ls --filter "name=worker" | grep -w "worker"
if [ $? -ne 0 ]; then
  docker service create --name worker --network ${DEMO_NET} ${DEMO_REP}/example-voting-app-worker:${DEMO_TAG}
fi
