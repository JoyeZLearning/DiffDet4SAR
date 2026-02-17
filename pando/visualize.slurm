#!/bin/bash
###############################################################################
# PANDO Supercomputer - Run Visualization after Training (Slurm)
#
# Submit after training completes:
#   sbatch pando/visualize.slurm
#
# Or chain after training:
#   sbatch --dependency=afterok:<TRAIN_JOB_ID> pando/visualize.slurm
###############################################################################

#SBATCH --job-name=diffdet-viz
#SBATCH --partition=gpu
#SBATCH --gres=gpu:1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --time=01:00:00
#SBATCH --output=pando/slurm_logs/viz_%j.out
#SBATCH --error=pando/slurm_logs/viz_%j.err

set -e

echo "=============================================="
echo " DiffDet4SAR Visualization - PANDO"
echo "=============================================="
echo " Job ID: $SLURM_JOB_ID"
echo " Started: $(date)"
echo "=============================================="

# --- Environment setup ---
module load python/2023-3
source activate diffdet4sar

cd ~/DiffDet4SAR-project/DiffDet4SAR
mkdir -p pando/slurm_logs

# Find the best/latest model checkpoint
MODEL_DIR="output_atrnet_star_pando"
if [ -f "${MODEL_DIR}/model_final.pth" ]; then
    WEIGHTS="${MODEL_DIR}/model_final.pth"
else
    # Pick the latest checkpoint
    WEIGHTS=$(ls -t ${MODEL_DIR}/model_*.pth 2>/dev/null | head -1)
fi

if [ -z "$WEIGHTS" ]; then
    echo "ERROR: No model checkpoint found in ${MODEL_DIR}/"
    exit 1
fi

echo "Using weights: $WEIGHTS"

# --- Run visualization ---
python visualize_detections.py \
    --weights "$WEIGHTS" \
    --input-dir ../ATRNet-STAR-data/Ground_Range/Amplitude_8bit/SOC_40classes/test \
    --output-dir visualizations_pando \
    --num-samples 50 \
    --confidence-threshold 0.3

echo ""
echo "Visualizations saved to: ~/DiffDet4SAR-project/DiffDet4SAR/visualizations_pando/"
echo "Download them with:"
echo "  scp -r a.jesus@pando:~/DiffDet4SAR-project/DiffDet4SAR/visualizations_pando/ ."
echo ""
echo "Done! $(date)"
