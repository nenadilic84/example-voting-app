#!/bin/bash

[ -z "$DEMO_REP" ] && DEMO_REP="gaiadocker"
[ -z "$VOTE_TAG_GOOD" ] && VOTE_TAG_GOOD="good"
[ -z "$VOTE_TAG_BAD" ] && VOTE_TAG_BAD="bad"

if [ -z "$1" ]; then
  END=10
else
  END=$1
fi

if [ -z "$2" ]; then
  SLEEP=15
else
  SLEEP=$2
fi

for i in $(seq 1 ${END}); do
  echo "***** ITERATION ${i}/${END} ******"
  echo " > Deploy BUG "
  docker service update --image ${DEMO_REP}/example-voting-app-vote:${VOTE_TAG_BAD} voting-app
  sleep "${SLEEP}"
  echo " > Fix BUG "
  docker service update --image ${DEMO_REP}/example-voting-app-vote:${VOTE_TAG_GOOD} voting-app
  sleep "${SLEEP}"
  echo " "
done
