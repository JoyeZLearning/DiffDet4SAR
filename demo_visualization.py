#!/usr/bin/env python3
"""
Quick demo - Test visualization on sample images
Shows what the visualization will look like with the current model
"""

import sys
import os
sys.path.insert(0, os.path.dirname(__file__))

import cv2
import numpy as np
import random
from pathlib import Path
import json

# Get category names
def get_categories():
    annotation_file = "/media/alexandre/E6AE9051AE901BDD/PIE Code/ATR/ATR-Segmentation/ATRNet-STAR-data/Ground_Range/annotation_coco/SOC_40classes/annotations/test.json"
    with open(annotation_file, 'r') as f:
        data = json.load(f)
    return {cat['id']: cat['name'] for cat in data['categories']}

# COLORS for visualization (BGR)
COLORS = [
    (255, 0, 0), (0, 255, 0), (0, 0, 255), (255, 255, 0), (255, 0, 255),
    (0, 255, 255), (128, 0, 0), (0, 128, 0), (0, 0, 128), (128, 128, 0),
] * 5

def draw_box_demo(image, categories, num_boxes=5):
    """Draw demo boxes to show what visualizations will look like"""
    height, width = image.shape[:2]
    
    # Convert to BGR
    if len(image.shape) == 2:
        image = cv2.cvtColor(image, cv2.COLOR_GRAY2BGR)
    
    # Generate random boxes
    for i in range(num_boxes):
        # Random box
        x1 = random.randint(10, width - 60)
        y1 = random.randint(10, height - 60)
        w = random.randint(30, min(50, width - x1 - 10))
        h = random.randint(30, min(50, height - y1 - 10))
        x2 = x1 + w
        y2 = y1 + h
        
        # Random class and confidence
        cls_id = random.choice(list(categories.keys()))
        confidence = random.uniform(0.5, 0.95)
        color = COLORS[cls_id % len(COLORS)]
        
        # Draw box
        cv2.rectangle(image, (x1, y1), (x2, y2), color, 2)
        
        # Label
        category_name = categories[cls_id]
        label = f"{category_name}: {confidence:.2f}"
        
        # Label background
        label_size, _ = cv2.getTextSize(label, cv2.FONT_HERSHEY_SIMPLEX, 0.5, 1)
        label_w, label_h = label_size
        label_y1 = max(y1 - label_h - 5, 0)
        label_y2 = label_y1 + label_h + 5
        
        cv2.rectangle(image, (x1, label_y1), (x1 + label_w + 5, label_y2), color, -1)
        cv2.putText(image, label, (x1 + 2, label_y2 - 3), 
                   cv2.FONT_HERSHEY_SIMPLEX, 0.5, (255, 255, 255), 1)
    
    # Title
    title = f"DEMO: Detected {num_boxes} objects (Random for illustration)"
    cv2.putText(image, title, (10, 30), 
               cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 255, 255), 2)
    
    return image

def main():
    print("=" * 70)
    print("DiffDet4SAR Visualization Demo")
    print("=" * 70)
    print()
    print("Creating demo visualizations with random boxes to show")
    print("what your trained model detections will look like!")
    print()
    
    # Load categories
    categories = get_categories()
    print(f"✓ Loaded {len(categories)} vehicle categories")
    
    # Get sample test images
    test_dir = Path("/media/alexandre/E6AE9051AE901BDD/PIE Code/ATR/ATR-Segmentation/ATRNet-STAR-data/Ground_Range/Amplitude_8bit/SOC_40classes/test")
    image_files = list(test_dir.glob("*.tif"))[:10]
    
    print(f"✓ Found {len(image_files)} sample images")
    print()
    
    # Create output directory
    output_dir = Path("./demo_visualizations")
    output_dir.mkdir(exist_ok=True)
    
    # Process images
    for i, image_path in enumerate(image_files, 1):
        print(f"[{i}/{len(image_files)}] Processing: {image_path.name}")
        
        # Read image
        image = cv2.imread(str(image_path), cv2.IMREAD_GRAYSCALE)
        if image is None:
            continue
        
        # Draw demo boxes
        vis_image = draw_box_demo(image, categories, num_boxes=random.randint(2, 6))
        
        # Save
        output_path = output_dir / f"demo_{image_path.stem}.jpg"
        cv2.imwrite(str(output_path), vis_image)
        print(f"  ✓ Saved: {output_path.name}")
    
    print()
    print("=" * 70)
    print("✅ Demo visualizations created!")
    print(f"   Check them out in: {output_dir}")
    print()
    print("These are RANDOM boxes for demonstration.")
    print("Real detections will be created once training checkpoints are available.")
    print()
    print("To create real detections after iteration 5000:")
    print("  python visualize_detections.py --weights output_atrnet_star/model_0004999.pth")
    print("=" * 70)

if __name__ == "__main__":
    main()
