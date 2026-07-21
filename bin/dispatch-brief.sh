#!/usr/bin/env bash
# Create a standalone task brief.
# Usage: dispatch-brief.sh --task ID --kind ship|scout --title TITLE [--body TEXT | --file PATH]

set -euo pipefail
# shellcheck source=lib.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)/lib.sh"

TASK_ID=""
KIND=""
TITLE=""
BODY=""
FROM_FILE=""

while (($#)); do
  case "$1" in
    --task) [[ $# -ge 2 ]] || fail "--task requires a value"; TASK_ID="$2"; shift 2 ;;
    --kind) [[ $# -ge 2 ]] || fail "--kind requires a value"; KIND="$2"; shift 2 ;;
    --title) [[ $# -ge 2 ]] || fail "--title requires a value"; TITLE="$2"; shift 2 ;;
    --body) [[ $# -ge 2 ]] || fail "--body requires a value"; BODY="$2"; shift 2 ;;
    --file) [[ $# -ge 2 ]] || fail "--file requires a value"; FROM_FILE="$2"; shift 2 ;;
    -h|--help)
      sed -n '2,3p' "$0"
      exit 0
      ;;
    *) fail "unknown option: $1" ;;
  esac
done

[[ -n "$TASK_ID" ]] || fail "--task is required"
[[ -n "$KIND" ]] || fail "--kind is required"
[[ -n "$TITLE" ]] || fail "--title is required"
validate_id "task ID" "$TASK_ID"
[[ "$KIND" == "ship" || "$KIND" == "scout" ]] || fail "--kind must be ship or scout"
[[ -z "$BODY" || -z "$FROM_FILE" ]] || fail "use either --body or --file, not both"
[[ -z "$FROM_FILE" || -f "$FROM_FILE" ]] || fail "brief source file not found: $FROM_FILE"

ensure_state_dirs
BRIEF_FILE="$STATE_ACTIVE/$TASK_ID.brief.md"
[[ ! -e "$BRIEF_FILE" ]] || fail "brief already exists: $BRIEF_FILE"

{
  printf '# Task Brief: %s\n\n' "$TITLE"
  printf -- "- Task ID: \`%s\`\n" "$TASK_ID"
  printf -- "- Kind: \`%s\`\n" "$KIND"
  printf -- "- Created: \`%s\`\n\n" "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  printf '## Objective and scope\n\n'
  if [[ -n "$FROM_FILE" ]]; then
    cat "$FROM_FILE"
    printf '\n'
  elif [[ -n "$BODY" ]]; then
    printf '%s\n' "$BODY"
  else
    printf '<!-- Add a complete, standalone objective, scope, constraints, and relevant paths/refs. -->\n'
  fi
  cat <<'EOF'

## Expected deliverable

<!-- For ship: focused code changes and a commit. For scout: an evidence-based report. -->

## Validation

<!-- List the exact tests, checks, or evidence required. -->

## Completion criteria

<!-- State the observable conditions that make this task complete. -->
EOF
} >"$BRIEF_FILE"

printf 'Created brief: %s\n' "$BRIEF_FILE"
