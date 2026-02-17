"""
ATRNet-STAR Dataset Registration for DiffusionDet

This file registers the ATRNet-STAR dataset with Detectron2.
The dataset contains 40 vehicle classes from SAR imagery.

Supports both local and PANDO supercomputer layouts:
  - Local:  .../ATR-Segmentation/DiffDet4SAR/  +  .../ATR-Segmentation/ATRNet-STAR-data/
  - PANDO:  ~/DiffDet4SAR-project/DiffDet4SAR/ +  ~/DiffDet4SAR-project/ATRNet-STAR-data/

Override with env var ATRNET_DATA_DIR if needed.
"""

import os
from detectron2.data.datasets import register_coco_instances


def register_atrnet_star():
    """
    Register ATRNet-STAR dataset (SOC-40 classes)
    
    The dataset is organized as:
    - Train images: ../ATRNet-STAR-data/Ground_Range/Amplitude_8bit/SOC_40classes/train/
    - Test images: ../ATRNet-STAR-data/Ground_Range/Amplitude_8bit/SOC_40classes/test/
    - Annotations: ../ATRNet-STAR-data/Ground_Range/annotation_coco/SOC_40classes/annotations/
    """
    
    # Allow override via environment variable
    env_data_dir = os.environ.get("ATRNET_DATA_DIR")
    if env_data_dir:
        base_path = os.path.abspath(env_data_dir)
    else:
        # Default: ATRNet-STAR-data is a sibling of the DiffDet4SAR folder
        base_path = os.path.join(os.path.dirname(__file__), "..", "..", "ATRNet-STAR-data")
        base_path = os.path.abspath(base_path)
    
    # Paths to images
    train_image_dir = os.path.join(base_path, "Ground_Range", "Amplitude_8bit", "SOC_40classes", "train")
    test_image_dir = os.path.join(base_path, "Ground_Range", "Amplitude_8bit", "SOC_40classes", "test")
    
    # Paths to annotations
    annotation_dir = os.path.join(base_path, "Ground_Range", "annotation_coco", "SOC_40classes", "annotations")
    train_json = os.path.join(annotation_dir, "train.json")
    test_json = os.path.join(annotation_dir, "test.json")
    
    # Register training set
    register_coco_instances(
        "atrnet_star_train",
        {},
        train_json,
        train_image_dir
    )
    
    # Register test set
    register_coco_instances(
        "atrnet_star_test",
        {},
        test_json,
        test_image_dir
    )
    
    print(f"✓ Registered ATRNet-STAR dataset")
    print(f"  - Train images: {train_image_dir}")
    print(f"  - Test images: {test_image_dir}")
    print(f"  - Train annotations: {train_json}")
    print(f"  - Test annotations: {test_json}")


# Auto-register on import
register_atrnet_star()
