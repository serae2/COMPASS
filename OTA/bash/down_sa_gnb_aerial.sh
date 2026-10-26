#!/usr/bin/env bash
set -euo pipefail

COMPOSE_DIR="/home/serae/COMPASS/OTA/openairinterface5g/ci-scripts/yaml_files/sa_gnb_aerial"

cd "${COMPOSE_DIR}"

echo "[RUNTIME] docker compose down in ${COMPOSE_DIR}"
docker compose down