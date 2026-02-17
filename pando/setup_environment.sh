#!/bin/bash
###############################################################################
# PANDO Supercomputer - Environment Setup Script
# Run this ONCE after uploading your project to PANDO
#
# Usage: ssh a.jesus@pando
#        cd ~/DiffDet4SAR-project
#        bash pando/setup_environment.sh
###############################################################################

set -e

echo "=============================================="
echo " PANDO Environment Setup for DiffDet4SAR"
echo "=============================================="
echo ""

# --- Step 1: Load Python module ---
echo "[1/5] Loading Python module..."
module load python/2023-3
echo "  ✓ Python module loaded"

# --- Step 2: Create conda environment ---
echo ""
echo "[2/5] Creating conda environment 'diffdet4sar'..."

# Check if environment already exists
if conda env list | grep -q "diffdet4sar"; then
    echo "  Environment already exists. Updating..."
    source activate diffdet4sar
else
    conda create --name diffdet4sar python=3.10 -y
    source activate diffdet4sar
    echo "  ✓ Environment created"
fi

# --- Step 3: Set proxy for pip (ISAE network requirement) ---
echo ""
echo "[3/5] Configuring proxy..."
export https_proxy=http://proxy.isae.fr:3128
export http_proxy=http://proxy.isae.fr:3128
echo "  ✓ Proxy configured"

# --- Step 4: Install PyTorch with CUDA ---
echo ""
echo "[4/5] Installing PyTorch and dependencies..."
echo "  This may take a few minutes..."

# Install PyTorch with CUDA support (for V100 GPUs)
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118

# Install other dependencies
pip install opencv-python-headless  # headless for server (no GUI)
pip install timm
pip install tqdm
pip install scipy
pip install pycocotools
pip install tensorboard
pip install Pillow

echo "  ✓ All packages installed"

# --- Step 5: Install local detectron2 and fvcore ---
echo ""
echo "[5/5] Setting up project packages..."
cd ~/DiffDet4SAR-project/DiffDet4SAR

# The project includes its own detectron2 and fvcore in-tree, no pip install needed
# Just verify imports work
python -c "
import sys
sys.path.insert(0, '.')
import torch
print(f'  PyTorch: {torch.__version__}')
print(f'  CUDA available: {torch.cuda.is_available()}')
if torch.cuda.is_available():
    print(f'  GPU: {torch.cuda.get_device_name(0)}')
    print(f'  VRAM: {torch.cuda.get_device_properties(0).total_mem / 1e9:.1f} GB')
from detectron2 import model_zoo
print(f'  detectron2: OK')
from diffusiondet import DiffusionDet
print(f'  diffusiondet: OK')
print()
print('  ✓ All imports successful!')
"

echo ""
echo "=============================================="
echo " Setup Complete!"
echo "=============================================="
echo ""
echo " To train, submit the Slurm job:"
echo "   cd ~/DiffDet4SAR-project"
echo "   sbatch pando/train.slurm"
echo ""
echo " To monitor:"
echo "   squeue -u \$USER"
echo "   tail -f DiffDet4SAR/output_atrnet_star_pando/training.log"
echo ""
