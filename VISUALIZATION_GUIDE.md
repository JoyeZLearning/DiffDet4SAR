# 🎨 Visualization Guide for DiffDet4SAR

## 🎬 Demo Visualizations (Available NOW!)

I've created **demo visualizations** with random bounding boxes to show you what the final output will look like!

**View the demos:**
```bash
cd /media/alexandre/E6AE9051AE901BDD/PIE\ Code/ATR/ATR-Segmentation/DiffDet4SAR/demo_visualizations
# Open any .jpg file to see the visualization style
```

**Demo images show:**
- ✅ Colorful bounding boxes (different color per vehicle class)
- ✅ Vehicle class labels (e.g., "Buick_Excelle_GT")
- ✅ Confidence scores (e.g., 0.85)
- ✅ Detection count overlay
- ✅ Professional visualization style

---

## 🚀 Real Model Testing (After Checkpoints Available)

### When Can I Test?

Training saves checkpoints every **5,000 iterations**:
- ✅ First checkpoint: **Iteration 5,000** (~1.5 hours from start)
- ✅ Second checkpoint: **Iteration 10,000** (~3 hours)
- ✅ And so on...

Current training status: Run this to check progress:
```bash
tail -f training_output.log | grep "iter:"
```

### Option 1: Manual Visualization (One-time)

Test your model immediately after a checkpoint is saved:

```bash
# Activate environment
conda activate torch-env

# Run visualization on 20 random test images
python visualize_detections.py \
    --weights output_atrnet_star/model_0004999.pth \
    --num-samples 20 \
    --confidence-threshold 0.5 \
    --output-dir ./my_visualizations
```

**Parameters:**
- `--weights`: Path to your checkpoint (e.g., `model_0004999.pth`, `model_0009999.pth`, `model_final.pth`)
- `--num-samples`: Number of images to visualize (default: 20)
- `--confidence-threshold`: Minimum detection confidence (0-1, default: 0.3)
- `--output-dir`: Where to save images (default: ./visualizations)
- `--input-dir`: Use specific images instead of random samples

**Example - Test on specific images:**
```bash
python visualize_detections.py \
    --weights output_atrnet_star/model_0004999.pth \
    --input-dir /path/to/your/sar/images \
    --confidence-threshold 0.7
```

### Option 2: Automatic Monitoring (Continuous)

Automatically create visualizations whenever a new checkpoint is saved:

```bash
# In a separate terminal
./monitor_and_visualize.sh
```

This script will:
- 🔍 Monitor for new checkpoints
- 🎨 Automatically run visualization on each new checkpoint
- 📊 Show live training progress
- 💾 Save results to `visualizations_iter_XXXX/`

### Option 3: Best Model Visualization

After training completes (90,000 iterations), test the final model:

```bash
python visualize_detections.py \
    --weights output_atrnet_star/model_final.pth \
    --num-samples 50 \
    --confidence-threshold 0.7 \
    --output-dir ./final_results
```

---

## 📊 Understanding the Visualizations

### What You'll See:

1. **Bounding Boxes**: Colored rectangles around detected vehicles
2. **Class Labels**: Vehicle type (40 classes like "Toyota_Corolla", "Buick_GL8", etc.)
3. **Confidence Scores**: How confident the model is (0.00 to 1.00)
4. **Detection Count**: Total objects found in the image

### Visualization Colors:

Each of the 40 vehicle classes gets a unique color:
- 🔴 Red, 🟢 Green, 🔵 Blue, 🟡 Yellow, 🟣 Purple, 🔶 Orange, etc.

### File Naming:

Output files are named: `detected_ORIGINALNAME.jpg`

Example:
- Input: `KU_HH_15_0_107287.tif`
- Output: `detected_KU_HH_15_0_107287.jpg`

---

## 🎯 Advanced Usage

### Test Different Confidence Thresholds

Compare results with different confidence levels:

