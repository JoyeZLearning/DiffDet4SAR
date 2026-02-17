#!/usr/bin/env python
"""
Test script to verify ATRNet-STAR dataset registration
This script checks if the dataset is properly registered and accessible.
"""

import sys
import os

# Add DiffDet4SAR to path
sys.path.insert(0, os.path.dirname(__file__))

print("=" * 60)
print("Testing ATRNet-STAR Dataset Registration")
print("=" * 60)

try:
    # Import required modules
    print("\n1. Importing detectron2 modules...")
    from detectron2.data import DatasetCatalog, MetadataCatalog
    print("   ✓ Successfully imported detectron2")
    
    # Register the dataset
    print("\n2. Registering ATRNet-STAR dataset...")
    import diffusiondet.register_atrnet
    print("   ✓ Dataset registration module loaded")
    
    # Check if datasets are registered
    print("\n3. Checking registered datasets...")
    available_datasets = list(DatasetCatalog.keys())
    
    atrnet_train_found = "atrnet_star_train" in available_datasets
    atrnet_test_found = "atrnet_star_test" in available_datasets
    
    if atrnet_train_found:
        print("   ✓ atrnet_star_train is registered")
    else:
        print("   ✗ atrnet_star_train NOT found")
        
    if atrnet_test_found:
        print("   ✓ atrnet_star_test is registered")
    else:
        print("   ✗ atrnet_star_test NOT found")
    
    # Get dataset info
    if atrnet_train_found:
        print("\n4. Getting training dataset info...")
        try:
            train_data = DatasetCatalog.get("atrnet_star_train")
            print(f"   ✓ Training set loaded: {len(train_data)} images")
            
            # Show sample info
            if len(train_data) > 0:
                sample = train_data[0]
                print(f"\n5. Sample image info:")
                print(f"   - File: {sample.get('file_name', 'N/A')}")
                print(f"   - Height: {sample.get('height', 'N/A')}")
                print(f"   - Width: {sample.get('width', 'N/A')}")
                print(f"   - Annotations: {len(sample.get('annotations', []))}")
                if len(sample.get('annotations', [])) > 0:
                    ann = sample['annotations'][0]
                    print(f"   - Sample annotation category: {ann.get('category_id', 'N/A')}")
        except Exception as e:
            print(f"   ✗ Error loading training data: {e}")
    
    if atrnet_test_found:
        print("\n6. Getting test dataset info...")
        try:
            test_data = DatasetCatalog.get("atrnet_star_test")
            print(f"   ✓ Test set loaded: {len(test_data)} images")
        except Exception as e:
            print(f"   ✗ Error loading test data: {e}")
    
    print("\n" + "=" * 60)
    if atrnet_train_found and atrnet_test_found:
        print("SUCCESS: Dataset is properly registered!")
        print("You can now start training with:")
        print("  ./train_atrnet.sh")
        print("or")
        print("  python train_net.py --num-gpus 1 --config-file configs/diffdet.atrnet.res50.yaml")
    else:
        print("ERROR: Dataset registration failed!")
        print("Please check the paths in diffusiondet/register_atrnet.py")
    print("=" * 60)
    
except ImportError as e:
    print(f"\n✗ Import error: {e}")
    print("\nPlease make sure:")
    print("  1. You are in the torch-env conda environment")
    print("  2. Detectron2 is properly installed")
    print("  3. All dependencies are available")
    sys.exit(1)
    
except Exception as e:
    print(f"\n✗ Unexpected error: {e}")
    import traceback
    traceback.print_exc()
    sys.exit(1)
