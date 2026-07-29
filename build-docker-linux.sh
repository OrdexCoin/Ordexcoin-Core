#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
IMAGE_NAME="ordexcoin-core-linux-builder"
OUT_DIR="${ROOT_DIR}/build/linux"
VERSION="v25.0.0"

echo "==> Building OrdexCoin Core Linux image..."
echo "    First build may take 30-60 minutes."
echo ""

docker build -t "${IMAGE_NAME}" \
    --target builder \
    -f Dockerfile.linux .

echo ""
echo "==> Extracting Linux binaries to ${OUT_DIR}/bin/..."
rm -rf "${OUT_DIR}"
mkdir -p "${OUT_DIR}/bin"

CONTAINER_ID=$(docker create "${IMAGE_NAME}")
docker cp "${CONTAINER_ID}:/opt/ordexcoin/bin/." "${OUT_DIR}/bin/"
docker rm "${CONTAINER_ID}" > /dev/null

echo ""
echo "==> Creating build/ordexcoin-${VERSION}-linux-x86_64.tar.gz..."
cd "${ROOT_DIR}/build"
tar czf "ordexcoin-${VERSION}-linux-x86_64.tar.gz" linux/bin/*
cd - > /dev/null

echo ""
echo "==> Built Linux binaries:"
ls -lh "${OUT_DIR}/bin/"
file "${OUT_DIR}/bin/"*

echo ""
echo "==> Done! Output:"
echo "    build/linux/           (individual binaries)"
echo "    build/ordexcoin-${VERSION}-linux-x86_64.tar.gz"
