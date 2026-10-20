#!/bin/sh
docker rm -fv db
docker network rm assignment-net
docker rmi seeder-image