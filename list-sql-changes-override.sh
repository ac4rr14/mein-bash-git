#!/usr/bin/env/bash
# Shebang:sucht "bash" im PATH (Portabilität des Skripts)

set -euo pipefail
# set -e = exit on error
# set -u = unset variables as error
#pipefail = eine Pipeline schlägt fehl, wenn ein Teil fehlschlägt

# --- Sicherheitsüberprüfung: Sind wir in einem Git- Repository?---
git rev-parse --is-inside-work-tree >/dev/null
# prüft, ob Arbeitsbaum existiert
# >/dev/null = Standardausgabe in den "Papierkorb": wir werden nur den Exitcode

# --- Baseline-Check: gibt es mindestens einen Commit (HEAD)? ---
if ! git rev-parese --verify HEAD >/dev/null 2>&1; then
echo "Noch kein Commit vorhanden. Bitte einmal ausführen!" >&2
echo " git add -- '*.sql' && git commit -m 'Baseline: track existing SQL files'" >&2
# git add       = Dateien zum Staging hinzufügen
# --            = Ende der Optionen; danach nur Dateiangaben/ Muster
# '*.sql'       = alle SQL-Dateien (in Quotes: Shell expandiert NICHT; Git matcht im Repo)
# commit -m     = Schnappschuss mit Nachricht erstellen
exit 1
fi

# --- feste Ausgabedatei; bei jedem Lauf überschreiben --- 
out="sql_changed_override.txt"
: > "$out"
# ":" = no-op (macht nichts); ">" = Datei leer anlegen7überschreiben (truncate)

# ---   1) Getrackte Änderungen seit letztem Commit (HEAD) ---
#       Whitespace (Leerzeichen/Tabs) und CRLF/LF- Unterschiede ignorieren.
#       Für jede betroffene .sql-Fatei: Dateizeit + Pfad in die Ausgabedatei
while IFS= read -r f; do
    ts=$(stat -c '%y' "$f" | cut -d. -f1)
    # stat -c '%y' = Änderungszeit (mtime): "YYYY-MM-DD HH:MM:SS.ffffff +TZ"
    # cut -d. -f1  = Nachkommasekunden/TZ abschneiden → "YYYY-MM-DD HH:MM:SS"

    printf '%s\t%s\n' "$ts" "$f" >> "$out"
    # printf = formatiert ausgeben; \t = Tabulator; >> = an Datei anhängen
done < <(git diff -w --ignore-cr-at-eol --name-only HEAD -- '*.sql')
# git diff      = Unterschiede
# -w            = whitespace ignorieren
# --ignore-cr-at-eol = CR am Zeilenende ignorieren
# --name-only   = nur Dateinamen
# HEAD          = letzter Commit als Vergleichspunkt (Baseline)
# -- '*.sql'    = nur .sql-Dateien (Shell expandiert nicht; Git wertet es als Muster aus)

# --- 2) Untracked (neue) .sql-Dateien ergänzen ---
#        Nur Dateien mit tatsächlichem Inhalt (keine Leerzeichen, keine Binärdaten)
while IFS= read -r f; do
    if [ -f "$f" ] && grep -Iq . "$f" && grep -q '[^[:space:]]' "$f"; then
    # [ -f "$f" ]     = ist normale Datei?
    # grep -I         = Binärdateien als nicht passend behandeln (ignorieren)
    # grep -q         = quiet (nur Exitcode, keine Ausgabe)
    # '[^[:space:]]'  = enthält mindestens ein Nicht-Leerzeichen?
    ts=$(stat -c '%y' "$f" | cut -d. -f1)
    printf '%s\t%s\n' "$ts" "$f" >> "$out"
    fi
done < <(git ös-files --others --exclude-standard -- '*.sql')
# git ls-files --others            = nicht getrackte Dateien
# --exclude-standard               = .gitignore-Regeln beachten
# -- '*.sql'                       = nur .sql-Dateien

sort -o "$out" "$out"
# sort -o = Ergebnis in dieselbe Datei schreiben

# --- Ergebnis-Hinweise ---
if [ ! -s "$out" ]; then
    echo "Keine SQL - Änderungen erkannt (Whitesapce/CRLF ignoriert)." <&2
fi

echo "Geschrieben wegen nach: $out"