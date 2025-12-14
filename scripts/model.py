#!/usr/bin/env python3
"""
Shared model architectures for SRCX Blueprint AI
"""

import torch.nn as nn


class SimpleModel(nn.Module):
    """Simple neural network model for classification tasks"""
    
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
