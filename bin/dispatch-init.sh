#!/usr/bin/env bash
# Initialize local, gitignored Kiro Dispatcher state and config.
# Usage: dispatch-init.sh

set -euo pipefail
# shellcheck source=lib.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)/lib.sh"

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  sed -n '2,3p' "$0"
  exit 0
fi
[[ $# -eq 0 ]] || fail "unknown argument: $1"

ensure_state_dirs
mkdir -p "$DISPATCHER_HOME/config" "$DISPATCHER_HOME/data"

if [[ ! -f "$DISPATCHER_HOME/config/harness" ]]; then
  printf 'kiro-cli\n' >"$DISPATCHER_HOME/config/harness"
fi
if [[ ! -f "$DISPATCHER_HOME/config/autonomy" ]]; then
  printf 'supervised\n' >"$DISPATCHER_HOME/config/autonomy"
fi
if [[ ! -f "$DISPATCHER_HOME/data/captain.md" ]]; then
  cat >"$DISPATCHER_HOME/data/captain.md" <<'EOF'
# Local user preferences

<!-- Record durable communication, validation, and merge preferences here. -->
EOF
fi
if [[ ! -f "$DISPATCHER_HOME/data/learnings.md" ]]; then
  cat >"$DISPATCHER_HOME/data/learnings.md" <<'EOF'
# Local operational learnings

<!-- Keep dated, evidence-backed facts that improve future dispatches. -->
EOF
fi

printf 'Initialized Kiro Dispatcher at %s\n' "$DISPATCHER_HOME"
printf '  harness: %s\n' "$(read_config harness kiro-cli)"
printf '  autonomy: %s\n' "$(read_config autonomy supervised)"
