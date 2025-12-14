#!/usr/bin/env python3
"""
cleanup.py - Removes temporary files and patterns, cleans empty folders
"""
import os
import shutil
import glob
import argparse

def remove_pattern(pattern, dry_run=False):
    """Remove files matching pattern"""
    files = glob.glob(pattern, recursive=True)
    removed_count = 0
    
    for file in files:
        if os.path.isfile(file):
            if dry_run:
                print(f"[DRY RUN] Would remove: {file}")
            else:
                os.remove(file)
                print(f"Removed: {file}")
            removed_count += 1
    
    return removed_count

def remove_empty_dirs(root_dir='.', dry_run=False):
    """Remove empty directories"""
    removed_count = 0
    
    for dirpath, dirnames, filenames in os.walk(root_dir, topdown=False):
        # Skip .git and node_modules
        if '.git' in dirpath or 'node_modules' in dirpath:
            continue
        
        if not dirnames and not filenames:
            if dry_run:
                print(f"[DRY RUN] Would remove empty dir: {dirpath}")
            else:
                os.rmdir(dirpath)
                print(f"Removed empty dir: {dirpath}")
            removed_count += 1
    
    return removed_count

def cleanup(remove_node_modules=False, dry_run=False):
    """Clean up temporary and unwanted files"""
    print("Starting cleanup...")
    
    if dry_run:
        print("\n=== DRY RUN MODE - No files will be deleted ===\n")
    
    # Patterns to remove
    patterns = [
        "**/.DS_Store",
        "**/*.log",
        "**/*.tmp",
        "**/*.bak"
    ]
    
    total_removed = 0
    
    for pattern in patterns:
        print(f"\nCleaning pattern: {pattern}")
        count = remove_pattern(pattern, dry_run)
        total_removed += count
        print(f"  → {count} files")
    
    # Optionally remove node_modules
    if remove_node_modules:
        print("\nRemoving node_modules directories...")
        for root, dirs, files in os.walk('.'):
            if 'node_modules' in dirs:
                node_modules_path = os.path.join(root, 'node_modules')
                if dry_run:
                    print(f"[DRY RUN] Would remove: {node_modules_path}")
                else:
                    shutil.rmtree(node_modules_path)
                    print(f"Removed: {node_modules_path}")
                total_removed += 1
    
    # Remove empty directories
    print("\nRemoving empty directories...")
    empty_dirs = remove_empty_dirs('.', dry_run)
    total_removed += empty_dirs
    print(f"  → {empty_dirs} empty directories")
    
    print(f"\nCleanup complete. Total items removed: {total_removed}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Clean up temporary files and folders')
    parser.add_argument('--remove-node-modules', action='store_true', 
                        help='Also remove node_modules directories')
    parser.add_argument('--dry-run', action='store_true',
                        help='Show what would be deleted without actually deleting')
    
    args = parser.parse_args()
    cleanup(remove_node_modules=args.remove_node_modules, dry_run=args.dry_run)
