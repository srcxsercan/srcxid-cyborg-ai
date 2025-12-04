#!/usr/bin/env bash
# Rename/cleanup script for replacing "SRCXID CYBORG AI" references with
# visible title "SRCXID CYBORG AI" and slug "srcxid-cyborg-ai".
# Usage:
#   chmod +x rename-srcxid-cyborg-ai.sh
#   ./rename-srcxid-cyborg-ai.sh         # interactive mode
#   ./rename-srcxid-cyborg-ai.sh --yes   # non-interactive
#   ./rename-srcxid-cyborg-ai.sh --dry   # dry-run (no changes)
set -euo pipefail

NEW_BRANCH="rename/srcxid-cyborg-ai-to-srcxid-cyborg-ai"
TITLE_DISPLAY="SRCXID CYBORG AI"
SLUG="srcxid-cyborg-ai"
DRY_RUN=false
AUTO_YES=false
EXCLUDE_GREP="^(.git/|node_modules/|dist/|build/|venv/|.venv/|__pycache__/|.pytest_cache/|.gitignore$|package-lock.json$|yarn.lock$)"

for arg in "$@"; do
  case "$arg" in
    --dry) DRY_RUN=true ;;
    --yes) AUTO_YES=true ;;
    --help|-h) printf "Options:\n  --dry   Dry run (no changes)\n  --yes   Assume yes for prompts\n"; exit 0 ;;
  esac
done

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "[ERROR] Bu dizin bir Git deposu değil. Repoyu klonlayıp tekrar deneyin." >&2
  exit 1
fi

if [ -n "$(git status --porcelain)" ]; then
  echo "[WARN] Working tree temiz değil. Commit veya stash yapın." >&2
  if [ "$AUTO_YES" = false ]; then
    read -rp "Devam edilsin mi (y/N)? " yn
    case "$yn" in [Yy]*) ;; *) echo "İptal edildi."; exit 1 ;; esac
  fi
fi

echo "[INFO] 'SRCXID CYBORG AI' içeren dosyalar aranıyor..."
IFS=$'\n' read -r -d '' -a MATCHED_FILES < <(
  git grep -I -n --line-number --untracked -e "SRCXID CYBORG AI" -e "SRCXID CYBORG AI" -e "srcxid-cyborg-ai" -- . ':' 2>/dev/null \
  | cut -d: -f1 | sort -u | grep -Ev "${EXCLUDE_GREP}" || true
) || true

echo "[INFO] 'srcxid-cyborg-ai' içeren dosya/dizin isimleri aranıyor..."
IFS=$'\n' read -r -d '' -a PATH_WITH_BLUEPRINT < <(
  git ls-files | grep -E "srcxid-cyborg-ai" || true
) || true

if [ "$DRY_RUN" = true ]; then
  echo
  echo "[DRY RUN] Aşağıdaki içerik dosyalarında değişiklik olabilir:"
  printf '%s\n' "${MATCHED_FILES[@]}"
  echo
  echo "[DRY RUN] Aşağıdaki yollar yeniden adlandırılabilir:"
  printf '%s\n' "${PATH_WITH_BLUEPRINT[@]}"
  echo
  echo "[DRY RUN] Bitti. Eğer uygun görünüyorsa çalıştırmak için: ./rename-srcxid-cyborg-ai.sh"
  exit 0
fi

if [ "$AUTO_YES" = false ]; then
  read -rp "Branch '$NEW_BRANCH' oluşturulsun ve değişiklik yapılsın mı? (y/N) " ok
  case "$ok" in [Yy]*) ;; *) echo "İptal edildi."; exit 1 ;; esac
fi

git checkout -b "$NEW_BRANCH"

backup_file(){ cp -- "$1" "$1.bk" 2>/dev/null || true; }

echo "[INFO] Metin içi değişiklikler uygulanıyor..."
for f in "${MATCHED_FILES[@]}"; do
  if ! grep -Iq . "$f" 2>/dev/null; then
    echo "[SKIP] Binary: $f"
    continue
  fi
  backup_file "$f"
  perl -0777 -pe "s/\bBLUEPRINT\b/${TITLE_DISPLAY}/g; s/\bBlueprint\b/${TITLE_DISPLAY}/g; s/\bblueprint\b/${SLUG}/g" -i "$f"
  if ! cmp -s "$f" "$f.bk" 2>/dev/null; then
    git add "$f"
    echo "[MODIFIED] $f"
  else
    rm -f "$f.bk"
  fi
done

