#!/usr/bin/env python3
"""
collect_data.py - Creates example JSON sample files
"""
import json
import os
import random
from datetime import datetime

def collect_data():
    """Generate example JSON data files"""
    output_dir = "data/raw"
    os.makedirs(output_dir, exist_ok=True)
    
    # Generate 10 example data files
    for i in range(10):
        data = {
            "id": i,
            "timestamp": datetime.now().isoformat(),
            "features": [random.random() for _ in range(10)],
            "label": random.randint(0, 1)
        }
        
        filename = os.path.join(output_dir, f"sample_{i}.json")
        with open(filename, 'w') as f:
            json.dump(data, f, indent=2)
        
        print(f"Created: {filename}")
    
    print(f"\nGenerated {10} sample files in {output_dir}/")

if __name__ == "__main__":
    collect_data()
