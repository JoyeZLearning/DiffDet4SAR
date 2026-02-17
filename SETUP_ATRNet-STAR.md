# Training DiffDet4SAR with ATRNet-STAR Dataset

## Overview

ATRNet-STAR is a large-scale SAR vehicle recognition dataset with:
- **40 vehicle types** (cars, SUVs, trucks, buses, etc.)  
- **~200,000 images** (10x larger than MSTAR)
- **Pre-converted COCO annotations** for object detection
- Multiple imaging conditions (X/Ku band, quad polarization, various angles)

## Step 1: Download the ATRNet-STAR Dataset

The dataset needs to be downloaded from one of these sources:

### Option A: Hugging Face (Recommended - Fast)
```bash
# Install huggingface-cli if not already installed
conda activate torch-env
pip install huggingface-hub[cli]

# Download the dataset (choose what you need)
cd /media/alexandre/E6AE9051AE901BDD/PIE\ Code/ATR/ATR-Segmentation
huggingface-cli download waterdisappear/ATRNet-STAR --repo-type dataset --local-dir ATRNet-STAR-data
```

### Option B: Other Sources
- **Baidu Cloud**: https://www.wjx.top/vm/YOHgMtK.aspx (Chinese)
- **Radar Journal**: https://radars.ac.cn/web/data/getData?dataType=GDHuiYan-ATRNet
- **Science Data Bank**: https://www.scidb.cn/detail?dataSetId=d9ea44937cb94fba9befe9cdb15ffeed

### What to Download

For object detection with DiffDet4SAR, you need:
1. **Ground-range 8-bit amplitude data** (processed images - recommended for detection)
2. **COCO annotations** (included with the data)

The dataset is organized by experimental setting. For initial training, download **SOC-40** (Standard Operating Conditions with 40 classes):
- `SOC-40_train.zip` - Training set (~68,000 images)
- `SOC-40_test.zip` - Test set (~29,000 images)
- `annotations_coco_format.zip` - COCO format annotations

## Step 2: Extract and Organize Dataset

Once downloaded, extract and organize the dataset:

```bash
cd /media/alexandre/E6AE9051AE901BDD/PIE\ Code/ATR/ATR-Segmentation/DiffDet4SAR

# Create datasets directory
mkdir -p datasets/atrnet_star

# Extract the data (adjust paths according to your download location)
# Example structure after extraction:
# datasets/atrnet_star/
# ├── train/
# │   ├── Buick_Excelle_GT/
# │   ├── Toyota_Corolla/
# │   └── ... (40 vehicle types)
# ├── test/
# │   └── (same structure)
# └── annotations/
#     ├── instances_train.json
#     └── instances_test.json
```

## Step 3: Convert to COCO Format (if not already)

If the COCO annotations aren't included, use the conversion script from ATRNet-STAR:

```bash
cd /media/alexandre/E6AE9051AE901BDD/PIE\ Code/ATR/ATR-Segmentation/ATRNet-STAR

# The repo should include a conversion script
# Run it according to their instructions (check ATRBench or docs)


## Step 4: Update DiffDet4SAR Configuration

Now we need to register the ATRNet-STAR dataset with Detectron2 and update configs.

### Create dataset registration file:

```bash
cd /media/alexandre/E6AE9051AE901BDD/PIE\ Code/ATR/ATR-Segmentation/DiffDet4SAR
```

Create `diffusiondet/data/datasets/register_atrnet.py`:

```python
import os
from detectron2.data.datasets import register_coco_instances

# Register ATRNet-STAR dataset
def register_atrnet_star():
    # Adjust paths to match your actual data location
    dataset_dir = "datasets/atrnet_star"
    
    register_coco_instances(
        "atrnet_star_train",
        {},
        os.path.join(dataset_dir, "annotations/instances_train.json"),
        os.path.join(dataset_dir, "train")
    )
    
    register_coco_instances(
        "atrnet_star_test",
        {},
        os.path.join(dataset_dir, "annotations/instances_test.json"),
        os.path.join(dataset_dir, "test")
    )

# Auto-register on import
register_atrnet_star()
```

### Update `diffusiondet/__init__.py`:

Add this line to automatically register the dataset:
```python
from .data.datasets.register_atrnet import register_atrnet_star
```

## Step 5: Create Configuration File for ATRNet-STAR

Create `configs/diffdet.atrnet.res50.yaml`:

```yaml
_BASE_: "Base-DiffusionDet.yaml"
MODEL:
  # Use ImageNet pretrained ResNet-50 (auto-downloaded)
  WEIGHTS: "detectron2://ImageNetPretrained/torchvision/R-50.pkl"
  RESNETS:
    DEPTH: 50
    STRIDE_IN_1X1: False
  DiffusionDet:
    NUM_PROPOSALS: 500
    NUM_CLASSES: 40  # ATRNet-STAR has 40 vehicle types