```bash
# Conservative (fewer but more confident detections)
python visualize_detections.py --weights output_atrnet_star/model_final.pth \
    --confidence-threshold 0.8 --output-dir ./results_conf_0.8

# Moderate (balanced)
python visualize_detections.py --weights output_atrnet_star/model_final.pth \
    --confidence-threshold 0.5 --output-dir ./results_conf_0.5

# Aggressive (more detections, some false positives)
python visualize_detections.py --weights output_atrnet_star/model_final.pth \
    --confidence-threshold 0.3 --output-dir ./results_conf_0.3
```

### Test on Custom SAR Images

Have your own SAR images? Test them:

```bash
python visualize_detections.py \
    --weights output_atrnet_star/model_final.pth \
    --input-dir /path/to/your/sar/images \
    --output-dir ./custom_results
```

Supported formats: `.tif`, `.jpg`, `.png`

### Batch Processing

Process large batches efficiently:

```bash
# Process 100 test images
python visualize_detections.py \
    --weights output_atrnet_star/model_final.pth \
    --num-samples 100 \
    --output-dir ./batch_results
```

---

## 📈 Compare Model Performance Over Training

Visualize how detection quality improves:

```bash
# Early checkpoint (iteration 5,000)
python visualize_detections.py \
    --weights output_atrnet_star/model_0004999.pth \
    --num-samples 10 --output-dir ./compare/iter_5k

# Middle checkpoint (iteration 45,000)
python visualize_detections.py \
    --weights output_atrnet_star/model_0044999.pth \
    --num-samples 10 --output-dir ./compare/iter_45k

# Final model
python visualize_detections.py \
    --weights output_atrnet_star/model_final.pth \
    --num-samples 10 --output-dir ./compare/final
```

Then visually compare the same images across different training stages!

---

## 🔧 Troubleshooting

### "No checkpoints found"
- Wait for training to reach 5,000 iterations
- Check: `ls output_atrnet_star/*.pth`

### "Out of memory" during visualization
- Reduce `--num-samples`
- Process images one at a time

### "Could not read image"
- Check image format (must be .tif, .jpg, or .png)
- Verify file path

### Low detection quality early in training
- Normal! Model improves over time
- Wait for more iterations (best results after 50k-90k)

---

## 📸 Example Output

Each visualization includes:

```
[Image with colored bounding boxes]

┌─────────────────────────────┐
│ Detected: 3 objects         │ ← Count overlay
├─────────────────────────────┤
│ ┌─────────────────┐        │
│ │ Toyota_Corolla: │0.92    │ ← Label + confidence
│ │    [Box]        │        │ ← Bounding box
│ └─────────────────┘        │
│                             │
│ ┌─────────────┐            │
│ │ Buick_GL8:  │0.87        │
│ │   [Box]     │            │
│ └─────────────┘            │
│                             │
│ ┌──────────────┐           │
│ │ FAW_J6P:     │0.78        │
│ │   [Box]      │            │
│ └──────────────┘           │
└─────────────────────────────┘
```

---

## 🎊 Quick Start Summary

**Right now (Demo):**
```bash
python demo_visualization.py
# View: demo_visualizations/*.jpg
```

**After 1.5 hours (First real checkpoint):**
```bash
python visualize_detections.py \
    --weights output_atrnet_star/model_0004999.pth
# View: visualizations/*.jpg
```

**Automatic (Set and forget):**
```bash
./monitor_and_visualize.sh
# Automatically creates visualizations as training progresses
```

---

## 🌟 Cool Features

- ✨ **Multi-color boxes** - Each class has unique color
- 📊 **Confidence scores** - See how certain the model is
- 🎯 **Adjustable threshold** - Filter by confidence
- 🖼️ **High-quality output** - Full resolution JPEGs
- 📁 **Batch processing** - Handle hundreds of images
- 🔄 **Auto-monitoring** - Automatic visualization on new checkpoints

---

Enjoy testing your model! 🚀🎉
