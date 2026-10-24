#!/bin/sh
docker rm -fv agent 

docker rm -fv gateway

docker rm -f seeder

docker rm -fv db

docker network rm assignment-net

docker rmi agent-image

docker rmi seeder-image