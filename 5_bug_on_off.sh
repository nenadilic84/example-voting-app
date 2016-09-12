#!/bin/bash

if [ -z "$1" ]; then
  END=5
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
  (./1_deploy.sh bad)
  sleep "${SLEEP}"
  echo " > Fix BUG "
  (./1_deploy.sh)
  sleep "${SLEEP}"
  echo " "
done
