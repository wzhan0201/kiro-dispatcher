#!/usr/bin/env bash
# Launch the dispatcher in Kiro CLI.
# Usage: dispatcher.sh [--trusted] [initial request...]

set -euo pipefail
# shellcheck source=lib.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)/lib.sh"

TRUSTED=false
if [[ "${1:-}" == "--trusted" ]]; then
  TRUSTED=true
  shift
fi
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  sed -n '2,3p' "$0"
  exit 0
fi

require_command kiro-cli
ensure_state_dirs

PROMPT="$(cat "$DISPATCHER_HOME/DISPATCHER.md")"
if [[ -f "$DISPATCHER_HOME/data/captain.md" ]]; then
  PROMPT+=$'\n\n## Local user preferences\n\n'
  PROMPT+="$(cat "$DISPATCHER_HOME/data/captain.md")"
fi
if (($#)); then
  PROMPT+=$'\n\n## Initial user request\n\n'
  PROMPT+="$*"
fi

cd "$DISPATCHER_HOME"
if [[ "$TRUSTED" == true ]]; then
  exec kiro-cli chat --trust-all-tools "$PROMPT"
else
  exec kiro-cli chat "$PROMPT"
fi
