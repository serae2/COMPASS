#!/usr/bin/env bash
set -euo pipefail

########################################
# Dev incremental build for OAI gNB Aerial
#
# Use when modified OAI source code.
# This does NOT rebuild the oai-gnb-aerial Docker image.
# It builds nr-softmodem incrementally inside a persistent build container.
########################################

OAI_REPO="/home/serae/COMPASS/OTA/openairinterface5g"
BUILD_CONTAINER="oai-build-dev"
BASE_IMAGE="ran-base:ATB1.2_serae"

echo "========================================"
echo "[OAI-DEV] OAI repo        : ${OAI_REPO}"
echo "[OAI-DEV] Build container: ${BUILD_CONTAINER}"
echo "[OAI-DEV] Base image     : ${BASE_IMAGE}"
echo "========================================"

if [ ! -d "${OAI_REPO}" ]; then
  echo "[OAI-DEV] ERROR: OAI repo not found: ${OAI_REPO}"
  exit 1
fi

########################################
# 1. Create persistent build container
########################################

if ! docker ps -a --format '{{.Names}}' | grep -qx "${BUILD_CONTAINER}"; then
  echo "[OAI-DEV] Creating persistent build container: ${BUILD_CONTAINER}"

  docker run -dit \
    --name "${BUILD_CONTAINER}" \
    --network host \
    --privileged \
    -v "${OAI_REPO}:/oai-ran" \
    -w /oai-ran \
    "${BASE_IMAGE}" \
    bash
else
  echo "[OAI-DEV] Build container already exists."
fi

########################################
# 2. Start container if stopped
########################################

if ! docker ps --format '{{.Names}}' | grep -qx "${BUILD_CONTAINER}"; then
  echo "[OAI-DEV] Starting ${BUILD_CONTAINER}"
  docker start "${BUILD_CONTAINER}"
fi

########################################
# 3. Build inside container
########################################

echo "[OAI-DEV] Running incremental build inside ${BUILD_CONTAINER}"

docker exec -it "${BUILD_CONTAINER}" bash -lc '
  set -euo pipefail

  cd /oai-ran

  ########################################
  # Install extra dependencies once
  ########################################

  if [ ! -f /root/.oai-dev-deps-installed ]; then
    echo "[OAI-DEV] Installing build dependencies for nvIPC/OAI..."

    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
      wget \
      ninja-build \
      unzip \
      moreutils \
      vim-tiny \
      nano \
      cmake \
      libpcap-dev \
      libcunit1-dev \
      libnuma-dev \
      pkg-config

    touch /root/.oai-dev-deps-installed
  else
    echo "[OAI-DEV] Build dependencies already installed."
  fi

  ########################################
  # Source OAI environment
  ########################################

  echo "[OAI-DEV] Loading OAI environment..."
  /bin/sh oaienv

  ########################################
  # Build/install nvIPC once
  ########################################

  if [ ! -f /usr/local/lib/libnvipc.so ]; then
    echo "[OAI-DEV] libnvipc.so not found. Building nvIPC once..."

    cd /oai-ran

    NVIPC_TARBALL="$(ls nvipc_src.*.tar.gz 2>/dev/null | head -n1 || true)"
    NVIPC_DIR="$(find . -maxdepth 1 -type d -name "nvipc_src.*" | head -n1 || true)"

    if [ -z "${NVIPC_DIR}" ]; then
      if [ -z "${NVIPC_TARBALL}" ]; then
        echo "[OAI-DEV] ERROR: nvipc_src.*.tar.gz not found in /oai-ran"
        exit 1
      fi

      echo "[OAI-DEV] Extracting ${NVIPC_TARBALL}"
      tar -xvzf "${NVIPC_TARBALL}"

      NVIPC_DIR="$(find . -maxdepth 1 -type d -name "nvipc_src.*" | head -n1 || true)"
    fi

    if [ -z "${NVIPC_DIR}" ]; then
      echo "[OAI-DEV] ERROR: nvIPC source directory not found after extraction"
      exit 1
    fi

    echo "[OAI-DEV] nvIPC source dir: ${NVIPC_DIR}"

    cd "${NVIPC_DIR}"
    rm -rf build
    mkdir -p build
    cd build

    cmake .. \
      -DNVIPC_DPDK_ENABLE=OFF \
      -DNVIPC_DOCA_ENABLE=OFF \
      -DNVIPC_CUDA_ENABLE=OFF \
      -DENABLE_SLT_RSP=ON

    make -j"$(nproc)"
    make install
    ldconfig

    echo "[OAI-DEV] nvIPC build/install done."
  else
    echo "[OAI-DEV] nvIPC already installed in /usr/local/lib."
  fi

  ########################################
  # Incremental OAI build
  ########################################

  cd /oai-ran/cmake_targets
  mkdir -p log

  echo "[OAI-DEV] Building OAI gNB Aerial incrementally..."
  echo "[OAI-DEV] Important: build_oai is called WITHOUT -c"

  ./build_oai -w AERIAL --gNB --ninja --build-tool-opt -k10 \
    --cmake-opt -DCMAKE_C_FLAGS="-Werror" \
    --cmake-opt -DCMAKE_CXX_FLAGS="-Werror"

  ########################################
  # Check output
  ########################################

  if [ ! -f /oai-ran/cmake_targets/ran_build/build/nr-softmodem ]; then
    echo "[OAI-DEV] ERROR: nr-softmodem was not generated."
    exit 1
  fi

  echo "[OAI-DEV] Build completed."
  ls -lh /oai-ran/cmake_targets/ran_build/build/nr-softmodem
'

echo "========================================"
echo "[OAI-DEV] Done."
echo "[OAI-DEV] Built binary on host:"
echo "  ${OAI_REPO}/cmake_targets/ran_build/build/nr-softmodem"
echo ""
echo "[OAI-DEV] To run with this dev binary, use dev compose override:"
echo "  ./down_sa_gnb_aerial.sh"
echo "  ./up_sa_gnb_aerial_dev.sh"
echo "========================================"