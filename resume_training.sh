#!/bin/bash
###############################################################################
# Resume interrupted DiffDet4SAR training
#
# Usage:
#   bash resume_training.sh              # Resume from last checkpoint
#   bash resume_training.sh --config <config>  # Resume with custom config
###############################################################################

set -e

cd "$(dirname "$0")"

CONFIG_FILE="${1:-configs/diffdet.atrnet.res50.yaml}"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "ERROR: Config file not found: $CONFIG_FILE"
    exit 1
fi

echo "=============================================="
echo " Resuming DiffDet4SAR Training"
echo "=============================================="
echo " Config:  $CONFIG_FILE"
echo "=============================================="
echo ""

# Check if checkpoint exists
OUTPUT_DIR=$(grep "^OUTPUT_DIR" "$CONFIG_FILE" | awk '{print $2}' | tr -d '"')
if [ -z "$OUTPUT_DIR" ]; then
    OUTPUT_DIR="./output_atrnet_star"
fi

LAST_CKPT="$OUTPUT_DIR/last_checkpoint"

if [ ! -f "$LAST_CKPT" ]; then
    echo "ERROR: No checkpoint found. Starting fresh training instead:"
    echo ""
    echo "  python train_net.py --num-gpus 1 --config-file $CONFIG_FILE"
    echo ""
    exit 1
fi

CKPT=$(cat "$LAST_CKPT" | tail -1)
ITER=$(ls $OUTPUT_DIR/model_*.pth 2>/dev/null | tail -1 | grep -oE '[0-9]+' | tail -1)

echo "✓ Found checkpoint: $CKPT"
echo "✓ Resuming from iteration: $ITER"
echo ""
echo "Starting training..."
echo ""

# Resume with the --resume flag
python train_net.py \
    --num-gpus 1 \
    --config-file "$CONFIG_FILE" \
    --resume \
    2>&1 | tee -a "${OUTPUT_DIR}/training_output.log"
