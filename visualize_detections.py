#!/usr/bin/env python3
"""
Visualize DiffDet4SAR Detections on ATRNet-STAR Images
Creates beautiful visualizations with bounding boxes, labels, and confidence scores
"""

import argparse
import os
import json
import sys
import numpy as np
import cv2
from pathlib import Path
import random
import matplotlib.pyplot as plt
import matplotlib.patches as patches
from detectron2.config import get_cfg
from detectron2.data import MetadataCatalog, DatasetCatalog
from detectron2.engine import DefaultPredictor
from detectron2.utils.visualizer import Visualizer, ColorMode
from detectron2.checkpoint import DetectionCheckpointer

# Add DiffDet4SAR to path
sys.path.insert(0, os.path.dirname(__file__))
from diffusiondet import add_diffusiondet_config
from diffusiondet.util.model_ema import add_model_ema_configs
import diffusiondet.register_atrnet

# COLORS for visualization (BGR for OpenCV)
COLORS = [
    (255, 0, 0), (0, 255, 0), (0, 0, 255), (255, 255, 0), (255, 0, 255),
    (0, 255, 255), (128, 0, 0), (0, 128, 0), (0, 0, 128), (128, 128, 0),
    (128, 0, 128), (0, 128, 128), (255, 128, 0), (255, 0, 128), (128, 255, 0),
    (0, 255, 128), (128, 0, 255), (0, 128, 255), (255, 255, 128), (255, 128, 255),
] * 3  # Repeat to have enough colors

def setup_cfg(args):
    """Setup config and add DiffusionDet config"""
    cfg = get_cfg()
    add_diffusiondet_config(cfg)
    add_model_ema_configs(cfg)
    cfg.merge_from_file(args.config_file)
    cfg.merge_from_list(args.opts)
    
    # Set model weights
    if args.weights:
        cfg.MODEL.WEIGHTS = args.weights
    
    # Set inference threshold
    cfg.MODEL.ROI_HEADS.SCORE_THRESH_TEST = args.confidence_threshold
    cfg.MODEL.DiffusionDet.SAMPLE_STEP = 4  # Faster inference
    
    cfg.freeze()
    return cfg

def get_category_names():
    """Get ATRNet-STAR category names"""
    annotation_file = "/media/alexandre/E6AE9051AE901BDD/PIE Code/ATR/ATR-Segmentation/ATRNet-STAR-data/Ground_Range/annotation_coco/SOC_40classes/annotations/train.json"
    
    with open(annotation_file, 'r') as f:
        data = json.load(f)
    
    categories = {cat['id']: cat['name'] for cat in data['categories']}
    return categories

def draw_predictions(image, outputs, categories, confidence_threshold=0.3):
    """
    Draw bounding boxes and labels on image
    """
    height, width = image.shape[:2]
    
    # Convert grayscale to RGB for colorful boxes
    if len(image.shape) == 2:
        image = cv2.cvtColor(image, cv2.COLOR_GRAY2BGR)
    elif image.shape[2] == 1:
        image = cv2.cvtColor(image, cv2.COLOR_GRAY2BGR)
    
    instances = outputs["instances"].to("cpu")
    boxes = instances.pred_boxes.tensor.numpy()
    scores = instances.scores.numpy()
    classes = instances.pred_classes.numpy()
    
    # Filter by confidence
    keep = scores > confidence_threshold
    boxes = boxes[keep]
    scores = scores[keep]
    classes = classes[keep]
    
    num_detections = len(boxes)
    
    # Draw each detection
    for i, (box, score, cls_id) in enumerate(zip(boxes, scores, classes)):
        x1, y1, x2, y2 = box.astype(int)
        
        # Get color for this class
        color = COLORS[int(cls_id) % len(COLORS)]
        
        # Draw bounding box
        cv2.rectangle(image, (x1, y1), (x2, y2), color, 2)
        
        # Get category name
        category_name = categories.get(int(cls_id) + 1, f"Class_{cls_id}")  # +1 because COCO IDs are 1-indexed
        
        # Create label
        label = f"{category_name}: {score:.2f}"
        
        # Draw label background
        label_size, _ = cv2.getTextSize(label, cv2.FONT_HERSHEY_SIMPLEX, 0.5, 1)
        label_w, label_h = label_size
        
        # Ensure label is within image bounds
        label_y1 = max(y1 - label_h - 5, 0)
        label_y2 = label_y1 + label_h + 5
        
        cv2.rectangle(image, (x1, label_y1), (x1 + label_w + 5, label_y2), color, -1)
        
        # Draw label text
        cv2.putText(image, label, (x1 + 2, label_y2 - 3), 
                   cv2.FONT_HERSHEY_SIMPLEX, 0.5, (255, 255, 255), 1)
    
    # Add detection count at top
    count_text = f"Detected: {num_detections} objects"
    cv2.putText(image, count_text, (10, 30), 
               cv2.FONT_HERSHEY_SIMPLEX, 1, (0, 255, 0), 2)
    
    return image, num_detections

