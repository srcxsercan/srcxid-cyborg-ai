# CYBORG-OS v4 — Orchestrator Rules

Greptile bu projede:
- Event pipeline state machine uyumluluğunu kontrol etmeli
- Orchestrator'ın provider ve bank-rail adapter'larını doğru bağladığını doğrulamalı
- Transaction engine'in double-entry ledger kurallarına uyduğunu kontrol etmeli
- Routing engine'in MCC, country, provider-availability kurallarına uyduğunu doğrulamalı
- Queue mekanizmasının retry + backoff içerdiğini kontrol etmeli
- Error recovery mekanizmasını enforce etmeli
