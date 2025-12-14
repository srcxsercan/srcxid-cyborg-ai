# SRCX CYBORG-OS

Global fintech orchestrator + multi-currency ledger + event-driven payment engine.

## 🤖 Continuous Learning System

This repository now includes an advanced continuous learning system with automated retraining, drift detection, and MLflow integration.

### Features

- ✅ **Reusable Training Workflow** - Callable from any repository
- ✅ **Incremental Training** - Fine-tune models on new data
- ✅ **Drift Detection** - Automatic detection of data distribution changes
- ✅ **MLflow Integration** - Track experiments and model versions
- ✅ **Automated Retraining** - Trigger training when drift is detected
- ✅ **Model Release Pipeline** - Package and deploy models to S3/MLflow
- ✅ **Docker Support** - Reproducible training environment

### Quick Start

#### 1. Local Training

```bash
# Install dependencies
pip install torch torchvision transformers datasets scikit-learn numpy pandas

# Basic training
python scripts/train.py \
  --data-path data/training \
  --epochs 10 \
  --batch-size 32 \
  --output-dir models

# Resume from checkpoint
python scripts/train.py \
  --data-path data/training \
  --epochs 5 \
  --resume models/checkpoint.pt \
  --output-dir models
```

#### 2. Incremental Training

```bash
python scripts/train_incremental.py \
  --base-model models/model.pt \
  --new-data data/new_samples \
  --epochs 5 \
  --learning-rate 0.0001 \
  --output-dir models/incremental
```

#### 3. Drift Detection

```bash
# Create snapshots
python scripts/detect_drift.py \
  --current snapshots/current.json \
  --previous snapshots/previous.json \
  --output drift_report.json \
  --create-dummy

# Check for drift (exits with code 2 if drift detected)
python scripts/detect_drift.py \
  --current snapshots/current.json \
  --previous snapshots/previous.json \
  --kl-threshold 0.1 \
  --mean-threshold 0.15
```

#### 4. Using Docker

```bash
# Build the training container
docker build -t srcx-training .

# Run training
docker run -v $(pwd)/data:/app/data -v $(pwd)/models:/app/models \
  srcx-training python scripts/train.py \
  --data-path /app/data/training \
  --epochs 10 \
  --output-dir /app/models

# Run drift detection
docker run -v $(pwd)/snapshots:/app/snapshots \
  srcx-training python scripts/detect_drift.py \
  --current /app/snapshots/current.json \
  --previous /app/snapshots/previous.json \
  --create-dummy
```

### GitHub Actions Workflows

#### Reusable Training Workflow

Call this workflow from other repositories:

```yaml
jobs:
  train:
    uses: srcxsercan/srcxid-cyborg-ai/.github/workflows/reusable/train-reusable.yml@main
    with:
      data_path: 'data/training'
      epochs: 20
      use_mlflow: true
      model_out_dir: 'models'
      batch_size: 32
      learning_rate: 0.001
    secrets:
      MLFLOW_TRACKING_URI: ${{ secrets.MLFLOW_TRACKING_URI }}
      AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
      AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
      S3_BUCKET: ${{ secrets.S3_BUCKET }}
```

#### Automatic Retraining

Scheduled workflow runs daily to detect drift and retrain if needed:

- **Schedule**: Daily at 2 AM UTC
- **Manual Trigger**: Available via workflow_dispatch
- **Drift Detection**: Compares current and previous data snapshots
- **Auto-Retrain**: Triggers training when drift is detected

#### Model Release

Automatically packages and releases model artifacts:

- **Trigger**: After successful training
- **Artifacts**: Uploaded to GitHub Actions, S3, and MLflow
- **Versioning**: Automatic version tagging

### Required GitHub Secrets

Configure these secrets in your repository settings (Settings > Secrets and variables > Actions):

#### For MLflow Integration (Optional)
- `MLFLOW_TRACKING_URI` - MLflow tracking server URL (e.g., `http://mlflow.example.com`)

