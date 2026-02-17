#!/bin/bash
###############################################################################
# Deploy DiffDet4SAR project to PANDO Supercomputer
#
# This script uploads all code and data, sets up the environment,
# and optionally submits the training job.
#
# Usage:
#   bash pando/deploy_to_pando.sh              # Upload everything
#   bash pando/deploy_to_pando.sh --no-data    # Upload code only (skip dataset)
#   bash pando/deploy_to_pando.sh --submit     # Upload + submit training job
#
# Prerequisites:
#   - SSH access to a.jesus@pando (key-based auth recommended)
#   - Dataset extracted locally (ATRNet-STAR-data folder)
###############################################################################

set -e

# --- Configuration ---
REMOTE_USER="a.jesus"
REMOTE_HOST="pando"
REMOTE_DIR="~/DiffDet4SAR-project"

# Parse script directory (where this script is located)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
WORKSPACE_DIR="$(cd "$PROJECT_DIR/.." && pwd)"

DIFFDET_DIR="$PROJECT_DIR"
DATA_DIR="$WORKSPACE_DIR/ATRNet-STAR-data"

# Parse arguments
SKIP_DATA=false
SUBMIT_JOB=false
SETUP_ENV=false

for arg in "$@"; do
    case $arg in
        --no-data)    SKIP_DATA=true ;;
        --submit)     SUBMIT_JOB=true ;;
        --setup)      SETUP_ENV=true ;;
        --help|-h)
            echo "Usage: bash pando/deploy_to_pando.sh [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --no-data   Skip uploading dataset (code only)"
            echo "  --submit    Submit training job after upload"
            echo "  --setup     Run environment setup on PANDO after upload"
            echo "  -h, --help  Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $arg"
            exit 1
            ;;
    esac
done

echo "=============================================="
echo " Deploy DiffDet4SAR to PANDO"
echo "=============================================="
echo ""
echo " Local project:  $DIFFDET_DIR"
echo " Local data:     $DATA_DIR"
echo " Remote target:  ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DIR}"
echo " Skip data:      $SKIP_DATA"
echo " Submit job:     $SUBMIT_JOB"
echo " Setup env:      $SETUP_ENV"
echo ""

# --- Verify local files exist ---
if [ ! -d "$DIFFDET_DIR" ]; then
    echo "ERROR: DiffDet4SAR directory not found: $DIFFDET_DIR"
    exit 1
fi

if [ "$SKIP_DATA" = false ] && [ ! -d "$DATA_DIR" ]; then
    echo "ERROR: ATRNet-STAR-data directory not found: $DATA_DIR"
    echo "  Use --no-data to skip dataset upload"
    exit 1
fi

# --- Test SSH connection ---
echo "[1/5] Testing SSH connection..."
if ! ssh -o ConnectTimeout=10 -o BatchMode=yes ${REMOTE_USER}@${REMOTE_HOST} "echo 'SSH OK'" 2>/dev/null; then
    echo "ERROR: Cannot connect to ${REMOTE_USER}@${REMOTE_HOST}"
    echo "  Make sure SSH keys are set up or use ssh-copy-id first"
    exit 1
fi
echo "  ✓ SSH connection successful"

# --- Create remote directory structure ---
echo ""
echo "[2/5] Creating remote directory structure..."
ssh ${REMOTE_USER}@${REMOTE_HOST} "mkdir -p ${REMOTE_DIR}"
echo "  ✓ Remote directory ready"

# --- Upload DiffDet4SAR code ---
echo ""
echo "[3/5] Uploading DiffDet4SAR code..."
echo "  Syncing code (excluding heavy/unnecessary files)..."

rsync -avz --progress \
    --exclude='.git/' \
    --exclude='__pycache__/' \
    --exclude='*.pyc' \
    --exclude='output_*/' \
    --exclude='demo_visualizations/' \
    --exclude='visualizations_*/' \
    --exclude='*.7z*' \
    --exclude='.ipynb_checkpoints/' \
    "$DIFFDET_DIR/" \
    "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DIR}/DiffDet4SAR/"

echo "  ✓ Code uploaded"

# --- Upload dataset ---
if [ "$SKIP_DATA" = false ]; then
    echo ""
    echo "[4/5] Uploading ATRNet-STAR dataset..."
    echo "  This may take a while for ~9GB of images..."
    echo ""

    # Upload annotations first (small, fast)
    echo "  Uploading annotations..."
    rsync -avz --progress \
        "$DATA_DIR/Ground_Range/annotation_coco/" \
        "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DIR}/ATRNet-STAR-data/Ground_Range/annotation_coco/"

    # Upload images (large, slow)
    echo ""
    echo "  Uploading training images..."
    rsync -avz --progress \
        --exclude='*.7z*' \
        --exclude='__MACOSX/' \
        "$DATA_DIR/Ground_Range/Amplitude_8bit/SOC_40classes/train/" \
        "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DIR}/ATRNet-STAR-data/Ground_Range/Amplitude_8bit/SOC_40classes/train/"

    echo ""
    echo "  Uploading test images..."
    rsync -avz --progress \
        --exclude='*.7z*' \
        --exclude='__MACOSX/' \
        "$DATA_DIR/Ground_Range/Amplitude_8bit/SOC_40classes/test/" \
        "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DIR}/ATRNet-STAR-data/Ground_Range/Amplitude_8bit/SOC_40classes/test/"

    echo "  ✓ Dataset uploaded"
else
    echo ""
    echo "[4/5] Skipping dataset upload (--no-data)"
fi

# --- Setup environment (optional) ---
if [ "$SETUP_ENV" = true ]; then
    echo ""
    echo "[5/5] Setting up environment on PANDO..."
    ssh -t ${REMOTE_USER}@${REMOTE_HOST} "cd ${REMOTE_DIR} && bash DiffDet4SAR/pando/setup_environment.sh"
    echo "  ✓ Environment configured"
else
    echo ""
    echo "[5/5] Skipping environment setup (use --setup to run)"
fi

# --- Submit training job (optional) ---
if [ "$SUBMIT_JOB" = true ]; then
    echo ""
    echo "Submitting training job..."
    ssh ${REMOTE_USER}@${REMOTE_HOST} "cd ${REMOTE_DIR}/DiffDet4SAR && mkdir -p pando/slurm_logs && sbatch pando/train.slurm"
    echo "  ✓ Training job submitted!"
fi

echo ""
echo "=============================================="
echo " Deployment Complete!"
echo "=============================================="
echo ""
echo " What to do next:"
echo ""
echo " 1. SSH into PANDO:"
echo "      ssh ${REMOTE_USER}@${REMOTE_HOST}"
echo ""
if [ "$SETUP_ENV" = false ]; then
    echo " 2. Run environment setup (first time only):"
    echo "      cd ${REMOTE_DIR}"
    echo "      bash DiffDet4SAR/pando/setup_environment.sh"
    echo ""
fi
if [ "$SUBMIT_JOB" = false ]; then
    echo " 3. Submit training job:"
    echo "      cd ${REMOTE_DIR}/DiffDet4SAR"
    echo "      sbatch pando/train.slurm"
    echo ""
fi
echo " 4. Monitor training:"
echo "      squeue -u \$USER"
echo "      tail -f ${REMOTE_DIR}/DiffDet4SAR/output_atrnet_star_pando/training.log"
echo ""
echo " 5. Submit visualization after training:"
echo "      sbatch pando/visualize.slurm"
echo "    Or chain: sbatch --dependency=afterok:<JOB_ID> pando/visualize.slurm"
echo ""
echo " 6. Download results:"
echo "      bash pando/download_results.sh"
echo ""
