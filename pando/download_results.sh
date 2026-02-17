#!/bin/bash
###############################################################################
# Download trained model and results from PANDO
#
# Usage:
#   bash pando/download_results.sh                # Download model + visualizations
#   bash pando/download_results.sh --model-only   # Download model checkpoint only
#   bash pando/download_results.sh --viz-only     # Download visualizations only
###############################################################################

set -e

REMOTE_USER="a.jesus"
REMOTE_HOST="pando"
REMOTE_DIR="~/DiffDet4SAR-project/DiffDet4SAR"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOCAL_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

DOWNLOAD_MODEL=true
DOWNLOAD_VIZ=true

for arg in "$@"; do
    case $arg in
        --model-only)  DOWNLOAD_VIZ=false ;;
        --viz-only)    DOWNLOAD_MODEL=false ;;
    esac
done

echo "=============================================="
echo " Download Results from PANDO"
echo "=============================================="

if [ "$DOWNLOAD_MODEL" = true ]; then
    echo ""
    echo "Downloading trained model and logs..."
    mkdir -p "$LOCAL_DIR/output_atrnet_star_pando"
    rsync -avz --progress \
        "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DIR}/output_atrnet_star_pando/" \
        "$LOCAL_DIR/output_atrnet_star_pando/"
    echo "  ✓ Model saved to: output_atrnet_star_pando/"
fi

if [ "$DOWNLOAD_VIZ" = true ]; then
    echo ""
    echo "Downloading visualizations..."
    mkdir -p "$LOCAL_DIR/visualizations_pando"
    rsync -avz --progress \
        "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DIR}/visualizations_pando/" \
        "$LOCAL_DIR/visualizations_pando/" 2>/dev/null || echo "  (No visualizations found - run visualize.slurm first)"
    echo "  ✓ Visualizations saved to: visualizations_pando/"
fi

echo ""
echo "Downloading Slurm logs..."
mkdir -p "$LOCAL_DIR/pando/slurm_logs"
rsync -avz --progress \
    "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DIR}/pando/slurm_logs/" \
    "$LOCAL_DIR/pando/slurm_logs/" 2>/dev/null || echo "  (No Slurm logs yet)"

echo ""
echo "=============================================="
echo " Download Complete!"
echo "=============================================="
echo ""
echo " Model checkpoints: output_atrnet_star_pando/"
echo " Visualizations:    visualizations_pando/"
echo " Slurm logs:        pando/slurm_logs/"
echo ""
