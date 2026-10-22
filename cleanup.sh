#!/bin/sh
docker rm -fv db

docker rm -f seeder

docker network rm assignment-net

docker rmi seeder-image

docker rm -fv gateway