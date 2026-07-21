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

AGENT_CONFIG="$ROOT/.kiro/agents/dispatcher.json"
if command -v python3 >/dev/null 2>&1; then
  if python3 -m json.tool "$AGENT_CONFIG" >/dev/null; then
    printf 'workspace agent JSON: OK\n'
  else
    FAILED=1
  fi
fi
if [[ ! -f "$ROOT/DISPATCHER.md" ]] || ! grep -Fq 'file://DISPATCHER.md' "$AGENT_CONFIG"; then
  printf 'Workspace agent resource is missing or incorrect.\n' >&2
  FAILED=1
else
  printf 'workspace agent resource: OK\n'
fi
if command -v kiro-cli >/dev/null 2>&1; then
  if (cd "$ROOT" && kiro-cli agent validate --path .kiro/agents/dispatcher.json); then
    printf 'kiro-cli agent validation: OK\n'
  else
    FAILED=1
  fi
else
  printf 'kiro-cli agent validation: SKIP (not installed)\n'
fi

if grep -RInE --exclude-dir=.git --exclude='*.example' --exclude='lint.sh' \
  'fm-(spawn|watch|status|brief|teardown)|bin/dispatcher\.sh|agents/(developer|reviewer|scout)\.md|--profile (developer|reviewer|scout)|q chat|kiro chat --prompt' \
  "$ROOT"; then
  printf 'Found obsolete fixed-role or invalid command references.\n' >&2
  FAILED=1
else
  printf 'obsolete-reference check: OK\n'
fi

exit "$FAILED"
