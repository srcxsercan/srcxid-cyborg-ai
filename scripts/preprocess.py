#!/usr/bin/env python3
"""
preprocess.py - Collects JSON files and converts them into CSV
"""
import json
import os
import pandas as pd
import glob

def preprocess_data():
    """Load JSON files and create a CSV dataset"""
    raw_dir = "data/raw"
    processed_dir = "data/processed"
    os.makedirs(processed_dir, exist_ok=True)
    
    # Find all JSON files
    json_files = glob.glob(os.path.join(raw_dir, "*.json"))
    
    if not json_files:
        print(f"No JSON files found in {raw_dir}")
        return
    
    # Load all data
    all_data = []
    for json_file in json_files:
        with open(json_file, 'r') as f:
            data = json.load(f)
            # Flatten features into separate columns
            row = {"id": data["id"], "label": data["label"]}
            for i, feat in enumerate(data["features"]):
                row[f"feature_{i}"] = feat
            all_data.append(row)
    
    # Create DataFrame and save
    df = pd.DataFrame(all_data)
    output_file = os.path.join(processed_dir, "dataset.csv")
    df.to_csv(output_file, index=False)
    
    print(f"Processed {len(all_data)} samples")
    print(f"Saved to: {output_file}")
    print(f"Shape: {df.shape}")

if __name__ == "__main__":
    preprocess_data()
