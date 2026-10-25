#!/bin/sh

set -e

export MSYS_NO_PATHCONV=1

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
  if [ "$elapsed" -ge "$WAIT_TIMEOUT" ]; then
    log "ERROR: Postgres not ready after ${WAIT_TIMEOUT}s."
    exit 1
  fi
  sleep 1
done
log "Postgres is ready."

docker run --rm --name seeder --net assignment-net \
    -v "$(pwd)/Chinook.db:/app/Chinook.db:ro" \
    -e SQLITE_FILE=/app/Chinook.db \
    -e DATABASE_URL=postgres://admin:konrad4564@db:5432/musicdb \
   seeder-image

docker run -d --net assignment-net \
  --name gateway \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v "$(pwd)/mcp_config.yaml:/mcp_config.yaml:ro" \
  -v "$(pwd)/mcp_secret.env:/run/secrets/database-url:ro" \
  docker/mcp-gateway:latest \
  --transport=sse \
  --secrets=/run/secrets/database-url \
  --allow-unauthenticated \
  --servers=cockroachdb \
  --tools=execute_query \
  --config=/mcp_config.yaml 

log "Waiting 45s for gateway to start..."
sleep 45
log "Gateway should be ready"

docker build --target agent -t agent-image .

docker run --rm --name agent --net assignment-net \
  -v "$(pwd)/secret.ollama-api-key:/run/secrets/openai-api-key:ro" \
  -e MCP_SERVER_URL=http://gateway:8811/sse \
  -e DATABASE_DIALECT=PostgreSQL \
  -e QUESTION="What are the top 3 albums by sales?" \
  -e OPENAI_API_BASE_URL=https://ollama.com/v1 \
  -e OPENAI_MODEL_NAME=gpt-oss:20b \
  agent-image