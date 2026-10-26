#!/usr/bin/env bash
set -euo pipefail

COMPOSE_DIR="/home/serae/COMPASS/OTA/openairinterface5g/ci-scripts/yaml_files/sa_gnb_aerial"

cd "${COMPOSE_DIR}"

echo "[RUNTIME] docker compose up in ${COMPOSE_DIR}"
docker compose up
#docker compose -f docker-compose.yaml -f docker-compose-dev.yaml up