#### For S3 Storage (Optional)
- `AWS_ACCESS_KEY_ID` - AWS access key for S3
- `AWS_SECRET_ACCESS_KEY` - AWS secret key for S3
- `S3_BUCKET` - S3 bucket name for model storage

#### For Notifications (Optional)
- `SLACK_WEBHOOK` - Slack webhook URL for notifications

### Testing Locally

#### Test Training Script

```bash
# Create dummy data directory
mkdir -p data/training

# Run training
python scripts/train.py \
  --data-path data/training \
  --epochs 3 \
  --batch-size 16 \
  --output-dir models/test

# Verify output
ls -lh models/test/
cat models/test/metrics.json
```

#### Test Incremental Training

```bash
# First train base model
python scripts/train.py --data-path data/training --epochs 5 --output-dir models/base

# Then run incremental training
python scripts/train_incremental.py \
  --base-model models/base \
  --new-data data/new_samples \
  --epochs 3 \
  --output-dir models/incremental

# Check versions
ls -lh models/incremental/
```

#### Test Drift Detection

```bash
# Create test snapshots
python scripts/detect_drift.py \
  --current snapshots/current.json \
  --previous snapshots/previous.json \
  --create-dummy \
  --output drift_report.json

# View results
cat drift_report.json

# Check exit code
echo $?  # 0 = no drift, 2 = drift detected
```

#### Test with MLflow

```bash
# Start MLflow server locally
pip install mlflow
mlflow server --host 0.0.0.0 --port 5000

# Set environment variable
export MLFLOW_TRACKING_URI=http://localhost:5000

# Run training with MLflow
python scripts/train.py \
  --data-path data/training \
  --epochs 5 \
  --output-dir models

# View experiments at http://localhost:5000
```

### Architecture

```
.github/workflows/
├── reusable/
│   └── train-reusable.yml    # Reusable training workflow
├── auto_retrain.yml          # Scheduled drift detection & retraining
└── release_model.yml         # Model packaging & release

scripts/
├── train.py                  # Main training script with MLflow
├── train_incremental.py      # Incremental training
└── detect_drift.py           # Data drift detection

Dockerfile                    # Training environment container
```

### Continuous Learning Pipeline

1. **Data Collection** → New data arrives
2. **Drift Detection** → Compare with previous data distribution
3. **Automatic Retraining** → Triggered if drift detected
4. **Model Release** → Package and upload to artifact stores
5. **Deployment** → Model ready for production use

### Customization

#### Adjust Drift Thresholds

Edit `.github/workflows/auto_retrain.yml`:

```yaml
--kl-threshold 0.1        # KL divergence threshold
--mean-threshold 0.15     # Mean change threshold
--std-threshold 0.20      # Std change threshold
```

#### Modify Training Schedule

Edit `.github/workflows/auto_retrain.yml`:

```yaml
schedule:
  - cron: '0 2 * * *'  # Daily at 2 AM UTC
  # Change to: '0 */6 * * *' for every 6 hours
```

#### Custom Model Architecture

Edit `scripts/train.py` and `scripts/train_incremental.py` to use your own model architecture.

### Troubleshooting

#### Training Fails
- Check Python dependencies are installed
- Verify data path exists
- Check available disk space for model checkpoints

#### MLflow Connection Issues
- Verify `MLFLOW_TRACKING_URI` is set correctly
- Check network connectivity to MLflow server
- Ensure MLflow is installed: `pip install mlflow`

#### S3 Upload Fails
- Verify AWS credentials are valid
- Check S3 bucket exists and has write permissions
- Ensure `boto3` is installed: `pip install boto3`

#### Drift Detection Always Triggers
- Adjust drift thresholds to be less sensitive
- Check snapshot data is being saved correctly
- Verify data preprocessing is consistent

### Contributing

Contributions welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test locally
5. Submit a pull request

### License

See LICENSE file for details.

---

**Author**: SRCX Systems — Fintech Infrastructure Division  
**Architect**: Sercan Sivrikaya
