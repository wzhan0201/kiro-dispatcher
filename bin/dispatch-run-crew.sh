#!/usr/bin/env bash
# Internal runner invoked inside a crewmate tmux window.
# Usage: dispatch-run-crew.sh TASK_ID

set -euo pipefail
# shellcheck source=lib.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)/lib.sh"

TASK_ID="${1:-}"
[[ -n "$TASK_ID" ]] || fail "task ID is required"
validate_id "task ID" "$TASK_ID"

META_FILE="$STATE_ACTIVE/$TASK_ID.meta"
STATUS_FILE="$STATE_ACTIVE/$TASK_ID.status"
BRIEF_FILE="$STATE_ACTIVE/$TASK_ID.brief.md"
REPORT_FILE="$STATE_ACTIVE/$TASK_ID.report.md"
[[ -f "$META_FILE" ]] || fail "metadata not found: $META_FILE"
[[ -f "$BRIEF_FILE" ]] || fail "brief not found: $BRIEF_FILE"

WORKTREE="$(meta_value "$META_FILE" worktree)"
PROJECT="$(meta_value "$META_FILE" project)"
BRANCH="$(meta_value "$META_FILE" branch)"
KIND="$(meta_value "$META_FILE" kind)"
PROFILE="$(meta_value "$META_FILE" profile)"
HARNESS="$(meta_value "$META_FILE" harness)"
AUTONOMY="$(meta_value "$META_FILE" autonomy)"
ADAPTER="$DISPATCHER_HOME/harnesses/$HARNESS.sh"

[[ -d "$WORKTREE" ]] || fail "worktree missing: $WORKTREE"
[[ -x "$ADAPTER" ]] || fail "harness adapter is not executable: $ADAPTER"

PROFILE_TEXT=""
if [[ "$PROFILE" != "none" ]]; then
  PROFILE_FILE="$DISPATCHER_HOME/profiles/$PROFILE.md"
  [[ -f "$PROFILE_FILE" ]] || fail "specialist profile missing: $PROFILE_FILE"
  PROFILE_TEXT="$(cat "$PROFILE_FILE")"
fi

PROMPT="$(cat "$DISPATCHER_HOME/crew/CREWMATE.md")"
if [[ -n "$PROFILE_TEXT" ]]; then
  PROMPT+=$'\n\n---\n\n## Optional specialist overlay\n\n'
  PROMPT+="$PROFILE_TEXT"
fi
PROMPT+=$'\n\n---\n\n## Authoritative task brief\n\n'
PROMPT+="$(cat "$BRIEF_FILE")"
PROMPT+=$'\n\n---\n\n## Assignment metadata\n\n'
PROMPT+="- Kind: $KIND
- Project root: $PROJECT
- Assigned worktree: $WORKTREE
- Assigned branch: $BRANCH
- Task report is captured by the dispatcher; provide the required report as your final response."

printf 'running: harness=%s autonomy=%s\n' "$HARNESS" "$AUTONOMY" >"$STATUS_FILE"
printf 'Kiro Dispatcher crew task %s\n' "$TASK_ID"
printf '  kind: %s\n  profile: %s\n  harness: %s\n  autonomy: %s\n  worktree: %s\n\n' \
  "$KIND" "$PROFILE" "$HARNESS" "$AUTONOMY" "$WORKTREE"

cd "$WORKTREE"
set +e
"$ADAPTER" "$PROMPT" "$AUTONOMY" 2>&1 | tee "$REPORT_FILE"
HARNESS_EXIT=${PIPESTATUS[0]}
set -e

if [[ "$HARNESS_EXIT" -ne 0 ]]; then
  printf 'failed: harness exit=%s; report=%s\n' "$HARNESS_EXIT" "$REPORT_FILE" >"$STATUS_FILE"
  exit "$HARNESS_EXIT"
fi

DECLARED_STATUS="$(grep -E '^DISPATCH_STATUS: (done|blocked|failed)$' "$REPORT_FILE" | tail -n 1 | awk '{print $2}' || true)"
case "$DECLARED_STATUS" in
  blocked) printf 'blocked: crewmate reported a blocker; report=%s\n' "$REPORT_FILE" >"$STATUS_FILE" ;;
  failed) printf 'failed: crewmate reported failure; report=%s\n' "$REPORT_FILE" >"$STATUS_FILE" ;;
  *) printf 'done: harness exited successfully; report=%s\n' "$REPORT_FILE" >"$STATUS_FILE" ;;
esac
