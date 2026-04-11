#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

DB_NAME="${DB_NAME:-thanh_toan}"
MYSQL_SERVICE="${MYSQL_SERVICE:-mysql}"
MYSQL_CONTAINER="${MYSQL_CONTAINER:-web-rating-mysql}"
MYSQL_ROOT_PASSWORD="${MYSQL_ROOT_PASSWORD:-root123}"
INIT_SQL="${INIT_SQL:-$REPO_ROOT/docker/mysql/init/01-init.sql}"
MAX_ATTEMPTS="${MAX_ATTEMPTS:-60}"
SLEEP_SECONDS="${SLEEP_SECONDS:-2}"

if ! command -v docker >/dev/null 2>&1; then
  printf 'Docker is required but was not found in PATH.\n' >&2
  exit 1
fi

if docker compose version >/dev/null 2>&1; then
  COMPOSE_CMD=(docker compose)
elif command -v docker-compose >/dev/null 2>&1; then
  COMPOSE_CMD=(docker-compose)
else
  printf 'Docker Compose is required but was not found.\n' >&2
  exit 1
fi

if [ ! -f "$INIT_SQL" ]; then
  printf 'Init SQL file not found: %s\n' "$INIT_SQL" >&2
  exit 1
fi

printf 'Starting MySQL service if needed...\n'
"${COMPOSE_CMD[@]}" -f "$REPO_ROOT/docker-compose.yml" up -d "$MYSQL_SERVICE"

printf 'Waiting for MySQL to accept connections'
attempt=1
while [ "$attempt" -le "$MAX_ATTEMPTS" ]; do
  if docker exec "$MYSQL_CONTAINER" sh -lc "MYSQL_PWD='$MYSQL_ROOT_PASSWORD' mysqladmin ping -h localhost -uroot --silent" >/dev/null 2>&1; then
    printf '\n'
    break
  fi

  printf '.'
  sleep "$SLEEP_SECONDS"
  attempt=$((attempt + 1))
done

if [ "$attempt" -gt "$MAX_ATTEMPTS" ]; then
  printf '\nMySQL did not become ready in time.\n' >&2
  exit 1
fi

printf 'Ensuring database %s exists...\n' "$DB_NAME"
docker exec "$MYSQL_CONTAINER" sh -lc "MYSQL_PWD='$MYSQL_ROOT_PASSWORD' mysql -h localhost -uroot -e \"CREATE DATABASE IF NOT EXISTS \\\`$DB_NAME\\\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;\""

printf 'Applying %s...\n' "$INIT_SQL"
docker exec -i "$MYSQL_CONTAINER" sh -lc "MYSQL_PWD='$MYSQL_ROOT_PASSWORD' mysql -h localhost -uroot" < "$INIT_SQL"

printf 'Database bootstrap complete.\n'
