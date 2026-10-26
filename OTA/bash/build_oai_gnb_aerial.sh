########################################
# when modified code in OAI
########################################

#!/usr/bin/env bash
set -euo pipefail

OAI_REPO="/home/serae/COMPASS/OTA/openairinterface5g"
DOCKERFILE="${OAI_REPO}/docker/Dockerfile.gNB.aerial.ubuntu"
IMAGE_NAME="oai-gnb-aerial:ATB1.2_serae"

cd "${OAI_REPO}"

echo "[OAI-FULL] Building image ${IMAGE_NAME}"
docker build \
  -f "${DOCKERFILE}" \
  -t "${IMAGE_NAME}" \
  .

echo "[OAI-FULL] Done: ${IMAGE_NAME}"