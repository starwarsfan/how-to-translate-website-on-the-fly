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

# VERSION wird vom Release-Workflow auf den Tag-Namen gesetzt. Lokal (ohne
# gesetzte Variable) fällt es auf die nächste erreichbare Git-Tag-Beschreibung
# bzw. "dev" zurück, damit auch Testläufe eine sinnvolle Fusszeile bekommen.
VERSION="${VERSION:-$(git describe --tags --always --dirty 2>/dev/null || echo dev)}"
BUILD_DATE="$(date +%d.%m.%Y)"

# Fusszeile (Version, Datum, Seitenzahl) via Puppeteers PDF-Header/Footer-
# Templates. Wird über Node gebaut statt per Shell-String, um Quoting-Fehler
# bei den verschachtelten Anführungszeichen im JSON zu vermeiden.
PDF_OPTIONS="$(VERSION="$VERSION" BUILD_DATE="$BUILD_DATE" node -e '
  const footerTemplate = `<div style="font-size:9px; width:100%; text-align:center; color:#666;">Version ${process.env.VERSION} &middot; ${process.env.BUILD_DATE} &middot; <span class="pageNumber"></span> / <span class="totalPages"></span></div>`;
  console.log(JSON.stringify({
    printBackground: true,
    format: "a4",
    margin: { top: "30mm", right: "40mm", bottom: "30mm", left: "20mm" },
    displayHeaderFooter: true,
    headerTemplate: "<span></span>",
    footerTemplate,
  }));
')"

declare -A OUT=(
  ["webseite-uebersetzen-de"]="webseite-uebersetzen"
  ["webseite-uebersetzen-fr"]="traduire-site-web"
  ["webseite-uebersetzen-it"]="tradurre-sito-web"
)

echo "Version: ${VERSION}  |  Datum: ${BUILD_DATE}"

for src in "${!OUT[@]}"; do
  echo "==> ${src}.md -> ${OUT[$src]}.pdf"
  npx --yes md-to-pdf@5 "${src}.md" --launch-options "${LAUNCH_OPTIONS}" --pdf-options "${PDF_OPTIONS}"
  mv "${src}.pdf" "${OUT[$src]}.pdf"
done

echo
echo "Fertig. Erzeugte PDFs:"
ls -la webseite-uebersetzen.pdf traduire-site-web.pdf tradurre-sito-web.pdf
