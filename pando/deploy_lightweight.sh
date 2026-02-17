#!/bin/bash
###############################################################################
# Lightweight Deploy to PANDO - CODE ONLY (faster!)
#
# This script uploads only the code (~7MB) and setup scripts.
# Dataset is downloaded directly on PANDO using their fast connection.
#
# Usage:
#   bash pando/deploy_lightweight.sh              # Upload code only
#   bash pando/deploy_lightweight.sh --full       # Upload + setup + download data + train
#
# Prerequisites:
#   - SSH access to a.jesus@pando (key-based auth recommended)
###############################################################################

set -e

# --- Configuration ---
REMOTE_USER="a.jesus"
REMOTE_HOST="pando"
REMOTE_DIR="~/DiffDet4SAR-project"

# Parse script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

DIFFDET_DIR="$PROJECT_DIR"

# Parse arguments
FULL_SETUP=false
HF_TOKEN=""

for arg in "$@"; do
    case $arg in
        --full)       FULL_SETUP=true ;;
        --token=*)    HF_TOKEN="${arg#*=}" ;;
        --help|-h)
            echo "Usage: bash pando/deploy_lightweight.sh [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --full               Full setup: upload + env setup + download dataset + train"
            echo "  --token=HF_TOKEN     HuggingFace token (optional)"
            echo "  -h, --help           Show this help message"
            echo ""
            echo "This uploads ONLY code (~7MB), not the dataset."
            echo "Dataset is downloaded on PANDO using their fast connection."
            exit 0
            ;;
        *)
            echo "Unknown option: $arg"
            exit 1
            ;;
    esac
done

echo "=============================================="
echo " Lightweight Deploy to PANDO (Code Only)"
echo "=============================================="
echo ""
echo " Local project:  $DIFFDET_DIR"
echo " Remote target:  ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DIR}"
echo " Full setup:     $FULL_SETUP"
echo ""

# --- Verify local files exist ---
if [ ! -d "$DIFFDET_DIR" ]; then
    echo "ERROR: DiffDet4SAR directory not found: $DIFFDET_DIR"
    exit 1
fi

# --- Test SSH connection ---
echo "[1/3] Testing SSH connection..."
if ! ssh -o ConnectTimeout=10 -o BatchMode=yes ${REMOTE_USER}@${REMOTE_HOST} "echo 'SSH OK'" 2>/dev/null; then
    echo "ERROR: Cannot connect to ${REMOTE_USER}@${REMOTE_HOST}"
    echo "  Make sure SSH keys are set up or use ssh-copy-id first"
    exit 1
fi
echo "  ✓ SSH connection successful"

# --- Create remote directory ---
echo ""
echo "[2/3] Creating remote directory..."
ssh ${REMOTE_USER}@${REMOTE_HOST} "mkdir -p ${REMOTE_DIR}"
echo "  ✓ Remote directory ready"

# --- Upload code only (fast!) ---
echo ""
echo "[3/3] Uploading DiffDet4SAR code (~7MB)..."
echo "  This will be quick - no dataset upload!"
echo ""

rsync -avz --progress \
    --exclude='.git/' \
    --exclude='__pycache__/' \
    --exclude='*.pyc' \
    --exclude='output_*/' \
    --exclude='demo_visualizations/' \
    --exclude='visualizations*/' \
    --exclude='*.7z*' \
    --exclude='.ipynb_checkpoints/' \
    --exclude='DL-Project/' \
    "$DIFFDET_DIR/" \
    "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DIR}/DiffDet4SAR/"

echo ""
echo "  ✓ Code uploaded successfully!"

# --- Full automated setup (optional) ---
if [ "$FULL_SETUP" = true ]; then
    echo ""
    echo "=============================================="
    echo " Running Full Automated Setup on PANDO"
    echo "=============================================="
    
    # Step 1: Setup environment
    echo ""
    echo "[STEP 1/3] Setting up Python environment..."
    ssh -t ${REMOTE_USER}@${REMOTE_HOST} "cd ${REMOTE_DIR} && bash DiffDet4SAR/pando/setup_environment.sh"
    
    # Step 2: Download dataset on PANDO
    echo ""
    echo "[STEP 2/3] Downloading dataset on PANDO (using their fast connection)..."
    if [ ! -z "$HF_TOKEN" ]; then
        ssh -t ${REMOTE_USER}@${REMOTE_HOST} "cd ${REMOTE_DIR} && bash DiffDet4SAR/pando/download_dataset.sh $HF_TOKEN"
    else
        ssh -t ${REMOTE_USER}@${REMOTE_HOST} "cd ${REMOTE_DIR} && bash DiffDet4SAR/pando/download_dataset.sh"
    fi
    
    # Step 3: Submit training job
    echo ""
    echo "[STEP 3/3] Submitting training job to Slurm..."
    ssh ${REMOTE_USER}@${REMOTE_HOST} "cd ${REMOTE_DIR}/DiffDet4SAR && mkdir -p pando/slurm_logs && sbatch pando/train.slurm"
    
    echo ""
    echo "  ✓ Training job submitted!"
    echo ""
    echo "  Monitor with:"
    echo "    ssh ${REMOTE_USER}@${REMOTE_HOST}"
    echo "    squeue -u \$USER"
fi

echo ""
echo "=============================================="
echo " Deployment Complete!"
echo "=============================================="
echo ""

if [ "$FULL_SETUP" = false ]; then
    echo " Next steps (SSH into PANDO and run):"
    echo ""
    echo " 1. SSH into PANDO:"
    echo "      ssh ${REMOTE_USER}@${REMOTE_HOST}"
    echo ""
    echo " 2. Setup Python environment (first time only):"
    echo "      cd ${REMOTE_DIR}"
    echo "      bash DiffDet4SAR/pando/setup_environment.sh"
    echo ""
    echo " 3. Download dataset on PANDO (fast!):"
    echo "      bash DiffDet4SAR/pando/download_dataset.sh"
    echo ""
    echo " 4. Submit training job:"
    echo "      cd ${REMOTE_DIR}/DiffDet4SAR"
    echo "      sbatch pando/train.slurm"
    echo ""
    echo " 5. Monitor training:"
    echo "      squeue -u \$USER"
    echo "      tail -f ${REMOTE_DIR}/DiffDet4SAR/output_atrnet_star_pando/training.log"
    echo ""
    echo "=============================================="
    echo ""
    echo " OR run full automated setup:"
    echo "   bash pando/deploy_lightweight.sh --full"
    echo ""
fi

echo " Download results later:"
echo "   bash pando/download_results.sh"
echo ""
