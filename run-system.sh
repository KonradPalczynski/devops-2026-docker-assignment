#!/bin/sh

set -e

docker network create assignment-net

docker run -d  --name db --network assignment-net \
    -e POSTGRES_USER=admin \
    -e POSTGRES_PASSWORD=konrad4564 \
    -e POSTGRES_DB=musicdb   \
   postgres

docker build --target seeder -t seeder-image .