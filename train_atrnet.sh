#!/bin/bash

# ATRNet-STAR Training Script for DiffDet4SAR
# This script activates the conda environment and starts training

echo "=========================================="
echo "Starting DiffDet4SAR Training on ATRNet-STAR"
echo "=========================================="
echo ""

# Change to DiffDet4SAR directory
cd "/media/alexandre/E6AE9051AE901BDD/PIE Code/ATR/ATR-Segmentation/DiffDet4SAR"

# Activate conda environment
conda activate torch-env

# Check if OpenCV is installed, if not install it
python -c "import cv2" 2>/dev/null || {
    echo "OpenCV not found. Installing..."
    pip install opencv-python
}

echo ""
echo "Starting training with these settings:"
echo "  - Dataset: ATRNet-STAR (SOC-40 classes)"
echo "  - Model: DiffusionDet with ResNet-50 backbone"
echo "  - Batch size: 4 images per iteration"
echo "  - Max iterations: 90,000"
echo "  - GPU: 1 (your RTX 3070 Laptop)"
echo ""
echo "Training output will be saved to: ./output_atrnet_star/"
echo ""
echo "To monitor training progress:"
echo "  tensorboard --logdir output_atrnet_star/ --port 6006"
echo ""
echo "=========================================="
echo ""

# Start training
python train_net.py \
    --num-gpus 1 \
    --config-file configs/diffdet.atrnet.res50.yaml

echo ""
echo "=========================================="
echo "Training completed or interrupted"
echo "=========================================="
