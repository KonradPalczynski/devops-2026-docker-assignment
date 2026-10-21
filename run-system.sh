#!/bin/sh

set -e

docker network create assignment-net

docker run -d  --name db --net assignment-net \
    -e POSTGRES_USER=admin \
    -e POSTGRES_PASSWORD=konrad4564 \
    -e POSTGRES_DB=musicdb   \
   postgres

docker build --target seeder -t seeder-image .

docker run --name seeder --net assignment-net \
    -v "$(pwd)/Chinook.db:/app/Chinook.db" \
    -e SQLITE_FILE=/app/Chinook.db \
    -e DATABASE_URL=postgres://admin:konrad4564@db:5432/musicdb \
   seeder-image