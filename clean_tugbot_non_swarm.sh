#!/bin/bash

set -x

docker stop es
docker rm es

docker stop tugbot-run
docker rm tugbot-run

docker stop tugbot-result-service-es
docker rm tugbot-result-service-es

docker stop tugbot-collect
docker rm tugbot-collect



