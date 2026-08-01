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

Alle drei Sprachversionen sind identisch strukturiert (gleiche Kapitel/
Reihenfolge: Chrome, Edge, Firefox, Safari macOS, Safari iOS, Android Chrome,
FAQ). Bei inhaltlichen Änderungen an der deutschen Quelle müssen `-fr.md` und
`-it.md` entsprechend nachgezogen werden, damit die drei Versionen synchron
bleiben.

## PDF-Release-Workflow

Bei jedem Tag-Push auf `main` (`.github/workflows/release.yml`) wird
automatisch ein GitHub Release erstellt:

1. Prüfung, dass der Tag-Commit auf `main` liegt.
2. Konvertierung der drei Markdown-Dateien in PDF via
   [`md-to-pdf`](https://github.com/simonhaenisch/md-to-pdf) (Chromium-basiert,
   kein LaTeX nötig, rendert Umlaute/Akzente korrekt).
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
