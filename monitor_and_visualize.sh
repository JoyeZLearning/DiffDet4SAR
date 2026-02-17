#!/bin/bash

# Monitor training and run visualization when checkpoints are available

CHECKPOINT_DIR="./output_atrnet_star"
VIS_SCRIPT="./visualize_detections.py"
LAST_CHECKPOINT=""

echo "========================================"
echo "DiffDet4SAR Training Monitor"
echo "========================================"
echo ""
echo "This script monitors training and automatically"
echo "creates visualizations when new checkpoints are saved."
echo ""

# Check if training is running
if ! pgrep -f "train_net.py" > /dev/null; then
    echo "⚠️  Warning: Training doesn't appear to be running"
    echo ""
fi

# Activate conda environment
source ~/miniconda3/etc/profile.d/conda.sh
conda activate torch-env

while true; do
    # Get latest checkpoint
    LATEST_CHECKPOINT=$(ls -t ${CHECKPOINT_DIR}/model_*.pth 2>/dev/null | head -1)
    
    if [ -n "$LATEST_CHECKPOINT" ] && [ "$LATEST_CHECKPOINT" != "$LAST_CHECKPOINT" ]; then
        ITERATION=$(basename "$LATEST_CHECKPOINT" | sed 's/model_//' | sed 's/.pth//')
        
        echo ""
        echo "========================================"
        echo "🎉 New checkpoint detected!"
        echo "   Iteration: $ITERATION"
        echo "   File: $(basename $LATEST_CHECKPOINT)"
        echo "========================================"
        echo ""
        
        # Create visualizations
        echo "Creating visualizations..."
        python "$VIS_SCRIPT" \
            --weights "$LATEST_CHECKPOINT" \
            --num-samples 10 \
            --confidence-threshold 0.5 \
            --output-dir "./visualizations_iter_${ITERATION}"
        
        echo ""
        echo "✅ Visualizations saved to: ./visualizations_iter_${ITERATION}"
        echo ""
        
        LAST_CHECKPOINT="$LATEST_CHECKPOINT"
    fi
    
    # Show current training status
    if [ -f "./training_output.log" ]; then
        LAST_LINE=$(tail -n 1 ./training_output.log | grep "iter:")
        if [ -n "$LAST_LINE" ]; then
            CURR_ITER=$(echo "$LAST_LINE" | grep -oP 'iter: \K[0-9]+')
            TOTAL_LOSS=$(echo "$LAST_LINE" | grep -oP 'total_loss: \K[0-9.]+')
            ETA=$(echo "$LAST_LINE" | grep -oP 'eta: \K[0-9:]+')
            
            echo -ne "\r📊 Iteration: $CURR_ITER/90000 | Loss: $TOTAL_LOSS | ETA: $ETA | Next checkpoint: $(( (($CURR_ITER / 5000) + 1) * 5000 ))    "
        fi
    fi
    
    sleep 30
done
