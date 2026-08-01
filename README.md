# Wie übersetze ich eine Webseite direkt im Browser?

Dieses Repository enthält eine Anleitung für Vereinsmitglieder, wie sie sich Webseiteninhalte automatisch im Browser in ihre eigene Sprache übersetzen lassen können – ohne zusätzliche Software oder Apps.

**Hintergrund:** Die Vereinswebseite (https://bonsai-vsb.ch/) wird auf Deutsch gepflegt. Da Vereinsmitglieder in der ganzen Schweiz verteilt sind, soll diese Anleitung insbesondere weniger technikaffinen Mitgliedern helfen, die Seite bequem in ihrer Sprache zu lesen. Die Anleitung ist nicht auf bonsai-vsb.ch beschränkt, sondern gilt grundsätzlich für beliebige Webseiten.

## Dateien

| Datei | Sprache |
| --- | --- |
| [`webseite-uebersetzen-de.md`](webseite-uebersetzen-de.md) | Deutsch (Original) |
| [`webseite-uebersetzen-fr.md`](webseite-uebersetzen-fr.md) | Französisch |
| [`webseite-uebersetzen-it.md`](webseite-uebersetzen-it.md) | Italienisch |

## Inhalt der Anleitung

Jede Sprachversion ist identisch aufgebaut und beschreibt Schritt für Schritt, wie man die Übersetzungsfunktion aktiviert:

1. Computer – Google Chrome
2. Computer – Microsoft Edge
3. Computer – Mozilla Firefox
4. Computer (Mac) – Safari
5. iPhone / iPad – Safari
6. Android-Handy/-Tablet – Google Chrome
7. Häufige Fragen

## Status

- [x] Deutsche Ausgangsversion erstellt
- [x] Übersetzung Französisch
- [x] Übersetzung Italienisch

## Workflow bei Änderungen

Die deutsche Version (`webseite-uebersetzen-de.md`) ist die Quelle. Bei inhaltlichen Änderungen (z. B. neue Browser-Version, geänderte Menüführung) müssen `-fr.md` und `-it.md` entsprechend nachgezogen werden, damit alle drei Versionen synchron bleiben.

## PDF-Release

Über `.github/workflows/release.yml` wird bei jedem Tag auf `main` automatisch ein GitHub Release erstellt:

1. Der Tag-Commit wird geprüft (muss auf `main` liegen).
2. `scripts/build-pdfs.sh` konvertiert alle drei Markdown-Dateien per [`md-to-pdf`](https://github.com/simonhaenisch/md-to-pdf) in PDFs. Dasselbe Skript dient auch dem lokalen Test (siehe unten) – so gibt es nur eine Stelle mit der Konvertierungslogik.
3. Die PDFs werden als Assets an ein GitHub Release mit dem Tag-Namen angehängt – benannt in der jeweiligen Sprache:

| Quelle | PDF-Asset |
| --- | --- |
| `webseite-uebersetzen-de.md` | `webseite-uebersetzen.pdf` |
| `webseite-uebersetzen-fr.md` | `traduire-site-web.pdf` |
| `webseite-uebersetzen-it.md` | `tradurre-sito-web.pdf` |

Zusätzlich werden dieselben PDFs auf GitHub Pages veröffentlicht. Klickt man auf einen Release-Asset-Link direkt, erzwingt GitHub einen Download (`Content-Disposition: attachment`, nicht abschaltbar). Über GitHub Pages öffnen sich die PDFs dagegen direkt im Browser:

- https://starwarsfan.github.io/how-to-translate-website-on-the-fly/webseite-uebersetzen.pdf
- https://starwarsfan.github.io/how-to-translate-website-on-the-fly/traduire-site-web.pdf
- https://starwarsfan.github.io/how-to-translate-website-on-the-fly/tradurre-sito-web.pdf

Diese Links sind stabil und zeigen nach jedem Release automatisch den neuesten Stand – ideal zum Verteilen an die Vereinsmitglieder.

**Einmaliger manueller Schritt:** In den Repo-Settings unter *Pages* als Source **"GitHub Actions"** auswählen (Settings → Pages → Build and deployment → Source). Danach übernimmt der Workflow das Deployment automatisch bei jedem Tag.

Ein neues Release erstellen:

```bash
git checkout main
git pull
git tag v1.0.0
git push origin v1.0.0
```

Das Tag-Format ist nicht vorgeschrieben (anders als beim CalVer-Schema von OpenBridgeServer) – jeder Tag auf `main` löst den Release-Build aus.

Jedes PDF enthält eine Fusszeile mit Version, Build-Datum und Seitenzahl
(z. B. „Version v1.0.0 · 01.08.2026 · 1 / 3“). Im Release-Workflow ist die
Version der Tag-Name (`VERSION: ${{ github.ref_name }}`); lokal fällt sie
mangels Tag auf die Ausgabe von `git describe --tags --always` bzw. `dev`
zurück.

### Lokal testen

Die PDF-Konvertierung (ohne Release-Erstellung) lässt sich lokal nachvollziehen:

```bash
./scripts/build-pdfs.sh
# oder mit expliziter Version in der Fusszeile:
VERSION=v1.0.0 ./scripts/build-pdfs.sh
```

Das Skript ist die einzige Quelle für die Konvertierungslogik – der Release-Job ruft es 1:1 auf. Es legt die drei PDFs im Repo-Root ab (via `.gitignore` von Git ignoriert).
