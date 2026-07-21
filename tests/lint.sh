#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
FAILED=0

while IFS= read -r -d '' FILE; do
  if bash -n "$FILE"; then
    printf 'bash -n: OK %s\n' "${FILE#"$ROOT"/}"
  else
    FAILED=1
  fi
done < <(find "$ROOT/bin" "$ROOT/harnesses" "$ROOT/tests" -type f -name '*.sh' -print0)

if command -v shellcheck >/dev/null 2>&1; then
  while IFS= read -r -d '' FILE; do
    shellcheck -x -P "$ROOT/bin" "$FILE" || FAILED=1
  done < <(find "$ROOT/bin" "$ROOT/harnesses" "$ROOT/tests" -type f -name '*.sh' -print0)
else
  printf 'shellcheck: SKIP (not installed)\n'
fi

if grep -RInE --exclude-dir=.git --exclude='*.example' --exclude='lint.sh' \
  'fm-(spawn|watch|status|brief|teardown)|agents/(developer|reviewer|scout)\.md|--profile (developer|reviewer|scout)|q chat|kiro chat --prompt' \
  "$ROOT"; then
  printf 'Found obsolete fixed-role or invalid command references.\n' >&2
  FAILED=1
else
  printf 'obsolete-reference check: OK\n'
fi

exit "$FAILED"
