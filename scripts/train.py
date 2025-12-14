#!/usr/bin/env python3
"""
train.py - Simple PyTorch model training script
"""
import json
import os
import pandas as pd
import torch
import torch.nn as nn
import torch.optim as optim
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

def train_model():
    """Train a simple classification model"""
    # Load data
    data_path = "data/processed/dataset.csv"
    if not os.path.exists(data_path):
        print(f"Error: {data_path} not found. Run preprocess.py first.")
        return
    
    df = pd.read_csv(data_path)
    X = df.drop(["id", "label"], axis=1).values
    y = df["label"].values
    
    # Split data
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
    
    # Normalize
    scaler = StandardScaler()
    X_train = scaler.fit_transform(X_train)
    X_test = scaler.transform(X_test)
    
    # Convert to tensors
    X_train_t = torch.FloatTensor(X_train)
    y_train_t = torch.LongTensor(y_train)
    X_test_t = torch.FloatTensor(X_test)
    y_test_t = torch.LongTensor(y_test)
    
    # Create model
    model = SimpleModel(X_train.shape[1])
    criterion = nn.CrossEntropyLoss()
    optimizer = optim.Adam(model.parameters(), lr=0.001)
    
    # Train
    epochs = 100
    print(f"Training for {epochs} epochs...")
    for epoch in range(epochs):
        model.train()
        optimizer.zero_grad()
        outputs = model(X_train_t)
        loss = criterion(outputs, y_train_t)
        loss.backward()
        optimizer.step()
        
        if (epoch + 1) % 20 == 0:
            print(f"Epoch [{epoch+1}/{epochs}], Loss: {loss.item():.4f}")
    
    # Evaluate
    model.eval()
    with torch.no_grad():
        outputs = model(X_test_t)
        _, predicted = torch.max(outputs.data, 1)
        accuracy = (predicted == y_test_t).sum().item() / len(y_test_t)
    
    print(f"\nTest Accuracy: {accuracy:.4f}")
    
    # Save model
    models_dir = "models"
    os.makedirs(models_dir, exist_ok=True)
    model_path = os.path.join(models_dir, "model.pth")
    torch.save({
        'model_state_dict': model.state_dict(),
        'input_size': X_train.shape[1],
        'scaler_mean': scaler.mean_.tolist(),
        'scaler_scale': scaler.scale_.tolist()
    }, model_path)
    print(f"Model saved to: {model_path}")
    
    # Save metrics
    metrics = {
        "accuracy": accuracy,
        "loss": loss.item(),
        "timestamp": datetime.now().isoformat(),
        "epochs": epochs,
        "samples_train": len(X_train),
        "samples_test": len(X_test)
    }
    
    metrics_path = os.path.join(models_dir, "metrics.json")
    with open(metrics_path, 'w') as f:
        json.dump(metrics, f, indent=2)
    print(f"Metrics saved to: {metrics_path}")

if __name__ == "__main__":
    train_model()
