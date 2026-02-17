# Training DiffDet4SAR with ATRNet-STAR Dataset - Setup Summary

## ✅ Completed Steps

1. **Dataset Registration** - Created [diffusiondet/register_atrnet.py](diffusiondet/register_atrnet.py)
   - Registered `atrnet_star_train` (68,091 images)
   - Registered `atrnet_star_test` (29,284 images)
   - Verified dataset loading successfully

2. **Training Configuration** - Created [configs/diffdet.atrnet.res50.yaml](configs/diffdet.atrnet.res50.yaml)
   - Model: DiffusionDet with ResNet-50 backbone
   - 40 vehicle classes (ATRNet-STAR SOC-40)
   - Batch size: 4 (optimized for RTX 3070 Laptop 8GB)
   - Training: 90,000 iterations
   - Learning rate: 0.00001
   - Evaluation every 5,000 iterations
   - Checkpoints every 5,000 iterations

3. **Code Updates**
   - Modified [train_net.py](train_net.py#L318) to enable training mode (disabled eval_only)
   - Imported dataset registration module

4. **Dependencies**
   - ✅ Detectron2 installed
   - ✅ timm (transformers) installed
   - ✅ OpenCV (cv2) installed
   - ✅ All other requirements satisfied

## ⏳ Current Status: Extracting Dataset Images

The ATRNet-STAR dataset images are currently being extracted from the compressed archives:
- Source: `Amplitude 8-bit data_地距幅度8位数据.7z.001/.002/.003` (9.6 GB)
- Target: `ATRNet-STAR-data/Ground_Range/Amplitude_8bit/SOC_40classes/`
- Progress: Extraction in progress (background process PID 26811)
- Log: `ATRNet-STAR-data/Ground_Range/Amplitude_8bit/extraction.log`

Expected images:
- Training: 68,091 images
- Test: 29,284 images

## 📋 Next Steps

Once extraction completes, you can start training using **any of these methods**:

### Method 1: Automatic (Recommended)
```bash
cd /media/alexandre/E6AE9051AE901BDD/PIE\ Code/ATR/ATR-Segmentation/DiffDet4SAR
./monitor_and_train.sh
```
This script monitors extraction progress and automatically starts training when complete.

### Method 2: Manual Training Script
```bash
cd /media/alexandre/E6AE9051AE901BDD/PIE\ Code/ATR/ATR-Segmentation/DiffDet4SAR
./train_atrnet.sh
```

### Method 3: Direct Python Command
```bash
cd /media/alexandre/E6AE9051AE901BDD/PIE\ Code/ATR/ATR-Segmentation/DiffDet4SAR
conda activate torch-env
python train_net.py --num-gpus 1 --config-file configs/diffdet.atrnet.res50.yaml
```

## 📊 Monitor Training Progress

### Check Extraction Status
```bash
cd /media/alexandre/E6AE9051AE901BDD/PIE\ Code/ATR/ATR-Segmentation/ATRNet-STAR-data/Ground_Range/Amplitude_8bit
tail -f extraction.log
```

Count extracted images:
```bash
find SOC_40classes/train -name "*.tif" | wc -l  # Should be 68091 when complete
```

### Monitor Training with TensorBoard
```bash
conda activate torch-env
tensorboard --logdir output_atrnet_star/ --port 6006
```
Then open http://localhost:6006 in your browser

### View Training Logs
```bash
tail -f output_atrnet_star/log.txt
```

## 🔧 Training Configuration Details

- **Dataset**: ATRNet-STAR SOC-40 (Standard Operating Conditions, 40 vehicle classes)
- **Images**: 128x128 pixels, 8-bit SAR amplitude, .tif format
- **Bands**: X-band (10 GHz) and Ku-band (17.5 GHz)
- **Polarizations**: HH, HV, VH, VV
- **Model Architecture**: DiffusionDet (denoising diffusion probabilistic model for object detection)
- **Backbone**: ResNet-50 with FPN (Feature Pyramid Network)
- **Input sizes**: Multi-scale training (800, 1000, 1200 pixels)
- **Output**: `./output_atrnet_star/`
  - Model checkpoints every 5000 iterations
  - TensorBoard logs
  - Training metrics
  - Final model: `model_final.pth`

## 📈 Expected Training Time

- **Total iterations**: 90,000
- **Images per iteration**: 4
- **GPU**: RTX 3070 Laptop (8GB VRAM)
- **Estimated time**: 24-36 hours
- **Progress tracking**: Evaluation every 5,000 iterations (~1.5-2 hours)

## 🎯 Training Checkpoints

The model will be evaluated and saved at:
- 5,000 iterations
- 10,000 iterations
- 15,000 iterations
- ... (every 5,000 iterations)
- 90,000 iterations (final)

## 🔄 Resume Training

If training is interrupted, resume with:
```bash
python train_net.py --num-gpus 1 \
    --config-file configs/diffdet.atrnet.res50.yaml \
    --resume
```

## 🧪 Test/Evaluate After Training

```bash
python train_net.py --num-gpus 1 \
    --config-file configs/diffdet.atrnet.res50.yaml \
    --eval-only MODEL.WEIGHTS output_atrnet_star/model_final.pth
```

## 🖼️ Run Inference on New Images

```bash
python demo.py --config-file configs/diffdet.atrnet.res50.yaml \
    --input /path/to/sar/image.tif \
    --opts MODEL.WEIGHTS output_atrnet_star/model_final.pth \
    --output ./demo_output/
```

## ⚠️ Troubleshooting

### Out of GPU Memory
Reduce batch size in config:
```yaml
SOLVER:
  IMS_PER_BATCH: 2  # or even 1
```

### Training too slow
- Reduce input size: `MIN_SIZE_TRAIN: (640, 800)`
- Reduce workers: `NUM_WORKERS: 2`

### Check GPU usage
```bash
watch -n 1 nvidia-smi
```

## 📁 Files Created

1. [diffusiondet/register_atrnet.py](diffusiondet/register_atrnet.py) - Dataset registration
2. [configs/diffdet.atrnet.res50.yaml](configs/diffdet.atrnet.res50.yaml) - Training config
3. [train_atrnet.sh](train_atrnet.sh) - Training script
4. [test_dataset.py](test_dataset.py) - Dataset verification script
5. [monitor_and_train.sh](monitor_and_train.sh) - Auto-start training when extraction completes
6. This README

## 🎓 About Your Hugging Face Token

Your HF token:
- ✅ Already configured via `huggingface-cli login`
- ⚠️ Keep it private - never commit to git or share in public repos
- 🔒 Use environment variable `HF_TOKEN` for scripts
- 💡 Used to download datasets from private Hugging Face repositories
- 🔄 Can be revoked and regenerated at: https://huggingface.co/settings/tokens

To use in Python scripts:
```python
from datasets import load_dataset
dataset = load_dataset("dataset_name", use_auth_token=True)  # Uses stored token
```

---

**Status**: Ready to train once extraction completes! 🚀
