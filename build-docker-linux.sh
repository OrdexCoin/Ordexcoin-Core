#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
VERSION="v25.0.0"

# Parse flags
STATIC=false
DOCKERFILE="Dockerfile.linux"
IMAGE_NAME="ordexcoin-core-linux-builder"
SUFFIX=""
TAG_SUFFIX=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --static)
            STATIC=true
            DOCKERFILE="Dockerfile.linux.static"
            IMAGE_NAME="ordexcoin-core-linux-static-builder"
            SUFFIX="-static"
            TAG_SUFFIX="-static"
            shift
            ;;
        *)
            echo "Usage: $0 [--static]"
            exit 1
            ;;
    esac
done

OUT_DIR="${ROOT_DIR}/build/linux"
ARCHIVE="ordexcoin-${VERSION}-linux-x86_64${TAG_SUFFIX}.tar.gz"

echo "==> Building OrdexCoin Core Linux image${TAG_SUFFIX}..."
echo "    Dockerfile: ${DOCKERFILE}"
echo "    First build may take 30-60 minutes."
echo ""

docker build -t "${IMAGE_NAME}" \
    --target builder \
    -f "${DOCKERFILE}" .

echo ""
echo "==> Extracting Linux binaries to ${OUT_DIR}/bin/..."
mkdir -p "${OUT_DIR}/bin"

CONTAINER_ID=$(docker create "${IMAGE_NAME}")
docker cp "${CONTAINER_ID}:/opt/ordexcoin/bin/." /tmp/ordexcoin-extract-$$
docker rm "${CONTAINER_ID}" > /dev/null

# Copy binaries, adding -static suffix when building static
for f in /tmp/ordexcoin-extract-$$/*; do
    base="$(basename "$f")"
    cp "$f" "${OUT_DIR}/bin/${base}${SUFFIX}"
done
rm -rf /tmp/ordexcoin-extract-$$

echo ""
echo "==> Creating build/${ARCHIVE}..."
cd "${ROOT_DIR}/build"
tar czf "${ARCHIVE}" linux/bin/*
cd - > /dev/null

echo ""
echo "==> Built Linux binaries${TAG_SUFFIX}:"
ls -lh "${OUT_DIR}/bin/"*"${SUFFIX}" 2>/dev/null || ls -lh "${OUT_DIR}/bin/"
file "${OUT_DIR}/bin/"*"${SUFFIX}" 2>/dev/null || file "${OUT_DIR}/bin/"*

echo ""
echo "==> Done! Output:"
echo "    build/linux/           (individual binaries)"
echo "    build/${ARCHIVE}"
