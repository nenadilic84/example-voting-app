#!/bin/bash

[ -z "$DEMO_TAG" ] && DEMO_TAG="latest"
[ -z "$DEMO_REP" ] && DEMO_REP="gaiadocker"

docker-compose -f docker-compose-build.yml build
