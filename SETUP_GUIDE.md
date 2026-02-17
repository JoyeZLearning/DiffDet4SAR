# DiffDet4SAR Setup Guide

## Current Status
✅ PyTorch 2.5.1+cu124 installed in `torch-env` conda environment  
✅ Detectron2 built and installed  
✅ Config paths updated for your system  

## Understanding the Structure

### Two Detectron2 Folders:
1. **`/ATR-Segmentation/detectron2/`** - Standalone Detectron2 (pip package)
2. **`/ATR-Segmentation/DiffDet4SAR/detectron2/`** - Modified version for DiffDet4SAR

When running from `DiffDet4SAR/`, Python uses the **local modified detectron2** folder automatically.

## Steps to Run DiffDet4SAR

### 1. Get the Dataset

You need the **SAR-AIRcraft1.0** dataset (doi: 10.12000/JR23043) in COCO format.

**Option A: If you have the dataset**
```bash
cd /media/alexandre/E6AE9051AE901BDD/PIE\ Code/ATR/ATR-Segmentation/DiffDet4SAR
mkdir -p datasets/coco

# Link your dataset (replace /path/to/your/dataset with actual path)
ln -s /path/to/your/dataset/annotations datasets/coco/annotations
ln -s /path/to/your/dataset/train2017 datasets/coco/train2017  
ln -s /path/to/your/dataset/val2017 datasets/coco/val2017
```

**Option B: If you need to download**
- Check the paper: doi: 10.12000/JR23043
- Download SAR-AIRcraft1.0 dataset
- Convert to COCO format (or the authors may have already done this)

**Dataset Structure Should Be:**
```
DiffDet4SAR/datasets/coco/
├── annotations/
│   ├── instances_train2017.json
│   └── instances_val2017.json
├── train2017/
│   └── *.jpg or *.png (training images)
└── val2017/
    └── *.jpg or *.png (validation images)
```

### 2. Training from Scratch

The config is already set to use ImageNet pretrained ResNet-50 (auto-downloaded by Detectron2).

**For single GPU:**
```bash
cd /media/alexandre/E6AE9051AE901BDD/PIE\ Code/ATR/ATR-Segmentation/DiffDet4SAR
conda activate torch-env

python train_net.py --num-gpus 1 \
    --config-file configs/diffdet.coco.res50.300boxes.yaml
```

**Key Settings (already in config):**
- NUM_CLASSES: 7 (for SAR aircraft dataset)
- NUM_PROPOSALS: 500
- IMS_PER_BATCH: 4 (adjust based on your GPU memory)
- MAX_ITER: 5000 (quick test - increase for full training)

### 3. Resume Training

If training is interrupted:
```bash
python train_net.py --num-gpus 1 \
    --config-file configs/diffdet.coco.res50.300boxes.yaml \
    --resume
```

### 4. Evaluation

After training, evaluate your model:
```bash
python train_net.py --num-gpus 1 \
    --config-file configs/diffdet.coco.res50.300boxes.yaml \
    --eval-only MODEL.WEIGHTS output/model_final.pth
```

### 5. Demo/Inference on Single Image

```bash
python demo.py --config-file configs/diffdet.coco.res50.300boxes.yaml \
    --input /path/to/your/image.jpg \
    --opts MODEL.WEIGHTS output/model_final.pth
```

## Troubleshooting

### Issue: "No module named detectron2"
**Solution:** Make sure you're in torch-env:
```bash
conda activate torch-env
```

### Issue: "Dataset not found"
**Solution:** Check that datasets/coco/ exists with proper structure and annotations.

### Issue: Out of GPU memory
**Solution:** Reduce batch size in config:
- Edit `configs/diffdet.coco.res50.300boxes.yaml` or `Base-DiffusionDet.yaml`
- Change `IMS_PER_BATCH: 4` to `IMS_PER_BATCH: 2` or `1`

### Issue: Different number of classes
**Solution:** The config is set for 7 classes (SAR aircraft). If your dataset has different number:
- Edit `configs/diffdet.coco.res50.300boxes.yaml`
- Change `NUM_CLASSES: 7` to match your dataset

## Config Files Explained

- **Base-DiffusionDet.yaml**: Base configuration with model architecture, solver settings
- **diffdet.coco.res50.300boxes.yaml**: Specific config inheriting from base, sets 7 classes for SAR
- **diffdet.coco.res50.yaml**: Alternative config with 80 classes (original COCO)

## Output Structure

Training will create:
```
DiffDet4SAR/output/
├── metrics.json          # Training metrics
├── model_final.pth       # Final trained model
├── model_0004999.pth     # Checkpoint at iter 4999
└── events.out.tfevents.* # TensorBoard logs
```

## Monitoring Training

View training progress with TensorBoard:
```bash
tensorboard --logdir output/ --port 6006
```

Then open http://localhost:6006 in your browser.

## Key Differences from Standard COCO

1. **NUM_CLASSES: 7** instead of 80 (SAR aircraft types)
2. **PIXEL_MEAN and PIXEL_STD** adjusted for SAR imagery
3. **Smaller MAX_ITER** (5000 for quick test, increase for production)
4. **Input size** optimized for SAR images

## Next Steps

1. ✅ Verify dataset is in correct location
2. ✅ Check dataset format matches COCO structure  
3. ✅ Run training with 1 GPU
4. ✅ Monitor training progress
5. ✅ Evaluate on validation set
6. ✅ Run inference on new images
