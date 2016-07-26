#!/bin/bash
docker service rm es
docker service rm tugbot-run
docker service rm tugbot-collect
docker service rm tugbot-result-service-es
docker service rm tugbot-result-service
