########################################
# when modified:
# Aerial L1
# cuPHY
# cuphycontroller
# l2_adapter
# CUDA/C++ PHY-side code
########################################

#!/usr/bin/env bash
set -euo pipefail

AERIAL_SRC_REPO="/home/serae/COMPASS/OTA/aerial-cuda-accelerated-ran"
AERIAL_CONTAINER_DIR="${AERIAL_SRC_REPO}/cuPHY-CP/container"

export AERIAL_VERSION_TAG="26-2-cubb_serae"
export AERIAL_PLATFORM="${AERIAL_PLATFORM:-}"  # 빈 값이면 setup.sh가 host arch로 자동 설정

cd "${AERIAL_CONTAINER_DIR}"
source ./setup.sh

echo "[AERIAL] Starting Aerial build container."
echo "[AERIAL] After entering container, run:"
echo ""
echo "  cd /opt/nvidia/cuBB"
echo "  ./testBenches/phase4_test_scripts/build_aerial_sdk.sh --preset 10_02 -- -DSCF_FAPI_10_04_SRS=ON -DENABLE_CONFORMANCE_TM_PDSCH_PDCCH=OFF"
echo ""

./run_aerial.sh


# after, 
# cd /opt/nvidia/cuBB
# ./testBenches/phase4_test_scripts/build_aerial_sdk.sh   --preset 10_02 -- -DSCF_FAPI_10_04_SRS=ON  -DENABLE_CONFORMANCE_TM_PDSCH_PDCCH=OFF