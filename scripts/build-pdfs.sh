#!/usr/bin/env bash
#
# Baut die drei PDFs lokal genau so, wie es
# .github/workflows/release.yml im Release-Job tut.
# Voraussetzung: Node.js/npx verfügbar (lädt md-to-pdf bei Bedarf automatisch).
#
# Aufruf: ./scripts/build-pdfs.sh

set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."

for tool in node npx; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    echo "Fehler: '${tool}' wurde nicht gefunden." >&2
    echo "Node.js (inkl. npx) installieren, z. B. via https://nodejs.org/ oder nvm." >&2
    exit 1
  fi
done

# Chrome/Puppeteer benötigt in manchen Umgebungen (z. B. Ubuntu 23.10+ mit
# AppArmor-Restriktion für unprivilegierte User-Namespaces) --no-sandbox,
# da der Sandbox-Start sonst mit "No usable sandbox!" abstürzt. Für das reine
# lokale Rendern eigener, vertrauenswürdiger Markdown-Dateien (kein Besuch
# fremder Webseiten) ist das unkritisch.
LAUNCH_OPTIONS='{"args": ["--no-sandbox", "--disable-setuid-sandbox"]}'

declare -A OUT=(
  ["webseite-uebersetzen-de"]="webseite-uebersetzen"
  ["webseite-uebersetzen-fr"]="traduire-site-web"
  ["webseite-uebersetzen-it"]="tradurre-sito-web"
)

for src in "${!OUT[@]}"; do
  echo "==> ${src}.md -> ${OUT[$src]}.pdf"
  npx --yes md-to-pdf@5 "${src}.md" --launch-options "${LAUNCH_OPTIONS}"
  mv "${src}.pdf" "${OUT[$src]}.pdf"
done

echo
echo "Fertig. Erzeugte PDFs:"
ls -la webseite-uebersetzen.pdf traduire-site-web.pdf tradurre-sito-web.pdf