def display_images_grid(images_data, cols=3):
    """
    Display images in a grid using matplotlib
    
    Args:
        images_data: List of tuples (image, filename, num_detections)
        cols: Number of columns in the grid
    """
    n_images = len(images_data)
    rows = (n_images + cols - 1) // cols
    
    fig, axes = plt.subplots(rows, cols, figsize=(5*cols, 5*rows))
    fig.suptitle('DiffDet4SAR Detections on ATRNet-STAR', fontsize=16, fontweight='bold')
    
    if n_images == 1:
        axes = [axes]
    else:
        axes = axes.flatten() if rows > 1 else [axes] if cols == 1 else axes
    
    for idx, (image, filename, num_det) in enumerate(images_data):
        ax = axes[idx]
        
        # Convert BGR to RGB for matplotlib
        image_rgb = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
        
        ax.imshow(image_rgb)
        ax.set_title(f"{filename}\n{num_det} objects detected", fontsize=10)
        ax.axis('off')
    
    # Hide unused subplots
    for idx in range(n_images, len(axes)):
        axes[idx].axis('off')
    
    plt.tight_layout()
    plt.show()

def visualize_samples(args):
    """Run inference and create visualizations"""
    print("=" * 70)
    print("DiffDet4SAR Visualization on ATRNet-STAR")
    print("=" * 70)
    
    # Setup config
    cfg = setup_cfg(args)
    
    # Load category names
    categories = get_category_names()
    print(f"✓ Loaded {len(categories)} categories")
    
    # Create predictor
    print(f"✓ Loading model from: {cfg.MODEL.WEIGHTS}")
    predictor = DefaultPredictor(cfg)
    print(f"✓ Model loaded successfully!")
    
    # Get sample images
    if args.input_dir:
        # Use specified directory
        input_path = Path(args.input_dir)
        image_files = list(input_path.glob("*.tif")) + list(input_path.glob("*.jpg")) + list(input_path.glob("*.png"))
    else:
        # Use random samples from test set
        test_data = DatasetCatalog.get("atrnet_star_test")
        sample_indices = random.sample(range(len(test_data)), min(args.num_samples, len(test_data)))
        image_files = [test_data[i]["file_name"] for i in sample_indices]
    
    if not image_files:
        print("❌ No images found!")
        return
    
    # Limit number of samples
    image_files = image_files[:args.num_samples]
    print(f"✓ Processing {len(image_files)} images")
    print()
    
    # Create output directory
    output_dir = Path(args.output_dir)
    output_dir.mkdir(exist_ok=True, parents=True)
    
    # Store images for display if needed
    images_to_display = []
    
    # Process each image
    total_detections = 0
    for i, image_path in enumerate(image_files, 1):
        image_path = Path(image_path)
        print(f"[{i}/{len(image_files)}] Processing: {image_path.name}")
        
        # Read image
        image = cv2.imread(str(image_path), cv2.IMREAD_GRAYSCALE)
        if image is None:
            print(f"  ⚠ Could not read image, skipping...")
            continue
        
        # Convert to 3-channel for Detectron2
        image_rgb = cv2.cvtColor(image, cv2.COLOR_GRAY2RGB)
        
        # Run inference
        outputs = predictor(image_rgb)
        
        # Draw predictions
        vis_image, num_det = draw_predictions(image, outputs, categories, args.confidence_threshold)
        total_detections += num_det
        
        # Save for display if requested
        if args.show:
            images_to_display.append((vis_image.copy(), image_path.name, num_det))
        
        # Save visualization
        output_path = output_dir / f"detected_{image_path.stem}.jpg"
        cv2.imwrite(str(output_path), vis_image)
        
        print(f"  ✓ Found {num_det} objects | Saved to: {output_path.name}")
    
    print()
    print("=" * 70)
    print(f"✅ Visualization Complete!")
    print(f"   Total detections: {total_detections}")
    print(f"   Output directory: {output_dir}")
    print("=" * 70)
    
    # Display images if requested
    if args.show and images_to_display:
        print()
        print("📊 Displaying images in matplotlib window...")
        print("   (Close the window to exit)")
        display_images_grid(images_to_display, cols=min(3, len(images_to_display)))

def main():
    parser = argparse.ArgumentParser(description="Visualize DiffDet4SAR detections")
    parser.add_argument("--config-file", 
                       default="configs/diffdet.atrnet.res50.yaml",
                       help="Path to config file")
    parser.add_argument("--weights",
                       default=None,
                       help="Path to model weights (.pth file)")
    parser.add_argument("--input-dir",
                       default=None,
                       help="Directory with input images (if not specified, uses random test samples)")
    parser.add_argument("--output-dir",
                       default="./visualizations",
                       help="Directory to save visualizations")
    parser.add_argument("--num-samples",
                       type=int,
                       default=20,
                       help="Number of images to visualize")
    parser.add_argument("--confidence-threshold",
                       type=float,
                       default=0.3,
                       help="Minimum confidence threshold for detections")
    parser.add_argument("--show",
                       action="store_true",
                       help="Display images in matplotlib window (interactive)")
    parser.add_argument("--opts",
                       default=[],
                       nargs=argparse.REMAINDER,
                       help="Modify config options using the command-line")
    
    args = parser.parse_args()
    
    # Check if weights exist
    if args.weights and not os.path.exists(args.weights):
        print(f"❌ Error: Weights file not found: {args.weights}")
        print()
        print("Available options:")
        print("  1. Wait for training checkpoint (first at iteration 5000)")
        print("  2. Use a pretrained model (not trained on ATRNet-STAR)")
        print()
        sys.exit(1)
    
    visualize_samples(args)

if __name__ == "__main__":
    main()
