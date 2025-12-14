#!/usr/bin/env python3
"""
auto_retrain.py - Checks latest model metrics and retrains if accuracy < 0.8
"""
import json
import os
import subprocess

def auto_retrain():
    """Check metrics and retrain if needed"""
    metrics_path = "models/metrics.json"
    
    # Check if metrics exist
    if not os.path.exists(metrics_path):
        print("No metrics found. Training new model...")
        subprocess.run(["python", "scripts/train.py"], check=True)
        return
    
    # Load metrics
    with open(metrics_path, 'r') as f:
        metrics = json.load(f)
    
    accuracy = metrics.get("accuracy", 0.0)
    print(f"Current accuracy: {accuracy:.4f}")
    
    # Retrain if accuracy below threshold
    threshold = 0.8
    if accuracy < threshold:
        print(f"Accuracy below threshold ({threshold}). Retraining...")
        subprocess.run(["python", "scripts/train.py"], check=True)
        print("Retraining complete.")
    else:
        print(f"Accuracy above threshold ({threshold}). No retraining needed.")

if __name__ == "__main__":
    auto_retrain()
