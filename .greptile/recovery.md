# CYBORG-OS v5 — Autonomous Recovery Rules

Greptile bu projede:
- Retry mekanizmasının exponential backoff içerdiğini doğrulamalı
- Dead-letter queue'nun doğru çalıştığını kontrol etmeli
- Orchestrator çökse bile event'lerin kaybolmadığını doğrulamalı
- safe() wrapper'ın tüm external call'larda kullanıldığını kontrol etmeli
- Event replay mekanizmasını enforce etmeli
