########################################
# when modified:
# dockerfile.base.ubuntu
# apt package
# compiler/build tool
# build_oai -I dependency
# UHD/system library
# python package
########################################

#!/usr/bin/env bash
set -euo pipefail

OAI_REPO="/home/serae/COMPASS/OTA/openairinterface5g"
DOCKERFILE="${OAI_REPO}/docker/Dockerfile.base.ubuntu"
IMAGE_NAME="ran-base:ATB1.2_serae"

cd "${OAI_REPO}"

echo "[OAI-BASE] Building ${IMAGE_NAME}"
docker build \
  -f "${DOCKERFILE}" \
  -t "${IMAGE_NAME}" \
  .

echo "[OAI-BASE] Done: ${IMAGE_NAME}"
echo "[OAI-BASE] If OAI gNB image depends on this base, rebuild oai-gnb-aerial next."