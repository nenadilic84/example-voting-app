#!/bin/bash

set -x

docker run -d --name es -p 9200:9200 -p 9300:9300 elasticsearch:2.1
docker run -d --name tugbot-run -v /var/run/docker.sock:/var/run/docker.sock gaiadocker/tugbot:latest
docker run -d --name tugbot-result-service-es --link es:es -p 8081:8081 gaiadocker/tugbot-result-service-es:latest ./tugbot-result-service-es -e http://es:9200
docker run -d --name tugbot-collect --link tugbot-result-service-es:tugbot-result-service-es -v /var/run/docker.sock:/var/run/docker.sock gaiadocker/tugbot-collect:latest tugbot-collect -g null -c http://tugbot-result-service-es:8081/results