DATASETS:
  TRAIN: ("atrnet_star_train",)
  TEST: ("atrnet_star_test",)
SOLVER:
  IMS_PER_BATCH: 4  # Adjust based on your GPU memory (RTX 3070 Laptop)
  BASE_LR: 0.000025  # Standard learning rate
  STEPS: (60000, 80000)  # Decay at 60k and 80k iterations
  MAX_ITER: 90000  # ~90k iterations for large dataset
  WARMUP_FACTOR: 0.001
  WARMUP_ITERS: 1000
  WEIGHT_DECAY: 0.0001
  OPTIMIZER: "ADAMW"
  CHECKPOINT_PERIOD: 5000  # Save checkpoint every 5000 iterations
INPUT:
  MIN_SIZE_TRAIN: (800, 1000, 1200)  # Multi-scale training
  MIN_SIZE_TEST: 800
  CROP:
    ENABLED: False
  FORMAT: "RGB"
TEST:
  EVAL_PERIOD: 5000  # Evaluate every 5000 iterations
DATALOADER:
  NUM_WORKERS: 4
  FILTER_EMPTY_ANNOTATIONS: True
OUTPUT_DIR: "./output_atrnet_star"
```

## Step 6: Install OpenCV (if not done yet)

```bash
conda activate torch-env
pip install opencv-python
```

## Step 7: Start Training

### Single GPU Training:
```bash
cd /media/alexandre/E6AE9051AE901BDD/PIE\ Code/ATR/ATR-Segmentation/DiffDet4SAR
conda activate torch-env

python train_net.py --num-gpus 1 \
    --config-file configs/diffdet.atrnet.res50.yaml
```

### Resume Training (if interrupted):
```bash
python train_net.py --num-gpus 1 \
    --config-file configs/diffdet.atrnet.res50.yaml \
    --resume
```

### Monitor Training:
```bash
# In another terminal
tensorboard --logdir output_atrnet_star/ --port 6006
# Open http://localhost:6006 in browser
```

## Step 8: Evaluation

After training completes:
```bash
python train_net.py --num-gpus 1 \
    --config-file configs/diffdet.atrnet.res50.yaml \
    --eval-only MODEL.WEIGHTS output_atrnet_star/model_final.pth
```

## Step 9: Inference on New Images

```bash
python demo.py --config-file configs/diffdet.atrnet.res50.yaml \
    --input /path/to/sar/image.tif \
    --opts MODEL.WEIGHTS output_atrnet_star/model_final.pth \
    --output ./demo_output/
```

## Expected Training Time

- **Dataset size**: ~68,000 training images
- **GPU**: RTX 3070 Laptop (8GB)
- **Batch size**: 4 images per iteration
- **Iterations**: 90,000
- **Estimated time**: ~24-36 hours

## Troubleshooting

### Issue: Out of GPU Memory
**Solution**: Reduce batch size in config:
```yaml
SOLVER:
  IMS_PER_BATCH: 2  # or even 1
```

### Issue: Dataset not found
**Solution**: Check paths in `register_atrnet.py` match your actual data location.

### Issue: Slow training
**Solution**: 
- Reduce `NUM_WORKERS` if CPU is bottleneck
- Use smaller input size: `MIN_SIZE_TRAIN: (640, 800)`
- Start with fewer iterations for testing: `MAX_ITER: 10000`

### Issue: Different image format
**Solution**: If ATRNet-STAR uses .tif files but model expects .jpg:
- Check the COCO annotation file paths
- Detectron2 should handle .tif automatically
- If not, convert: `mogrify -format jpg *.tif`

## Comparison with SAR-AIRcraft1.0

| Dataset | Classes | Images | Resolution | Scenes |
|---------|---------|--------|------------|--------|
| SAR-AIRcraft1.0 | 7 aircraft | ~few thousand | - | Limited |
| ATRNet-STAR (SOC-40) | 40 vehicles | ~97,000 | 0.12-0.15m | 5 diverse scenes |

ATRNet-STAR is much larger and more diverse, making it ideal for training robust detection models!

## Next Steps After Training

1. ✅ Evaluate on test set
2. ✅ Test on EOC settings (domain shift scenarios)
3. ✅ Fine-tune hyperparameters
4. ✅ Try different backbones (ResNet-101, Swin Transformer)
5. ✅ Deploy for real-world SAR imagery

## Quick Start (if you have data ready)

If you've already downloaded and extracted ATRNet-STAR:

```bash
cd /media/alexandre/E6AE9051AE901BDD/PIE\ Code/ATR/ATR-Segmentation/DiffDet4SAR
conda activate torch-env

# Create the registration file (I'll help with this)
# Create the config file (I'll help with this)

# Start training
python train_net.py --num-gpus 1 --config-file configs/diffdet.atrnet.res50.yaml
```
