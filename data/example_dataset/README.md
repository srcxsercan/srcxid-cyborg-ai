# Example Dataset

This directory contains example data for the automated ML training pipeline.

## Data Structure

The data collection script (`scripts/collect_data.py`) generates JSON files with the following structure:

```json
{
  "id": 0,
  "timestamp": "2023-12-14T12:00:00",
  "features": [0.123, 0.456, ...],
  "label": 0
}
```

## Usage

1. **Generate data**: Run `python scripts/collect_data.py` to create sample JSON files in `data/raw/`
2. **Preprocess**: Run `python scripts/preprocess.py` to convert JSON files to CSV in `data/processed/`
3. **Train**: Use the processed CSV for model training

## Notes

- This is example/dummy data for demonstration purposes
- In production, replace with your actual data collection logic
- Consider using data versioning tools like DVC for production datasets
- For large datasets, consider cloud storage (S3, GCS, Azure Blob)

## Data Format

- **Features**: 10 random floating-point values
- **Label**: Binary classification (0 or 1)
- **Format**: JSON for raw data, CSV for processed data
