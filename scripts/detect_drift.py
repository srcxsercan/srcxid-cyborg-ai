#!/usr/bin/env python3
"""
Data drift detection script for SRCX Blueprint AI
Compares class distribution and text statistics between dataset snapshots
"""

import argparse
import json
import sys
from pathlib import Path
from collections import Counter
from datetime import datetime

import numpy as np


def load_dataset_snapshot(snapshot_path):
    """Load dataset snapshot metadata"""
    snapshot_file = Path(snapshot_path)
    
    if not snapshot_file.exists():
        print(f"Error: Snapshot not found at {snapshot_path}")
        return None
    
    print(f"Loading snapshot from {snapshot_file}")
    
    with open(snapshot_file, 'r') as f:
        snapshot = json.load(f)
    
    return snapshot


def create_dummy_snapshot(output_path, num_samples=1000, num_classes=10):
    """Create a dummy snapshot for testing purposes"""
    print(f"Creating dummy snapshot at {output_path}")
    
    # Generate random class distribution
    class_counts = {}
    for i in range(num_classes):
        class_counts[f"class_{i}"] = np.random.randint(50, 150)
    
    # Generate random text statistics
    text_lengths = np.random.normal(100, 30, num_samples).tolist()
    
    snapshot = {
        'timestamp': datetime.now().isoformat(),
        'num_samples': num_samples,
        'num_classes': num_classes,
        'class_distribution': class_counts,
        'text_statistics': {
            'mean_length': np.mean(text_lengths),
            'std_length': np.std(text_lengths),
            'min_length': np.min(text_lengths),
            'max_length': np.max(text_lengths),
            'median_length': np.median(text_lengths)
        },
        'feature_statistics': {
            'feature_mean': np.random.rand(10).tolist(),
            'feature_std': np.random.rand(10).tolist()
        }
    }
    
    output_file = Path(output_path)
    output_file.parent.mkdir(parents=True, exist_ok=True)
    
    with open(output_file, 'w') as f:
        json.dump(snapshot, f, indent=2)
    
    print(f"Snapshot created: {num_samples} samples, {num_classes} classes")
    return snapshot


def calculate_distribution_drift(dist1, dist2):
    """Calculate symmetric KL divergence (Jensen-Shannon divergence) between two class distributions"""
    # Normalize distributions
    total1 = sum(dist1.values())
    total2 = sum(dist2.values())
    
    prob1 = {k: v / total1 for k, v in dist1.items()}
    prob2 = {k: v / total2 for k, v in dist2.items()}
    
    # Ensure same keys
    all_keys = set(prob1.keys()) | set(prob2.keys())
    
    # Calculate symmetric KL divergence (average of both directions)
    # KL(P||Q) + KL(Q||P) / 2
    kl_pq = 0.0
    kl_qp = 0.0
    
    for key in all_keys:
        p1 = prob1.get(key, 1e-10)
        p2 = prob2.get(key, 1e-10)
        
        # Add small epsilon for numerical stability
        p1 = max(p1, 1e-10)
        p2 = max(p2, 1e-10)
        
        kl_pq += p1 * np.log(p1 / p2)
        kl_qp += p2 * np.log(p2 / p1)
    
    # Return symmetric KL divergence
    return (kl_pq + kl_qp) / 2.0


def calculate_statistical_drift(stats1, stats2):
    """Calculate drift in statistical measures with robust handling of small values"""
    mean_diff = abs(stats1['mean_length'] - stats2['mean_length'])
    std_diff = abs(stats1['std_length'] - stats2['std_length'])
    
    # Use relative change only if baseline is meaningful (>1)
    # Otherwise use absolute change
    if stats1['mean_length'] > 1.0:
        mean_drift = mean_diff / stats1['mean_length']
    else:
        mean_drift = mean_diff
    
    if stats1['std_length'] > 1.0:
        std_drift = std_diff / stats1['std_length']
    else:
        std_drift = std_diff
    
    return {
        'mean_drift': mean_drift,
        'std_drift': std_drift,
        'mean_diff': mean_diff,
        'std_diff': std_diff
    }


