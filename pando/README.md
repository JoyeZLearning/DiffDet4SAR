# PANDO Supercomputer Deployment

Quick guide to run DiffDet4SAR training on the PANDO supercomputer at ISAE-Supaero.

## ⚡ Quick Start (RECOMMENDED - Lightweight Deploy)

**Fastest method:** Upload only code (~7MB), let PANDO download dataset with its fast connection!

```bash
# 1. Deploy code and auto-setup everything (5 minutes)
bash pando/deploy_lightweight.sh --full

# 2. Monitor training (from another terminal)
ssh a.jesus@pando
squeue -u $USER
tail -f ~/DiffDet4SAR-project/DiffDet4SAR/output_atrnet_star_pando/training.log

# 3. Download results when done
bash pando/download_results.sh
```

**That's it!** Training will complete in ~3-6 hours on V100 GPU.

---

## 📦 Alternative: Full Deploy (Upload Local Dataset)

If you prefer to upload your local dataset (slower, 30-60 min upload time):

```bash
# Upload everything: code + 9GB dataset
bash pando/deploy_to_pando.sh --setup --submit
```

---

## Deployment Methods Comparison

| Method | Upload Time | Upload Size | Best For |
|--------|-------------|-------------|----------|
| **Lightweight** (NEW) | 5 min | ~7MB | First time, fast setup |
| Full deploy | 30-60 min | ~9GB | When dataset local |

## Files

| File | Purpose |
|------|---------|
| `deploy_lightweight.sh` | **NEW!** Upload code only, PANDO downloads dataset (fast) |
| `download_dataset.sh` | **NEW!** Download dataset on PANDO (runs on supercomputer) |
| `deploy_to_pando.sh` | Upload code + data to PANDO via rsync (slow) |
| `setup_environment.sh` | Install conda env + PyTorch + dependencies |
| `train.slurm` | Slurm job: training on V100 GPU |
| `visualize.slurm` | Slurm job: generate detection visualizations |
| `download_results.sh` | Download trained model + results back |

## Workflow

### First-time setup
```bash
# Upload everything and setup environment
bash pando/deploy_to_pando.sh --setup
```

### Submit training
```bash
ssh a.jesus@pando
cd ~/DiffDet4SAR-project/DiffDet4SAR
sbatch pando/train.slurm
```

### Monitor
```bash
squeue -u $USER                    # Check job status
tail -f output_atrnet_star_pando/training.log  # Watch training
scancel <JOB_ID>                   # Cancel if needed
```

### After training - visualize
```bash
# Chain visualization to run after training completes
sbatch --dependency=afterok:<TRAIN_JOB_ID> pando/visualize.slurm
```

### Download results
```bash
# From local machine
bash pando/download_results.sh
```

## Config: V100 vs Local

| Setting | Local (RTX 3070 8GB) | PANDO (V100 32GB) |
|---------|---------------------|-------------------|
| Batch size | 2 | 8 |
| Proposals | 300 | 500 |
| Image sizes | (640, 800) | (800, 1000, 1200) |
| Workers | 2 | 4 |
| Config file | `diffdet.atrnet.res50.yaml` | `diffdet.atrnet.v100.yaml` |
| Est. time | ~18 hours | ~4-5 hours |

## Deploy options

### Lightweight (Recommended)
```bash
bash pando/deploy_lightweight.sh              # Upload code only
bash pando/deploy_lightweight.sh --full       # Upload + setup + download data + train
```

### Full Deploy (with local dataset)
```bash
bash pando/deploy_to_pando.sh              # Upload code + data
bash pando/deploy_to_pando.sh --no-data    # Code only (data already there)
bash pando/deploy_to_pando.sh --setup      # Upload + setup environment
bash pando/deploy_to_pando.sh --submit     # Upload + submit training
```