if [ -f package.json ]; then
  echo "[INFO] package.json güncellemesi..."
  if command -v jq >/dev/null 2>&1; then
    jq --arg slug "$SLUG" --arg title "$TITLE_DISPLAY" \
      '(.name // "") |= (if . != "" then (gsub("(?i)srcxid-cyborg-ai"; $slug)) else $slug end) |
       (.description // "") |= (gsub("(?i)SRCXID CYBORG AI"; $title))' package.json > package.json.tmp && mv package.json.tmp package.json
    git add package.json
    echo "[MODIFIED] package.json (jq)"
  elif command -v node >/dev/null 2>&1; then
    node -e "const fs=require('fs');p='package.json';pkg=JSON.parse(fs.readFileSync(p,'utf8'));pkg.name=((pkg.name||'').replace(/srcxid-cyborg-ai/ig,'${SLUG}'))||'${SLUG}';pkg.description=(pkg.description||'').replace(/SRCXID CYBORG AI/ig,'${TITLE_DISPLAY}');fs.writeFileSync(p,JSON.stringify(pkg,null,2)+'\n');"
    git add package.json
    echo "[MODIFIED] package.json (node)"
  else
    echo "[WARN] jq/node yok - package.json otomatik güncellenemedi." >&2
  fi
fi

echo "[INFO] .github ve diğer meta dosyaları güncelleniyor..."
if [ -d .github ]; then
  git ls-files .github | grep -E '\.ya?ml$|\.yml$|\.md$|\.txt$' || true | while read -r gf; do
    backup_file "$gf"
    perl -0777 -pe "s/\bBLUEPRINT\b/${TITLE_DISPLAY}/g; s/\bBlueprint\b/${TITLE_DISPLAY}/g; s/\bblueprint\b/${SLUG}/g" -i "$gf"
    if ! cmp -s "$gf" "$gf.bk" 2>/dev/null; then git add "$gf"; echo "[MODIFIED] $gf"; else rm -f "$gf.bk"; fi
  done
fi

if [ ${#PATH_WITH_BLUEPRINT[@]} -gt 0 ]; then
  echo "[INFO] Dosya/dizin yeniden adlandırmaları yapılıyor..."
  IFS=$'\n' read -r -d '' -a UNIQUE_DIRS < <(printf "%s\n" "${PATH_WITH_BLUEPRINT[@]}" | xargs -n1 dirname | sort -uV | tac || true) || true
  for d in "${UNIQUE_DIRS[@]}"; do
    newd=$(echo "$d" | sed "s/srcxid-cyborg-ai/${SLUG}/g")
    [ "$d" = "$newd" ] && continue
    if [ -e "$newd" ]; then echo "[WARN] Hedef var: $newd, atlanıyor."; continue; fi
    git mv "$d" "$newd" || echo "[WARN] git mv başarısız: $d"
  done
  FILES2=$(git ls-files | grep -E "srcxid-cyborg-ai" || true)
  if [ -n "$FILES2" ]; then
    echo "$FILES2" | while read -r f; do
      newf=$(echo "$f" | sed "s/srcxid-cyborg-ai/${SLUG}/g")
      [ "$f" = "$newf" ] && continue
      if [ -e "$newf" ]; then echo "[WARN] Hedef dosya var: $newf"; continue; fi
      git mv "$f" "$newf" || echo "[WARN] git mv dosya başarısız: $f"
    done
  fi
fi

echo "[INFO] Geçici dosyalar temizleniyor..."
git ls-files -z | xargs -0 -r -n1 bash -c 'case "$0" in *".DS_Store" | *".log" | *".tmp" | *".bak") git rm -f -- "$0" || true ;; esac' || true
shopt -s globstar nullglob
for pat in "**/.DS_Store" "**/*.log" "**/*.tmp" "**/*.bak"; do
  for p in $pat; do [ -e "$p" ] && rm -f -- "$p"; done
done
shopt -u globstar nullglob

git add -A || true

if git diff --cached --quiet; then
  echo "[INFO] Staged değişiklik yok - commit atlanıyor."
else
  git commit -m "chore(rename): replace SRCXID CYBORG AI references with SRCXID CYBORG AI / srcxid-cyborg-ai and cleanup temporary files"
  echo "[INFO] Commit atıldı."
fi

echo "[INFO] İşlem bitti. Lütfen değişiklikleri kontrol edin."
echo "  git status --porcelain=v1"
echo "  git log -n 5 --oneline"
echo ""
echo "Uzak branch'a göndermek için: git push origin $NEW_BRANCH"
exit 0
