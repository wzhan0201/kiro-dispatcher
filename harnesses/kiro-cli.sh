#!/usr/bin/env bash
# Kiro CLI harness adapter.
# Contract: adapter <prompt> <supervised|trusted>

set -euo pipefail

PROMPT="${1:-}"
AUTONOMY="${2:-supervised}"

[[ -n "$PROMPT" ]] || { echo "Kiro adapter requires a prompt" >&2; exit 2; }
command -v kiro-cli >/dev/null 2>&1 || {
  echo "kiro-cli not found on PATH" >&2
  exit 127
}

case "$AUTONOMY" in
  supervised)
    exec kiro-cli chat "$PROMPT"
    ;;
  trusted)
    exec kiro-cli chat --no-interactive --trust-all-tools "$PROMPT"
    ;;
  *)
    echo "Unsupported autonomy '$AUTONOMY'; expected supervised or trusted" >&2
    exit 2
    ;;
esac
