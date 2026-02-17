# DiffDet4SAR - Essential Files Analysis

## 🎯 What's MANDATORY for Training

### Absolutely Essential (~10-20 MB)
```
DiffDet4SAR/
├── train_net.py                    # Main training script
├── configs/                         # Configuration files
│   ├── Base-DiffusionDet.yaml
│   ├── diffdet.atrnet.res50.yaml   # Local training config
│   └── diffdet.atrnet.v100.yaml    # PANDO config
├── diffusiondet/                    # Core model implementation
│   ├── __init__.py
│   ├── detector.py
│   ├── head.py
│   ├── loss.py
│   ├── util/
│   └── register_atrnet.py          # Dataset registration
├── detectron2/                      # In-tree detectron2 (NEEDED!)
│   └── [full detectron2 package]
├── fvcore/                          # In-tree fvcore (NEEDED!)
│   └── [fvcore package]
└── pando/                           # Deployment scripts
    ├── *.sh, *.slurm
```

**Size: ~15-20 MB**

---

## ❌ What's NOT NEEDED (Can Delete or Exclude)

### Top-Level Redundant Files
```
/ATR-Segmentation/
├── detectron2/           # ❌ DUPLICATE! DiffDet4SAR has its own
├── ATRNet-STAR/          # ❌ Documentation only (classification examples)
├── J2_exos/              # ❌ Unrelated Jupyter examples
└── ATRNet-STAR-data/     # ⚠️ NEEDED but uploaded separately (9GB)
```

### Inside DiffDet4SAR (Can Exclude)
```
DiffDet4SAR/
├── .git/                           # ❌ Git history (if using fresh clone)
├── output_atrnet_star/            # ❌ Training outputs (download later)
├── demo_visualizations/           # ❌ Demo images
├── visualizations/                # ❌ Generated visualizations
├── DL-Project/                    # ❌ If you cloned another repo here
├── *.log                          # ❌ Local logs
├── demo.py                        # ❌ Demo script (not for training)
├── demo_visualization.py          # ❌ Demo only
├── flatten_dataset.py             # ❌ One-time dataset fix script
├── test_dataset.py                # ❌ Testing script
├── monitor_and_train.sh           # ❌ Local convenience script
└── GETTING_STARTED.md, etc.       # ❌ Documentation (optional)
```

---

## 📦 Minimal Training Package (Git Approach)

### Create .gitignore for clean upload
```gitignore
# Outputs
output_*/
demo_visualizations/
visualizations*/
*.log

# Cache
__pycache__/
*.pyc
*.pyo
.ipynb_checkpoints/

# Dataset (upload separately or download on PANDO)
ATRNet-STAR-data/

# Training artifacts
model_*.pth
last_checkpoint
checkpoint

# Local scripts (not needed on PANDO)
demo*.py
flatten_dataset.py
test_dataset.py
monitor_*.sh
train_atrnet.sh

# Cloned repos
DL-Project/
```

### Essential files to commit to Git
```bash
# Core training code
train_net.py
voc2coco.py

# Configs
configs/

# Model implementation
diffusiondet/

# Dependencies (in-tree)
detectron2/
fvcore/

# PANDO deployment
pando/

# Utilities
visualize_detections.py
resume_training.sh

# Documentation (optional but useful)
README.md
SETUP_ATRNet-STAR.md
pando/README.md
```

**Git repo size: ~15-20 MB (without dataset)**

---

## 🚀 Recommended Git Workflow for PANDO

### 1. Create clean Git repo (Local)
```bash
cd DiffDet4SAR

# Add .gitignore (see above)
nano .gitignore

# Initialize if not already
git init

# Add and commit only essential files
git add train_net.py configs/ diffusiondet/ detectron2/ fvcore/ pando/ *.md
git commit -m "DiffDet4SAR training code for PANDO"

# Push to your repo
git remote add origin https://github.com/YOUR_USERNAME/DiffDet4SAR-PANDO.git
git push -u origin main
```

### 2. Clone on PANDO
```bash
# SSH to PANDO
ssh a.jesus@pando

# Set proxy
export https_proxy=http://proxy.isae.fr:3128
export http_proxy=http://proxy.isae.fr:3128

# Clone your repo
cd ~/DiffDet4SAR-project
git clone https://github.com/YOUR_USERNAME/DiffDet4SAR-PANDO.git DiffDet4SAR

# Setup environment
cd DiffDet4SAR
bash pando/setup_environment.sh

# Download dataset on PANDO
bash pando/download_dataset.sh

# Start training
sbatch pando/train.slurm
```

---

## 📊 Size Comparison

| Component | Size | Need for Training? |
|-----------|------|-------------------|
| **DiffDet4SAR code** | ~15-20 MB | ✅ YES |
| `detectron2/` (in-tree) | ~8 MB | ✅ YES (part of code) |
| `fvcore/` (in-tree) | ~2 MB | ✅ YES (part of code) |
| `diffusiondet/` | ~1 MB | ✅ YES |
| `configs/` | <1 MB | ✅ YES |
| **Top-level detectron2/** | ~8 MB | ❌ NO (duplicate!) |
| ATRNet-STAR/ | ~88 MB | ❌ NO (docs only) |
| ATRNet-STAR-data/ | ~9 GB | ✅ YES (but upload separately) |
| output_atrnet_star/ | ~1.3 GB | ❌ NO (generated locally) |
| J2_exos/ | ~? MB | ❌ NO (unrelated) |

---

## ✅ Summary

**For Git-based PANDO deployment:**

1. **Commit to Git:** Only `DiffDet4SAR/` essentials (~15-20 MB)
2. **Top-level `/detectron2/` folder:** ❌ DELETE or ignore (it's redundant)
3. **Dataset:** Download on PANDO via `download_dataset.sh` script
4. **Total upload via Git:** ~20 MB (fast!)
5. **Environment:** Use virtual env on PANDO, install via `setup_environment.sh`

**Minimal command set:**
```bash
# Local: Push to Git
cd DiffDet4SAR
git push

# PANDO: Clone and run
ssh a.jesus@pando
git clone <your-repo>
bash pando/setup_environment.sh
bash pando/download_dataset.sh
sbatch pando/train.slurm
```

**Total deployment time: ~5-10 minutes!**
