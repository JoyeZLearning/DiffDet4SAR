#!/bin/bash
###############################################################################
# Download ATRNet-STAR Dataset FROM PANDO back to Local Machine
#
# This script retrieves the dataset that was downloaded on PANDO
# and copies it back to your local machine.
#
# Usage:
#   bash pando/download_dataset_from_pando.sh
#
# The script will download from a.jesus@pando:~/DiffDet4SAR-project/ATRNet-STAR-data/
###############################################################################

set -e

REMOTE_USER="a.jesus"
REMOTE_HOST="pando"
REMOTE_DIR="~/DiffDet4SAR-project/ATRNet-STAR-data"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
WORKSPACE_DIR="$(cd "$PROJECT_DIR/.." && pwd)"

LOCAL_DATA_DIR="$WORKSPACE_DIR/ATRNet-STAR-data"

echo "=============================================="
echo " Download ATRNet-STAR Dataset from PANDO"
echo "=============================================="
echo ""
echo " Source: ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DIR}"
echo " Destination: ${LOCAL_DATA_DIR}"
echo ""

# Test SSH connection
echo "[1/3] Testing SSH connection..."
if ! ssh -o ConnectTimeout=10 -o BatchMode=yes ${REMOTE_USER}@${REMOTE_HOST} "echo 'SSH OK'" 2>/dev/null; then
    echo "ERROR: Cannot connect to ${REMOTE_USER}@${REMOTE_HOST}"
    exit 1
fi
echo "  ✓ SSH connection successful"

# Create local directory
echo ""
echo "[2/3] Creating local directory..."
mkdir -p "$LOCAL_DATA_DIR"
echo "  ✓ Directory ready"

# Download dataset from PANDO
echo ""
echo "[3/3] Downloading dataset from PANDO (~9GB, may take 10-30 minutes)..."
echo ""

# Download annotations
echo "  Downloading annotations..."
rsync -avz --progress \
    "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DIR}/Ground_Range/annotation_coco/" \
    "${LOCAL_DATA_DIR}/Ground_Range/annotation_coco/"

# Download training images
echo ""
echo "  Downloading training images..."
rsync -avz --progress \
    "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DIR}/Ground_Range/Amplitude_8bit/SOC_40classes/train/" \
    "${LOCAL_DATA_DIR}/Ground_Range/Amplitude_8bit/SOC_40classes/train/"

# Download test images
echo ""
echo "  Downloading test images..."
rsync -avz --progress \
    "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DIR}/Ground_Range/Amplitude_8bit/SOC_40classes/test/" \
    "${LOCAL_DATA_DIR}/Ground_Range/Amplitude_8bit/SOC_40classes/test/"

echo ""
echo "=============================================="
echo " ✅ Download Complete!"
echo "=============================================="
echo ""
echo " Dataset location: ${LOCAL_DATA_DIR}"
echo ""
