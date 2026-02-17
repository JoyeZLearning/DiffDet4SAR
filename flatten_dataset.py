#!/usr/bin/env python3
"""
Flatten the ATRNet-STAR directory structure to match COCO annotations
Moves all images from class subdirectories to the parent train/test directories
"""

import os
import shutil
from pathlib import Path
from tqdm import tqdm

def flatten_directory(base_dir):
    """Move all .tif files from subdirectories to the parent directory"""
    base_path = Path(base_dir)
    
    # Find all .tif files in subdirectories
    tif_files = list(base_path.glob("*/*.tif"))
    
    print(f"Found {len(tif_files)} images to move in {base_dir}")
    
    if len(tif_files) == 0:
        print(f"No files to move! Checking if already flat...")
        flat_files = list(base_path.glob("*.tif"))
        print(f"Files already in root: {len(flat_files)}")
        return len(flat_files)
    
    # Move files
    moved = 0
    for tif_file in tqdm(tif_files, desc=f"Flattening {base_path.name}"):
        dest = base_path / tif_file.name
        
        # Handle duplicate filenames (shouldn't happen but just in case)
        if dest.exists():
            print(f"Warning: {dest.name} already exists, skipping...")
            continue
            
        try:
            shutil.move(str(tif_file), str(dest))
            moved += 1
        except Exception as e:
            print(f"Error moving {tif_file}: {e}")
    
    print(f"Moved {moved} files")
    
    # Remove empty subdirectories
    print("Removing empty subdirectories...")
    for subdir in base_path.iterdir():
        if subdir.is_dir():
            try:
                subdir.rmdir()  # Only removes if empty
                print(f"  Removed: {subdir.name}")
            except OSError:
                print(f"  Not empty or error: {subdir.name}")
    
    # Verify
    final_count = len(list(base_path.glob("*.tif")))
    print(f"Final count: {final_count} images in {base_dir}")
    return final_count

if __name__ == "__main__":
    import sys
    
    base = "/media/alexandre/E6AE9051AE901BDD/PIE Code/ATR/ATR-Segmentation/ATRNet-STAR-data/Ground_Range/Amplitude_8bit/SOC_40classes"
    
    print("=" * 60)
    print("Flattening ATRNet-STAR directory structure")
    print("=" * 60)
    print()
    
    # Flatten train directory
    print("Processing training set...")
    train_count = flatten_directory(os.path.join(base, "train"))
    print()
    
    # Flatten test directory
    print("Processing test set...")
    test_count = flatten_directory(os.path.join(base, "test"))
    print()
    
    print("=" * 60)
    print("Summary:")
    print(f"  Training images: {train_count}")
    print(f"  Test images: {test_count}")
    print("  Structure is now flat and ready for training!")
    print("=" * 60)
