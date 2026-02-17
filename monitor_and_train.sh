#!/bin/bash

# Monitor ATRNet-STAR Dataset Extraction and Auto-start Training
# This script monitors the extraction progress and starts training when complete

EXTRACT_DIR="/media/alexandre/E6AE9051AE901BDD/PIE Code/ATR/ATR-Segmentation/ATRNet-STAR-data/Ground_Range/Amplitude_8bit"
EXTRACT_LOG="$EXTRACT_DIR/extraction.log"
TRAIN_DIR="/media/alexandre/E6AE9051AE901BDD/PIE Code/ATR/ATR-Segmentation/DiffDet4SAR"

echo "=========================================="
echo "Monitoring Dataset Extraction Progress"
echo "=========================================="
echo ""

# Function to count extracted images
count_images() {
    find "$EXTRACT_DIR/SOC_40classes/train" -name "*.tif" 2>/dev/null | wc -l
}

# Expected number of training images
EXPECTED_TRAIN=68091

echo "Expected training images: $EXPECTED_TRAIN"
echo ""

# Monitor extraction
while true; do
    CURRENT=$(count_images)
    
    # Check if extraction log exists
    if [ -f "$EXTRACT_LOG" ]; then
        LAST_LINE=$(tail -n 1 "$EXTRACT_LOG")
        echo -ne "\rExtracted: $CURRENT / $EXPECTED_TRAIN images | Status: $LAST_LINE"
    else
        echo -ne "\rExtracted: $CURRENT / $EXPECTED_TRAIN images"
    fi
    
    # Check if extraction is complete
    if [ "$CURRENT" -ge "$EXPECTED_TRAIN" ]; then
        echo ""
        echo ""
        echo "✓ Extraction complete! Found $CURRENT images"
        break
    fi
    
    # Check if 7z process is still running
    if ! pgrep -f "7z x" > /dev/null; then
        echo ""
        echo ""
        echo "Warning: 7z extraction process not running"
        echo "Current extracted: $CURRENT images"
        
        if [ "$CURRENT" -gt 0 ] && [ "$CURRENT" -lt "$EXPECTED_TRAIN" ]; then
            echo "Extraction seems incomplete. Please check extraction.log"
            exit 1
        fi
        break
    fi
    
    sleep 10
done

echo ""
echo "=========================================="
echo "Starting Training"
echo "=========================================="
echo ""

cd "$TRAIN_DIR"

# Activate conda environment and start training
bash -c "source ~/miniconda3/etc/profile.d/conda.sh && conda activate torch-env && python train_net.py --num-gpus 1 --config-file configs/diffdet.atrnet.res50.yaml"
