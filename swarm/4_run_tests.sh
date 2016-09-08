#!/bin/bash

echo "Running Functional and Integration Tests ..."

[ -z "$DEMO_TAG" ] && DEMO_TAG="latest"
[ -z "$DEMO_REP" ] && DEMO_REP="gaiadocker"
[ -z "$DEMO_NET" ] && DEMO_NET="voteapp"
[ -z "$DEMO_DB_VOL" ] && DEMO_DB_VOL="db-data"

docker service create --name votests \
        --network ${DEMO_NET} \
        --env appHost=voting-app:80 \
        --env dbHost=db \
        --label tugbot.swarm.event=update \
        --restart-condition none \
        ${DEMO_REP}/example-voting-app-tests:${DEMO_TAG}
