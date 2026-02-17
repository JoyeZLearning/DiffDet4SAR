#!/bin/bash
###############################################################################
# PANDO Supercomputer - DiffDet4SAR Training Job (Slurm)
#
# Submit with:  sbatch pando/train.slurm
# Monitor with: squeue -u $USER
# Cancel with:  scancel <JOB_ID>
# View logs:    tail -f output_atrnet_star_pando/training.log
###############################################################################

#SBATCH --job-name=diffdet4sar
#SBATCH --partition=gpu
#SBATCH --gres=gpu:1
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --time=24:00:00
#SBATCH --output=pando/slurm_logs/train_%j.out
#SBATCH --error=pando/slurm_logs/train_%j.err
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=a.jesus@isae-supaero.fr

set -e

echo "=============================================="
echo " DiffDet4SAR Training - PANDO"
echo "=============================================="
echo " Job ID:    $SLURM_JOB_ID"
echo " Node:      $SLURM_NODELIST"
echo " GPUs:      $SLURM_GPUS_ON_NODE"
echo " Started:   $(date)"
echo "=============================================="
echo ""

# --- Environment setup ---
module load python/2023-3
source activate diffdet4sar

# Set proxy (needed for downloading pretrained weights on first run)
export https_proxy=http://proxy.isae.fr:3128
export http_proxy=http://proxy.isae.fr:3128

# Navigate to project directory
cd ~/DiffDet4SAR-project/DiffDet4SAR

# Create log and output directories
mkdir -p output_atrnet_star_pando
mkdir -p pando/slurm_logs

# Print GPU info
python -c "
import torch
print(f'PyTorch {torch.__version__}')
print(f'CUDA available: {torch.cuda.is_available()}')
if torch.cuda.is_available():
    print(f'GPU: {torch.cuda.get_device_name(0)}')
    print(f'VRAM: {torch.cuda.get_device_properties(0).total_mem / 1e9:.1f} GB')
"

echo ""
echo "Starting training..."
echo ""

# --- Launch training ---
# Uses the V100-optimized config (batch=8, proposals=500, full resolution)
python train_net.py \
    --config-file configs/diffdet.atrnet.v100.yaml \
    --num-gpus 1 \
    2>&1 | tee output_atrnet_star_pando/training.log

echo ""
echo "=============================================="
echo " Training Complete! $(date)"
echo "=============================================="
