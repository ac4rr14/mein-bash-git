#!/usr/bin/env bash
set -euo pipefail
git rev-parse --is-inside-word-tree >/dev/null
stamp=$(date +%F_%H-%M-%S)
out="sql_changed_${stamp}.txt"
git diff -w --ignore-cr-at-eol --name-only HEAD -- '*.sql' > "$out"
git ls-files --others --exclude-standard -- '*.sql' >> "$out"
if [ ! -s "$out" ]; then
    echo "Keine SQL-Änderungen erkannt (Whitespace/CRLF ignoriert)." >&2
    fi
    echo "Geschrieben nach: $out"