#!/bin/sh
docker rm -fv agent 

docker rm -fv gateway

docker rm -fv seeder

docker rm -fv db

docker network rm assignment-net

docker rmi agent-image

docker rmi seeder-image