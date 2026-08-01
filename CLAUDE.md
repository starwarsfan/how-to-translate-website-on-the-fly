# CLAUDE.md

Kontext und Regeln für die Arbeit an diesem Repository.

## Wichtigste Regel

**Niemals automatisch `git push` ausführen.** Commits dürfen erstellt werden,
wenn der Nutzer explizit danach fragt – gepusht wird ausschliesslich manuell
durch den Nutzer selbst. Nach einem Commit nicht von sich aus pushen und auch
nicht danach fragen, es sei denn, der Nutzer bittet explizit darum.

## Projektzweck

Dieses Repository enthält eine Anleitung für Mitglieder des Vereins (Webseite
https://bonsai-vsb.ch/), wie sie sich Webseiteninhalte direkt im Browser in
ihre eigene Sprache übersetzen lassen können – ohne zusätzliche Software.
Zielgruppe sind insbesondere technisch weniger versierte Mitglieder. Die
Anleitung ist inhaltlich nicht auf bonsai-vsb.ch beschränkt, sondern gilt
für beliebige Webseiten.

## Struktur

- `webseite-uebersetzen-de.md` – deutsche Originalversion (Quelle)
- `webseite-uebersetzen-fr.md` – französische Übersetzung
- `webseite-uebersetzen-it.md` – italienische Übersetzung
- `.github/workflows/release.yml` – GitHub-Actions-Workflow für den PDF-Release
- `scripts/build-pdfs.sh` – einzige Quelle der Konvertierungslogik MD→PDF;
  wird sowohl vom Workflow als auch für lokale Tests aufgerufen (kein
  duplizierter Code)
- `pages/index.html` – statische Startseite für GitHub Pages, verlinkt alle
  drei PDFs; wird im `publish-pages`-Job unverändert neben die generierten
  PDFs kopiert (kein Templating, da die Ziel-Dateinamen fix sind)

Alle drei Sprachversionen sind identisch strukturiert (gleiche Kapitel/
Reihenfolge: Chrome, Edge, Firefox, Safari macOS, Safari iOS, Android Chrome,
FAQ). Bei inhaltlichen Änderungen an der deutschen Quelle müssen `-fr.md` und
`-it.md` entsprechend nachgezogen werden, damit die drei Versionen synchron
bleiben.

## PDF-Release-Workflow

Bei jedem Tag-Push auf `main` (`.github/workflows/release.yml`) wird
automatisch ein GitHub Release erstellt:

1. Prüfung, dass der Tag-Commit auf `main` liegt.
2. Aufruf von `scripts/build-pdfs.sh`, das die drei Markdown-Dateien via
   [`md-to-pdf`](https://github.com/simonhaenisch/md-to-pdf) (Chromium-basiert,
   kein LaTeX nötig, rendert Umlaute/Akzente korrekt) in PDF konvertiert.
   Läuft mit `--no-sandbox --disable-setuid-sandbox`, da Chrome/Puppeteer in
   manchen Umgebungen (z. B. Ubuntu 23.10+ mit AppArmor-Restriktion für
   unprivilegierte User-Namespaces, oder als root in CI) sonst mit
   "No usable sandbox!" abstürzt.
3. Veröffentlichung als GitHub-Release-Assets, benannt in der jeweiligen
   Sprache (nicht identisch zum Quelldateinamen):

   | Quelle | PDF-Asset |
   | --- | --- |
   | `webseite-uebersetzen-de.md` | `webseite-uebersetzen.pdf` |
   | `webseite-uebersetzen-fr.md` | `traduire-site-web.pdf` |
   | `webseite-uebersetzen-it.md` | `tradurre-sito-web.pdf` |

Das Tag-Format ist nicht vorgeschrieben (kein CalVer-Zwang) – jeder Tag auf
`main` löst den Release-Build aus. Vorbild für den Workflow-Aufbau (Tag-Trigger,
Origin-Branch-Validierung, Release über `softprops/action-gh-release`) ist das
Vorgehen im OpenBridgeServer-Repository, hier jedoch bewusst schlank gehalten
(kein Docker, keine CalVer-/RC-Logik).

### GitHub Pages für Direktanzeige der PDFs

GitHub liefert Release-Assets grundsätzlich mit
`Content-Disposition: attachment` aus – das erzwingt in jedem Browser einen
Download-Dialog und lässt sich nicht per Workflow-Konfiguration abschalten.
Deshalb gibt es einen zweiten Job `publish-pages`, der dieselben (im
`release`-Job einmal gebauten, per `actions/upload-artifact` durchgereichten)
PDFs zusätzlich auf GitHub Pages veröffentlicht. Dort werden sie ohne
erzwungenen Download direkt im Browser angezeigt, unter stabilen URLs wie
`https://starwarsfan.github.io/how-to-translate-website-on-the-fly/webseite-uebersetzen.pdf`.

Voraussetzung (einmalig, nicht per Workflow möglich, GitHub-Repo-Settings):

1. Unter *Pages* als Source **"GitHub Actions"** auswählen.
2. Unter *Environments → github-pages → Deployment branches and tags* eine
   Tag-Regel mit Pattern `*` hinzufügen. Die von GitHub beim ersten
   Pages-Setup automatisch angelegte `github-pages`-Environment erlaubt per
   Default nur Deployments vom Default-Branch – ohne diese Regel schlägt der
   `publish-pages`-Job mit „Tag ... is not allowed to deploy to github-pages
   due to environment protection rules" fehl.

### PDF-Fusszeile

`build-pdfs.sh` baut über Puppeteers `--pdf-options` (headerTemplate leer,
footerTemplate mit Inline-HTML) eine Fusszeile mit Version, Build-Datum und
Seitenzahl, z. B. „Version v1.0.0 · 01.08.2026 · 1 / 3“. Die Version kommt aus
der Env-Var `VERSION` – im Workflow gesetzt auf `${{ github.ref_name }}`
(also den Tag), lokal ohne gesetzte Variable per Fallback auf
`git describe --tags --always` bzw. `dev`. Das JSON für `--pdf-options` wird
bewusst über einen kleinen `node -e`-Einzeiler statt per Shell-String gebaut,
um Quoting-Probleme mit den verschachtelten Anführungszeichen zu vermeiden.
