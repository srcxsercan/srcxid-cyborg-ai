FROM python:3.9-slim

# Set working directory
WORKDIR /app

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
RUN pip install --upgrade pip && \
    pip install \
    torch==2.0.1 \
    torchvision==0.15.2 \
    torchaudio==2.0.2 \
    --index-url https://download.pytorch.org/whl/cpu

# Install ML and data science packages
RUN pip install \
    transformers==4.30.2 \
    datasets==2.13.1 \
    scikit-learn==1.3.0 \
    numpy==1.24.3 \
    pandas==2.0.3 \
    mlflow==2.5.0 \
    boto3==1.28.9

# Copy scripts
COPY scripts/ /app/scripts/

# Make scripts executable
RUN chmod +x /app/scripts/*.py

# Create directories for data and models
RUN mkdir -p /app/data /app/models /app/snapshots

# Set default command
CMD ["python", "scripts/train.py", "--help"]

# Labels
LABEL maintainer="SRCX Systems"
LABEL description="SRCX Blueprint AI Training Environment"
LABEL version="1.0"

# Health check (optional)
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD python -c "import torch; import mlflow; print('OK')" || exit 1

# Run as non-root user for security
RUN useradd -m -u 1000 mluser && \
    chown -R mluser:mluser /app
USER mluser

# Expose port for MLflow (if running tracking server)
EXPOSE 5000
