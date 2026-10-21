#!/bin/sh

set -e

log() {
    echo "[run-system] $*"
}

docker network create assignment-net

docker run -d  --name db --net assignment-net \
    -e POSTGRES_USER=admin \
    -e POSTGRES_PASSWORD=konrad4564 \
    -e POSTGRES_DB=musicdb   \
   postgres

docker build --target seeder -t seeder-image .

WAIT_TIMEOUT="${WAIT_TIMEOUT:-30}"
log "Waiting up to ${WAIT_TIMEOUT}s for Postgres..."

elapsed=0
until docker exec db pg_isready -U admin -d musicdb >/dev/null 2>&1; do
  elapsed=$((elapsed + 1))
  if [ "elapsed" -ge "$WAIT_TIMEOUT"]; then
    log "ERROR: Postgres not ready after ${WAIT_TIMEOUT}s."
    exit 1
  fi
  sleep 1
done
log "Postgres is ready."

docker run --name seeder --net assignment-net \
    -v "$(pwd)/Chinook.db:/app/Chinook.db" \
    -e SQLITE_FILE=/app/Chinook.db \
    -e DATABASE_URL=postgres://admin:konrad4564@db:5432/musicdb \
   seeder-image