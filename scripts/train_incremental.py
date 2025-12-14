#!/usr/bin/env python3
"""
Incremental training script for SRCX Blueprint AI
Loads existing model and fine-tunes on new data in small batches
"""

import argparse
import json
import os
import sys
from pathlib import Path
from datetime import datetime

import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import DataLoader, TensorDataset
import numpy as np


class SimpleModel(nn.Module):
    """Simple neural network model - must match train.py"""
    
    def __init__(self, input_dim=768, hidden_dim=256, output_dim=10):
        super(SimpleModel, self).__init__()
        self.fc1 = nn.Linear(input_dim, hidden_dim)
        self.relu = nn.ReLU()
        self.dropout = nn.Dropout(0.3)
        self.fc2 = nn.Linear(hidden_dim, hidden_dim // 2)
        self.fc3 = nn.Linear(hidden_dim // 2, output_dim)
    
    def forward(self, x):
        x = self.fc1(x)
        x = self.relu(x)
        x = self.dropout(x)
        x = self.fc2(x)
        x = self.relu(x)
        x = self.fc3(x)
        return x


def load_new_data(data_path, batch_size=16):
    """Load new training data for incremental learning"""
    print(f"Loading new data from {data_path}")
    
    # Create dummy data for demonstration
    # In real scenario, load from data_path (new data only)
    num_samples = 200  # Smaller batch of new data
    input_dim = 768
    output_dim = 10
    
    X = torch.randn(num_samples, input_dim)
    y = torch.randint(0, output_dim, (num_samples,))
    
    dataset = TensorDataset(X, y)
    dataloader = DataLoader(dataset, batch_size=batch_size, shuffle=True)
    
    return dataloader, input_dim, output_dim


def load_existing_model(model_path, input_dim=768, hidden_dim=256, output_dim=10):
    """Load existing trained model"""
    model = SimpleModel(input_dim=input_dim, hidden_dim=hidden_dim, 
                        output_dim=output_dim)
    
    model_file = Path(model_path)
    if model_file.is_dir():
        model_file = model_file / 'model.pt'
    
    if not model_file.exists():
        raise FileNotFoundError(f"Model not found at {model_file}")
    
    print(f"Loading existing model from {model_file}")
    state_dict = torch.load(model_file, map_location='cpu')
    model.load_state_dict(state_dict)
    
    return model


def incremental_train(model, dataloader, criterion, optimizer, device, 
                      num_epochs=5, checkpoint_freq=1):
    """Perform incremental training with frequent checkpointing"""
    model.train()
    
    metrics_history = []
    
    for epoch in range(num_epochs):
        total_loss = 0
        correct = 0
        total = 0
        
        for batch_idx, (data, target) in enumerate(dataloader):
            data, target = data.to(device), target.to(device)
            
            optimizer.zero_grad()
            output = model(data)
            loss = criterion(output, target)
            loss.backward()
            optimizer.step()
            
            total_loss += loss.item()
            _, predicted = output.max(1)
            total += target.size(0)
            correct += predicted.eq(target).sum().item()
        
        avg_loss = total_loss / len(dataloader)
        accuracy = 100. * correct / total
        
        metrics = {
            'epoch': epoch + 1,
            'loss': avg_loss,
            'accuracy': accuracy,
            'timestamp': datetime.now().isoformat()
        }
        metrics_history.append(metrics)
        
        print(f"Epoch {epoch + 1}/{num_epochs} - Loss: {avg_loss:.4f}, "
              f"Accuracy: {accuracy:.2f}%")
    
    return metrics_history


def save_incremental_checkpoint(model, output_dir, metrics, version=None):
    """Save incremental model checkpoint with versioning"""
    output_path = Path(output_dir)
    output_path.mkdir(parents=True, exist_ok=True)
    
    # Version the model
    if version is None:
        version = datetime.now().strftime("%Y%m%d_%H%M%S")
    
    versioned_dir = output_path / f"incremental_{version}"
    versioned_dir.mkdir(exist_ok=True)
    
    # Save model
    model_path = versioned_dir / 'model.pt'
    torch.save(model.state_dict(), model_path)
    
    # Save metrics
    metrics_path = versioned_dir / 'incremental_metrics.json'
    with open(metrics_path, 'w') as f:
        json.dump(metrics, f, indent=2)
    
    # Update latest symlink or file
    latest_path = output_path / 'latest_incremental.json'
    with open(latest_path, 'w') as f:
        json.dump({
            'version': version,
            'model_path': str(model_path),
            'timestamp': datetime.now().isoformat(),
            'final_metrics': metrics[-1] if metrics else {}
        }, f, indent=2)
    
    print(f"Incremental checkpoint saved to {versioned_dir}")
    return versioned_dir


def main():
    parser = argparse.ArgumentParser(
        description='Incremental training for SRCX Blueprint AI'
    )
    parser.add_argument('--base-model', type=str, required=True,
                        help='Path to existing trained model')
    parser.add_argument('--new-data', type=str, required=True,
                        help='Path to new training data')
    parser.add_argument('--epochs', type=int, default=5,
                        help='Number of incremental training epochs')
    parser.add_argument('--batch-size', type=int, default=16,
                        help='Training batch size (smaller for incremental)')
    parser.add_argument('--learning-rate', type=float, default=0.0001,
                        help='Learning rate (lower for fine-tuning)')
    parser.add_argument('--output-dir', type=str, default='models/incremental',
                        help='Output directory for incremental models')
    parser.add_argument('--hidden-dim', type=int, default=256,
                        help='Hidden dimension size')
    parser.add_argument('--checkpoint-freq', type=int, default=1,
                        help='Checkpoint frequency (epochs)')
    
    args = parser.parse_args()
    
    # Setup
    device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
    print(f"Using device: {device}")
    
    print("\n=== Incremental Training Mode ===")
    print(f"Base model: {args.base_model}")
    print(f"New data: {args.new_data}")
    print(f"Epochs: {args.epochs}")
    print(f"Learning rate: {args.learning_rate} (reduced for fine-tuning)")
    
    # Load new data
    dataloader, input_dim, output_dim = load_new_data(args.new_data, 
                                                       args.batch_size)
    
    # Load existing model
    model = load_existing_model(args.base_model, input_dim=input_dim,
                                hidden_dim=args.hidden_dim, 
                                output_dim=output_dim)
    model = model.to(device)
    
    # Setup for fine-tuning with lower learning rate
    criterion = nn.CrossEntropyLoss()
    optimizer = optim.Adam(model.parameters(), lr=args.learning_rate)
    
    # MLflow integration (optional)
    use_mlflow = os.environ.get('MLFLOW_TRACKING_URI') is not None
    if use_mlflow:
        try:
            import mlflow
            mlflow.set_experiment("srcx-blueprint-ai-incremental")
            mlflow.start_run()
            mlflow.log_params({
                'base_model': args.base_model,
                'epochs': args.epochs,
                'batch_size': args.batch_size,
                'learning_rate': args.learning_rate,
                'hidden_dim': args.hidden_dim
            })
            print("MLflow tracking enabled for incremental training")
        except ImportError:
            print("MLflow not available, skipping tracking")
            use_mlflow = False
    
    # Perform incremental training
    print(f"\nStarting incremental training for {args.epochs} epochs...")
    metrics_history = incremental_train(
        model, dataloader, criterion, optimizer, device,
        num_epochs=args.epochs, checkpoint_freq=args.checkpoint_freq
    )
    
    # Log to MLflow
    if use_mlflow:
        for metrics in metrics_history:
            mlflow.log_metrics({
                'incremental_loss': metrics['loss'],
                'incremental_accuracy': metrics['accuracy']
            }, step=metrics['epoch'])
    
    # Save incremental checkpoint
    version = datetime.now().strftime("%Y%m%d_%H%M%S")
    checkpoint_dir = save_incremental_checkpoint(model, args.output_dir, 
                                                  metrics_history, version)
    
    # Final summary
    final_metrics = metrics_history[-1]
    print(f"\nIncremental training complete!")
    print(f"Final loss: {final_metrics['loss']:.4f}")
    print(f"Final accuracy: {final_metrics['accuracy']:.2f}%")
    print(f"Model saved to {checkpoint_dir}")
    
    # Log model to MLflow
    if use_mlflow:
        mlflow.pytorch.log_model(model, "incremental_model")
        mlflow.end_run()
    
    return 0


if __name__ == '__main__':
    sys.exit(main())
