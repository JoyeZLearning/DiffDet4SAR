#!/bin/bash
###############################################################################
# Download ATRNet-STAR Dataset on PANDO (runs ON the supercomputer)
#
# This script downloads the dataset directly to PANDO using HuggingFace CLI
# Much faster than uploading 9GB from your laptop!
#
# Usage (ON PANDO):
#   cd ~/DiffDet4SAR-project
#   bash DiffDet4SAR/pando/download_dataset.sh
###############################################################################

set -e

echo "=============================================="
echo " Downloading ATRNet-STAR Dataset on PANDO"
echo "=============================================="
echo ""

# Set proxy for ISAE network
export https_proxy=http://proxy.isae.fr:3128
export http_proxy=http://proxy.isae.fr:3128

# Load Python module
module load python/2023-3 || true

# Check if dataset already exists
DATASET_DIR="$HOME/DiffDet4SAR-project/ATRNet-STAR-data"
if [ -d "$DATASET_DIR/Ground_Range/Amplitude_8bit/SOC_40classes/train" ]; then
    echo "✓ Dataset already exists at: $DATASET_DIR"
    echo "  Skipping download..."
    exit 0
fi

# Create dataset directory
mkdir -p "$DATASET_DIR"
cd "$DATASET_DIR"

echo "[1/4] Installing HuggingFace CLI..."
pip install --user huggingface_hub[cli] --quiet || pip3 install --user huggingface_hub[cli] --quiet

echo ""
echo "[2/4] Downloading dataset from HuggingFace..."
echo "  This will download ~9GB of data (faster on PANDO network!)"
echo ""

# Set HuggingFace token (if provided as argument)
if [ ! -z "$1" ]; then
    export HF_TOKEN="$1"
    echo "  Using provided HuggingFace token"
fi

# Download using huggingface-cli
python3 -c "
from huggingface_hub import snapshot_download
import os
import sys

token = os.environ.get('HF_TOKEN')
if not token:
    print('⚠ HF_TOKEN not set. Set it with: export HF_TOKEN=your_token')
    print('  Or login with: huggingface-cli login')
    sys.exit(1)

print('Downloading ATRNet-STAR-data...')
snapshot_download(
    repo_id='ATRNet-STAR-data',
    repo_type='dataset',
    local_dir='.',
    token=token
)
print('✓ Download complete!')
"

echo ""
echo "[3/4] Extracting compressed files..."
cd Ground_Range/Amplitude_8bit/SOC_40classes

# Check if 7z is available, install if needed
if ! command -v 7z &> /dev/null; then
    echo "  Installing p7zip..."
    # Try to install 7z (might need adjustment based on PANDO's package manager)
    module load p7zip 2>/dev/null || true
fi

# Extract training images if they're compressed
if [ -f "train.7z.001" ]; then
    echo "  Extracting training images..."
    7z x -y "train.7z.001" || {
        echo "  WARNING: 7z extraction failed. You may need to extract manually."
        echo "  Or images might already be extracted."
    }
fi

# Extract test images if they're compressed
if [ -f "test.7z.001" ]; then
    echo "  Extracting test images..."
    7z x -y "test.7z.001" || {
        echo "  WARNING: 7z extraction failed. You may need to extract manually."
        echo "  Or images might already be extracted."
    }
fi

echo ""
echo "[4/4] Flattening directory structure..."
# Flatten train directory (move all .tif from subdirs to root)
if [ -d "train" ]; then
    cd train
    if [ $(find . -mindepth 2 -name "*.tif" | wc -l) -gt 0 ]; then
        echo "  Flattening train/ directory..."
        find . -mindepth 2 -name "*.tif" -exec mv {} . \; 2>/dev/null || true
        find . -mindepth 1 -type d -empty -delete 2>/dev/null || true
    fi
    cd ..
fi

# Flatten test directory
if [ -d "test" ]; then
    cd test
    if [ $(find . -mindepth 2 -name "*.tif" | wc -l) -gt 0 ]; then
        echo "  Flattening test/ directory..."
        find . -mindepth 2 -name "*.tif" -exec mv {} . \; 2>/dev/null || true
        find . -mindepth 1 -type d -empty -delete 2>/dev/null || true
    fi
    cd ..
fi

echo ""
echo "=============================================="
echo " Dataset Download Complete!"
echo "=============================================="
echo ""
echo " Dataset location: $DATASET_DIR"
echo ""
echo " Training images:  $(find $DATASET_DIR/Ground_Range/Amplitude_8bit/SOC_40classes/train -name "*.tif" 2>/dev/null | wc -l) files"
echo " Test images:      $(find $DATASET_DIR/Ground_Range/Amplitude_8bit/SOC_40classes/test -name "*.tif" 2>/dev/null | wc -l) files"
echo ""
echo " Next steps:"
echo "   cd ~/DiffDet4SAR-project/DiffDet4SAR"
echo "   sbatch pando/train.slurm"
echo ""
