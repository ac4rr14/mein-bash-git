#!/usr/bin/env bash
set -euo pipefail
git rev-parse --is-inside-work-tree >/dev/null
stamp=$(date +%F_%H-%M-%S)
out="changed_${stamp}.txt"
git diff --name-only HEAD > "$out"
git ls-files --others --exclude-standard >> "$out"
echo "Geschrieben nach: $out"