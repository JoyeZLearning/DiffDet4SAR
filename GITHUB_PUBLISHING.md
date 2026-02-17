# Publishing DiffDet4SAR to GitHub

Complete guide to publish your DiffDet4SAR project to GitHub.

## 🎯 What Gets Published (Without Dataset)

**GitHub repo:** ~20 MB (code only)
- DiffDet4SAR code
- Training scripts
- PANDO deployment scripts
- Detectron2 & FVCore (in-tree)
- Configs & model code

**NOT in repo:** 
- Dataset (9GB) - downloaded separately
- Training outputs
- Visualizations

---

## 📋 Pre-Publication Checklist

### 1. Update .gitignore
```bash
cd DiffDet4SAR

# Use our clean gitignore
mv .gitignore_pando .gitignore

# Verify it excludes dataset and outputs
grep "ATRNet-STAR-data\|output_" .gitignore
```

### 2. Clean up local files
```bash
# Remove unnecessary files that shouldn't be in git
rm -rf output_atrnet_star/
rm -rf demo_visualizations/
rm -rf visualizations/
rm -rf DL-Project/

# Keep only essential training/config files
ls -la
# Should show: configs/, diffusiondet/, detectron2/, fvcore/, pando/, *.py, *.md, setup files
```

### 3. Verify Git status
```bash
git status
# Should show clean or only essential code files
# Should NOT show ATRNet-STAR-data/ or output_*/
```

---

## 🚀 Publishing Steps

### Option 1: Create New Repo (Recommended)

```bash
# 1. Create NEW repo on GitHub
# Go to https://github.com/new
# Name: DiffDet4SAR
# Description: "Diffusion-based Object Detection for SAR Images with ATRNet-STAR"
# Make it PUBLIC (or private)
# Don't initialize with README (we have one)

# 2. In your local DiffDet4SAR folder
cd /media/alexandre/E6AE9051AE901BDD/PIE\ Code/ATR/ATR-Segmentation/DiffDet4SAR

# 3. Initialize/reinitialize git (if needed)
git init
git add .
git commit -m "Initial commit: DiffDet4SAR training code and PANDO deployment"

# 4. Add remote and push
git remote add origin https://github.com/YOUR_USERNAME/DiffDet4SAR.git
git branch -M main
git push -u origin main
```

### Option 2: Push to Existing Repo

If you already have `DiffDet4SAR` repo:
```bash
cd DiffDet4SAR

# Update remote URL if needed
git remote set-url origin https://github.com/YOUR_USERNAME/DiffDet4SAR.git

# Add and push
git add .
git commit -m "Clean up: remove dataset and outputs, optimize for PANDO"
git push origin main
```

---

## 📚 Update Main README

Update [README.md](README.md) to include dataset download info:

```markdown
# DiffDet4SAR: Diffusion-based Object Detection for SAR Images

Training DiffusionDet on the ATRNet-STAR vehicle detection dataset.

## Quick Start

### Local Training
```bash
# Setup environment
conda create -n diffdet python=3.10
conda activate diffdet
pip install torch torchvision opencv-python timm tqdm scipy pycocotools tensorboard

# Clone and download dataset
git clone https://github.com/YOUR_USERNAME/DiffDet4SAR.git
cd DiffDet4SAR
python -c "from huggingface_hub import snapshot_download; snapshot_download('ATRNet-STAR-data', repo_type='dataset', local_dir='../ATRNet-STAR-data')"

# Train locally
python train_net.py --num-gpus 1 --config-file configs/diffdet.atrnet.res50.yaml
```

### PANDO Supercomputer (Fast!)
```bash
bash pando/deploy_lightweight.sh --full
```

## Dataset Download

### Download Locally (First-time)
```bash
cd ..  # Go to parent directory
python -c "
from huggingface_hub import snapshot_download
snapshot_download('ATRNet-STAR-data', repo_type='dataset', local_dir='ATRNet-STAR-data')
"
```

### Download on PANDO
The deployment scripts automatically download the dataset:
```bash
bash pando/download_dataset.sh
```

## Scripts

| Script | Purpose |
|--------|---------|
| `train_net.py` | Main training script |
| `visualize_detections.py` | Generate detection visualization |
| `resume_training.sh` | Resume interrupted training |
| `pando/deploy_lightweight.sh` | Deploy to PANDO (code only) |
| `pando/setup_environment.sh` | Setup environment on PANDO |
| `pando/download_dataset.sh` | Download dataset ON PANDO |
| `pando/download_results.sh` | Download results FROM PANDO |

See [pando/README.md](pando/README.md) for full PANDO guide.
```

---

## 📊 Available Dataset Download Scripts

| Script | Location | Purpose |
|--------|----------|---------|
| `pando/download_dataset.sh` | PANDO | Download dataset ON PANDO from HuggingFace |
| `pando/download_dataset_from_pando.sh` | LOCAL | Download dataset FROM PANDO to local machine |
| `pando/download_results.sh` | LOCAL | Download trained model FROM PANDO |

---

## 🔒 Publishing Checklist

Before pushing to GitHub:

```bash
# ✅ Git status is clean (only code)
git status

# ✅ .gitignore is correct
cat .gitignore | grep -E "output|demo|visual|dataset"

# ✅ No large files
git ls-files | xargs ls -lh | sort -k5 -h | tail -10

# ✅ README updated with dataset instructions
grep -i "dataset\|download" README.md

# ✅ No secrets/tokens in files
grep -r "hf_" . --include="*.py" --include="*.sh" | grep -v "hf_USER\|hf_TOKEN"
```

---

## 🎉 After Publishing

1. **Share the repo:** 
   ```
   https://github.com/YOUR_USERNAME/DiffDet4SAR
   ```

2. **Clone anywhere:**
   ```bash
   git clone https://github.com/YOUR_USERNAME/DiffDet4SAR.git
   cd DiffDet4SAR
   bash pando/deploy_lightweight.sh --full
   ```

3. **Users can:**
   - Train locally
   - Deploy to PANDO
   - Download and train on any GPU

---

## 🔄 Future Updates

After publishing, to add improvements:

```bash
# Make changes
git add .
git commit -m "Description of changes"
git push origin main
```

Popular branches:
- `main` - Stable training code
- `dev` - New features/experiments
- `pando` - PANDO-specific configs