def detect_drift(current_snapshot, previous_snapshot, thresholds):
    """Detect drift between two snapshots"""
    drift_detected = False
    drift_details = {}
    
    # Check class distribution drift
    kl_divergence = calculate_distribution_drift(
        current_snapshot['class_distribution'],
        previous_snapshot['class_distribution']
    )
    
    drift_details['kl_divergence'] = kl_divergence
    
    if kl_divergence > thresholds['kl_threshold']:
        drift_detected = True
        drift_details['class_distribution_drift'] = True
        print(f"⚠️  Class distribution drift detected! KL divergence: {kl_divergence:.4f}")
    else:
        drift_details['class_distribution_drift'] = False
        print(f"✓ Class distribution stable (KL: {kl_divergence:.4f})")
    
    # Check statistical drift
    stat_drift = calculate_statistical_drift(
        current_snapshot['text_statistics'],
        previous_snapshot['text_statistics']
    )
    
    drift_details['statistical_drift'] = stat_drift
    
    if stat_drift['mean_drift'] > thresholds['mean_threshold']:
        drift_detected = True
        drift_details['mean_length_drift'] = True
        print(f"⚠️  Mean text length drift detected! Change: {stat_drift['mean_drift']:.2%}")
    else:
        drift_details['mean_length_drift'] = False
        print(f"✓ Mean text length stable (change: {stat_drift['mean_drift']:.2%})")
    
    if stat_drift['std_drift'] > thresholds['std_threshold']:
        drift_detected = True
        drift_details['std_length_drift'] = True
        print(f"⚠️  Text length std drift detected! Change: {stat_drift['std_drift']:.2%}")
    else:
        drift_details['std_length_drift'] = False
        print(f"✓ Text length std stable (change: {stat_drift['std_drift']:.2%})")
    
    # Check sample count change
    count_change = abs(current_snapshot['num_samples'] - 
                      previous_snapshot['num_samples'])
    count_change_ratio = count_change / previous_snapshot['num_samples']
    
    drift_details['sample_count_change'] = count_change
    drift_details['sample_count_change_ratio'] = count_change_ratio
    
    if count_change_ratio > thresholds['count_threshold']:
        print(f"⚠️  Significant sample count change: {count_change_ratio:.2%}")
    
    return drift_detected, drift_details


def save_drift_report(drift_detected, drift_details, output_path):
    """Save drift detection report"""
    report = {
        'timestamp': datetime.now().isoformat(),
        'drift_detected': drift_detected,
        'details': drift_details
    }
    
    output_file = Path(output_path)
    output_file.parent.mkdir(parents=True, exist_ok=True)
    
    with open(output_file, 'w') as f:
        json.dump(report, f, indent=2)
    
    print(f"\nDrift report saved to {output_file}")


def main():
    parser = argparse.ArgumentParser(
        description='Detect data drift for SRCX Blueprint AI'
    )
    parser.add_argument('--current', type=str, required=True,
                        help='Path to current dataset snapshot')
    parser.add_argument('--previous', type=str, required=True,
                        help='Path to previous dataset snapshot')
    parser.add_argument('--output', type=str, default='drift_report.json',
                        help='Output path for drift report')
    parser.add_argument('--kl-threshold', type=float, default=0.1,
                        help='KL divergence threshold for drift detection')
    parser.add_argument('--mean-threshold', type=float, default=0.15,
                        help='Mean change threshold (as ratio)')
    parser.add_argument('--std-threshold', type=float, default=0.20,
                        help='Std change threshold (as ratio)')
    parser.add_argument('--count-threshold', type=float, default=0.30,
                        help='Sample count change threshold (as ratio)')
    parser.add_argument('--create-dummy', action='store_true',
                        help='Create dummy snapshots for testing')
    
    args = parser.parse_args()
    
    print("=== SRCX Blueprint AI - Data Drift Detection ===\n")
    
    # Create dummy snapshots if requested
    if args.create_dummy:
        print("Creating dummy snapshots for testing...")
        current_snapshot = create_dummy_snapshot(
            args.current, num_samples=1000, num_classes=10
        )
        # Create slightly different previous snapshot
        previous_snapshot = create_dummy_snapshot(
            args.previous, num_samples=950, num_classes=10
        )
        print()
    else:
        # Load snapshots
        current_snapshot = load_dataset_snapshot(args.current)
        previous_snapshot = load_dataset_snapshot(args.previous)
        
        if current_snapshot is None or previous_snapshot is None:
            print("Error: Failed to load snapshots")
            return 1
    
    # Set thresholds
    thresholds = {
        'kl_threshold': args.kl_threshold,
        'mean_threshold': args.mean_threshold,
        'std_threshold': args.std_threshold,
        'count_threshold': args.count_threshold
    }
    
    print(f"Thresholds:")
    print(f"  KL divergence: {thresholds['kl_threshold']}")
    print(f"  Mean change: {thresholds['mean_threshold']:.0%}")
    print(f"  Std change: {thresholds['std_threshold']:.0%}")
    print(f"  Count change: {thresholds['count_threshold']:.0%}")
    print()
    
    # Detect drift
    drift_detected, drift_details = detect_drift(
        current_snapshot, previous_snapshot, thresholds
    )
    
    # Save report
    save_drift_report(drift_detected, drift_details, args.output)
    
    # Print summary
    print("\n" + "="*50)
    if drift_detected:
        print("🚨 DRIFT DETECTED - Retraining recommended")
        print("="*50)
        return 2  # Exit code 2 indicates drift detected
    else:
        print("✅ NO DRIFT DETECTED - Model is stable")
        print("="*50)
        return 0  # Exit code 0 indicates no drift


if __name__ == '__main__':
    sys.exit(main())
