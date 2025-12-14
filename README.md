# SRCX CYBORG-OS

Global fintech orchestrator + multi-currency ledger + event-driven payment engine.

## Genel Bakış

Bu proje, otomatik makine öğrenmesi eğitim pipeline'ı ile birlikte global fintech orchestration ve çoklu para birimi defteri yönetimi sağlar.

## Kurulum

```bash
pip install -r requirements.txt
```

## Kullanım

### Veri Toplama
```bash
python scripts/collect_data.py
```

### Veri Ön İşleme
```bash
python scripts/preprocess.py
```

### Model Eğitimi
```bash
python scripts/train.py
```

### Model Değerlendirme
```bash
python scripts/evaluate.py
```

### Otomatik Yeniden Eğitim
```bash
python scripts/auto_retrain.py
```

### Temizlik
```bash
python scripts/cleanup.py
```

## GitHub Actions

- **Günlük Eğitim**: Her gün otomatik olarak model eğitilir (`.github/workflows/train.yml`)
- **Haftalık Temizlik**: Her hafta geçici dosyalar temizlenir (`.github/workflows/cleanup.yml`)

## Özellikler

- Otomatik veri toplama ve ön işleme
- PyTorch tabanlı model eğitimi
- Metrik takibi ve otomatik yeniden eğitim
- Zamanlanmış CI/CD iş akışları
- Otomatik temizlik scriptleri
