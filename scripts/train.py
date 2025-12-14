#!/usr/bin/env python3
"""
Training script for SRCX Blueprint AI models
Supports MLflow logging and resume training from checkpoints
"""

import argparse
import json
import os
import sys
from pathlib import Path

import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import DataLoader, TensorDataset
import numpy as np

from model import SimpleModel


def load_data(data_path, batch_size=32):
    """Load training data - placeholder for actual data loading"""
    print(f"Loading data from {data_path}")
    
    # Create dummy data for demonstration
    # In real scenario, load from data_path
    num_samples = 1000
    input_dim = 768
    output_dim = 10
    
    X = torch.randn(num_samples, input_dim)
    y = torch.randint(0, output_dim, (num_samples,))
    
    dataset = TensorDataset(X, y)
    dataloader = DataLoader(dataset, batch_size=batch_size, shuffle=True)
    
    return dataloader, input_dim, output_dim


def train_epoch(model, dataloader, criterion, optimizer, device):
    """Train for one epoch"""
    model.train()
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
    
    return avg_loss, accuracy


def save_checkpoint(model, optimizer, epoch, output_dir, metrics):
    """Save model checkpoint"""
    checkpoint = {
        'epoch': epoch,
        'model_state_dict': model.state_dict(),
        'optimizer_state_dict': optimizer.state_dict(),
        'metrics': metrics
    }
    
    checkpoint_path = Path(output_dir) / 'checkpoint.pt'
    torch.save(checkpoint, checkpoint_path)
    
    # Also save just the model
    model_path = Path(output_dir) / 'model.pt'
    torch.save(model.state_dict(), model_path)
    
    print(f"Checkpoint saved to {checkpoint_path}")
    return checkpoint_path


def load_checkpoint(resume_path, model, optimizer=None):
    """Load model checkpoint for resuming training"""
    checkpoint_path = Path(resume_path)
    
    if checkpoint_path.is_dir():
        checkpoint_path = checkpoint_path / 'checkpoint.pt'
    
    if not checkpoint_path.exists():
        print(f"Warning: Checkpoint not found at {checkpoint_path}")
        return 0, {}
    
    print(f"Loading checkpoint from {checkpoint_path}")
    checkpoint = torch.load(checkpoint_path, map_location='cpu')
    
    model.load_state_dict(checkpoint['model_state_dict'])
    if optimizer is not None and 'optimizer_state_dict' in checkpoint:
        optimizer.load_state_dict(checkpoint['optimizer_state_dict'])
    
    epoch = checkpoint.get('epoch', 0)
    metrics = checkpoint.get('metrics', {})
    
    print(f"Resumed from epoch {epoch}")
    return epoch, metrics


def main():
    parser = argparse.ArgumentParser(description='Train SRCX Blueprint AI model')
    parser.add_argument('--data-path', type=str, required=True,
                        help='Path to training data')
    parser.add_argument('--epochs', type=int, default=10,
                        help='Number of training epochs')
    parser.add_argument('--batch-size', type=int, default=32,
                        help='Training batch size')
    parser.add_argument('--learning-rate', type=float, default=0.001,
                        help='Learning rate')
    parser.add_argument('--output-dir', type=str, default='models',
                        help='Output directory for model')
    parser.add_argument('--resume', type=str, default=None,
                        help='Resume training from checkpoint directory')
    parser.add_argument('--hidden-dim', type=int, default=256,
                        help='Hidden dimension size')
    
    args = parser.parse_args()
    
    # Setup
    device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
    print(f"Using device: {device}")
    
    # Create output directory
    output_dir = Path(args.output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)
    
    # Load data
    dataloader, input_dim, output_dim = load_data(args.data_path, args.batch_size)
    
    # Initialize model
    model = SimpleModel(input_dim=input_dim, hidden_dim=args.hidden_dim, 
                        output_dim=output_dim).to(device)
    
    # Setup training
    criterion = nn.CrossEntropyLoss()
    optimizer = optim.Adam(model.parameters(), lr=args.learning_rate)
    
    # Resume from checkpoint if specified
    start_epoch = 0
    prev_metrics = {}
    if args.resume:
        start_epoch, prev_metrics = load_checkpoint(args.resume, model, optimizer)
    
    # MLflow integration (optional)
    use_mlflow = os.environ.get('MLFLOW_TRACKING_URI') is not None
    if use_mlflow:
        try:
            import mlflow
            mlflow.set_experiment("srcx-blueprint-ai-training")
            mlflow.start_run()
            mlflow.log_params({
                'epochs': args.epochs,
                'batch_size': args.batch_size,
                'learning_rate': args.learning_rate,
                'hidden_dim': args.hidden_dim,
                'resumed_from_epoch': start_epoch
            })
            print("MLflow tracking enabled")
        except ImportError:
            print("MLflow not available, skipping tracking")
            use_mlflow = False
    
    # Training loop
    print(f"\nStarting training for {args.epochs} epochs...")
    best_accuracy = 0
    all_metrics = []
    
    for epoch in range(start_epoch, start_epoch + args.epochs):
        print(f"\nEpoch {epoch + 1}/{start_epoch + args.epochs}")
        
        loss, accuracy = train_epoch(model, dataloader, criterion, optimizer, device)
        
        print(f"Loss: {loss:.4f}, Accuracy: {accuracy:.2f}%")
        
        metrics = {
            'epoch': epoch + 1,
            'loss': loss,
            'accuracy': accuracy
        }
        all_metrics.append(metrics)
        
        # Log to MLflow
        if use_mlflow:
            mlflow.log_metrics({
                'train_loss': loss,
                'train_accuracy': accuracy
            }, step=epoch + 1)
        
        # Save checkpoint
        if accuracy > best_accuracy:
            best_accuracy = accuracy
            save_checkpoint(model, optimizer, epoch + 1, output_dir, metrics)
    
    # Save final metrics
    metrics_path = output_dir / 'metrics.json'
    with open(metrics_path, 'w') as f:
        json.dump({
            'final_loss': all_metrics[-1]['loss'],
            'final_accuracy': all_metrics[-1]['accuracy'],
            'best_accuracy': best_accuracy,
            'epochs': args.epochs,
            'all_epochs': all_metrics
        }, f, indent=2)
    
    print(f"\nTraining complete! Best accuracy: {best_accuracy:.2f}%")
    print(f"Model saved to {output_dir}")
    
    # Log model to MLflow
    if use_mlflow:
        mlflow.pytorch.log_model(model, "model")
        mlflow.log_artifact(str(metrics_path))
        mlflow.end_run()
    
    return 0


if __name__ == '__main__':
    sys.exit(main())
