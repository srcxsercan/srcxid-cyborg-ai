#!/bin/bash

echo "🚀 STARSHIP EVOLUTION ORCHESTRATOR — v25 → v50"
ROOT=$(pwd)

VERSIONS=(
  26 27 28 29 30
  31 32 33 34 35
  36 37 38 39 40
  41 42 43 44 45
  46 47 48 49 50
)

run_installer() {
  local v=$1
  local script="cyborg-init-v${v}.sh"

  if [ ! -f "$script" ]; then
    echo "⚠️ Installer bulunamadı: $script — atlanıyor..."
    return
  fi

  echo "----------------------------------------"
  echo "🚀 v${v} installer çalıştırılıyor..."
  echo "----------------------------------------"

  chmod +x "$script"
  ./"$script"
}

run_cli_if_exists() {
  local cli=$1
  if [ -f "src/cli/$cli" ]; then
    echo "▶️ Çalıştırılıyor: $cli"
    node "src/cli/$cli"
  fi
}

echo "📁 Klasör yapısı doğrulanıyor..."
mkdir -p src/cli sync/state heartbeat memory/snapshots telemetry/events

echo "✅ Başlangıç yapısı hazır."

for v in "${VERSIONS[@]}"; do
  run_installer "$v"

  # Versiyonlara göre otomatik CLI çağrıları
  run_cli_if_exists "cyborg-heartbeat.js"
  run_cli_if_exists "cyborg-sla.js"
  run_cli_if_exists "cyborg-sync.js"
  run_cli_if_exists "cyborg-snapshot.js"
  run_cli_if_exists "cyborg-snapshot-diff.js"
  run_cli_if_exists "cyborg-brain.js"
  run_cli_if_exists "cyborg-rc.js"
done

echo "✅ Tüm versiyonlar işlendi."
echo "📄 Final RC/GA raporları üretildi."
echo "⚠️ Git push işlemini sen manuel yapacaksın."
