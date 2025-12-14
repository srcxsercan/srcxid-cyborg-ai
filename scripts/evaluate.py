#!/usr/bin/env python3
"""
evaluate.py - Evaluates the saved model and updates metrics
"""
import json
import os
import pandas as pd
import torch
import torch.nn as nn
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from datetime import datetime

class SimpleModel(nn.Module):
    def __init__(self, input_size):
        super(SimpleModel, self).__init__()
        self.fc1 = nn.Linear(input_size, 64)
        self.fc2 = nn.Linear(64, 32)
        self.fc3 = nn.Linear(32, 2)
        self.relu = nn.ReLU()
    
    def forward(self, x):
        x = self.relu(self.fc1(x))
        x = self.relu(self.fc2(x))
        x = self.fc3(x)
        return x

def evaluate_model():
    """Evaluate the saved model"""
    # Check if model exists
    model_path = "models/model.pth"
    if not os.path.exists(model_path):
        print(f"Error: {model_path} not found. Train a model first.")
        return
    
    # Load data
    data_path = "data/processed/dataset.csv"
    if not os.path.exists(data_path):
        print(f"Error: {data_path} not found.")
        return
    
    df = pd.read_csv(data_path)
    X = df.drop(["id", "label"], axis=1).values
    y = df["label"].values
    
    # Split data (same split as training)
    _, X_test, _, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
    
    # Load model checkpoint
    checkpoint = torch.load(model_path)
    
    # Normalize using saved scaler parameters
    scaler = StandardScaler()
    scaler.mean_ = torch.tensor(checkpoint['scaler_mean']).numpy()
    scaler.scale_ = torch.tensor(checkpoint['scaler_scale']).numpy()
    X_test = scaler.transform(X_test)
    
    # Convert to tensors
    X_test_t = torch.FloatTensor(X_test)
    y_test_t = torch.LongTensor(y_test)
    
    # Load model
    model = SimpleModel(checkpoint['input_size'])
    model.load_state_dict(checkpoint['model_state_dict'])
    model.eval()
    
    # Evaluate
    with torch.no_grad():
        outputs = model(X_test_t)
        _, predicted = torch.max(outputs.data, 1)
        accuracy = (predicted == y_test_t).sum().item() / len(y_test_t)
    
    print(f"Model Accuracy: {accuracy:.4f}")
    
    # Update metrics
    metrics = {
        "accuracy": accuracy,
        "timestamp": datetime.now().isoformat(),
        "samples_evaluated": len(X_test)
    }
    
    metrics_path = "models/metrics.json"
    with open(metrics_path, 'w') as f:
        json.dump(metrics, f, indent=2)
    print(f"Metrics updated: {metrics_path}")

if __name__ == "__main__":
    evaluate_model()
