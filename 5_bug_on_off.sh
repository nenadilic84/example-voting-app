#!/bin/bash

for i in {1..10}; do ./1_deploy.sh bad; sleep 15; ./1_deploy.sh; done
