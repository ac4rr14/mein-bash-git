#!/usr/bin/env bash
set -euo pipefail
git rev-parse --is-inside-work-tree >/dev/null
stamp=$(date +%F_%H-%M-%S)
out="changed_strict_${stamp}.txt"
git diff -w --ignore-cr-at-eol --name-only HEAD > "$out"
while IFS= read -r f; do
    if [ -f "$f" ] && grep -Iq . "$f" && grep -q '[^[:space:]]' "$f"; 
        then
        echo "$f" >> "$out"
    fi
    done < <(git ls-files --others --exclude-standard)
    echo "Geschrieben nach : $out"