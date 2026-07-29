#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
IMAGE_NAME="ordexcoin-core-win-builder"
OUT_DIR="${ROOT_DIR}/build/windows"
VERSION="v25.0.0"

echo "==> Building OrdexCoin Core Windows cross-compilation image..."
echo "    This downloads and builds Qt 5.15, Boost, BDB 4.8, etc."
echo "    for x86_64-w64-mingw32. First build may take 1-2 hours."
echo ""

docker build -t "${IMAGE_NAME}" \
    --target builder \
    -f Dockerfile.windows .

echo ""
echo "==> Extracting Windows binaries to ${OUT_DIR}/bin/..."
rm -rf "${OUT_DIR}"
mkdir -p "${OUT_DIR}/bin"

CONTAINER_ID=$(docker create "${IMAGE_NAME}")
docker cp "${CONTAINER_ID}:/opt/ordexcoin-win/bin/." "${OUT_DIR}/bin/"
docker rm "${CONTAINER_ID}" > /dev/null

echo ""
echo "==> Creating build/ordexcoin-${VERSION}-windows-x86_64.zip..."
cd "${ROOT_DIR}/build"
zip -9 "ordexcoin-${VERSION}-windows-x86_64.zip" windows/bin/*
cd - > /dev/null

echo ""
echo "==> Built Windows binaries:"
ls -lh "${OUT_DIR}/bin/"
file "${OUT_DIR}/bin/"*.exe

echo ""
echo "==> Done! Output:"
echo "    build/windows/           (individual .exe files)"
echo "    build/ordexcoin-${VERSION}-windows-x86_64.zip"
