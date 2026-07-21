#!/usr/bin/env bash
# Spawn one generic crewmate in an isolated git worktree and tmux window.
# Usage: dispatch-spawn.sh --task ID --kind ship|scout --project PATH [--profile NAME] [--harness NAME] [--autonomy supervised|trusted] [--branch REF]

set -euo pipefail
# shellcheck source=lib.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)/lib.sh"

TASK_ID=""
KIND=""
PROJECT_ARG=""
PROFILE="none"
HARNESS=""
AUTONOMY=""
BRANCH=""
BRANCH_EXPLICIT=false

while (($#)); do
  case "$1" in
    --task) [[ $# -ge 2 ]] || fail "--task requires a value"; TASK_ID="$2"; shift 2 ;;
    --kind) [[ $# -ge 2 ]] || fail "--kind requires a value"; KIND="$2"; shift 2 ;;
    --project) [[ $# -ge 2 ]] || fail "--project requires a value"; PROJECT_ARG="$2"; shift 2 ;;
    --profile) [[ $# -ge 2 ]] || fail "--profile requires a value"; PROFILE="$2"; shift 2 ;;
    --harness) [[ $# -ge 2 ]] || fail "--harness requires a value"; HARNESS="$2"; shift 2 ;;
    --autonomy) [[ $# -ge 2 ]] || fail "--autonomy requires a value"; AUTONOMY="$2"; shift 2 ;;
    --branch) [[ $# -ge 2 ]] || fail "--branch requires a value"; BRANCH="$2"; BRANCH_EXPLICIT=true; shift 2 ;;
    -h|--help) sed -n '2,3p' "$0"; exit 0 ;;
    *) fail "unknown option: $1" ;;
  esac
done

[[ -n "$TASK_ID" ]] || fail "--task is required"
[[ -n "$KIND" ]] || fail "--kind is required"
[[ -n "$PROJECT_ARG" ]] || fail "--project is required"
validate_id "task ID" "$TASK_ID"
[[ "$KIND" == "ship" || "$KIND" == "scout" ]] || fail "--kind must be ship or scout"
validate_id "profile" "$PROFILE"
[[ "$PROFILE" == "none" || -f "$DISPATCHER_HOME/profiles/$PROFILE.md" ]] || \
  fail "specialist profile not found: $DISPATCHER_HOME/profiles/$PROFILE.md"

HARNESS="${HARNESS:-$(read_config harness kiro-cli)}"
AUTONOMY="${AUTONOMY:-$(read_config autonomy supervised)}"
validate_id "harness" "$HARNESS"
[[ "$AUTONOMY" == "supervised" || "$AUTONOMY" == "trusted" ]] || \
  fail "autonomy must be supervised or trusted"
[[ -x "$DISPATCHER_HOME/harnesses/$HARNESS.sh" ]] || \
  fail "harness adapter is not executable: $DISPATCHER_HOME/harnesses/$HARNESS.sh"

require_command git
require_command tmux
ensure_state_dirs
BRIEF_FILE="$STATE_ACTIVE/$TASK_ID.brief.md"
META_FILE="$STATE_ACTIVE/$TASK_ID.meta"
STATUS_FILE="$STATE_ACTIVE/$TASK_ID.status"
[[ -f "$BRIEF_FILE" ]] || fail "create the task brief first: $BRIEF_FILE"
[[ ! -e "$META_FILE" && ! -e "$STATUS_FILE" ]] || fail "task is already active: $TASK_ID"

PROJECT="$(git -C "$PROJECT_ARG" rev-parse --show-toplevel 2>/dev/null)" || \
  fail "not a git repository: $PROJECT_ARG"
PROJECT="$(cd "$PROJECT" && pwd -P)"

if [[ -z "$BRANCH" ]]; then
  BRANCH="dispatcher/$TASK_ID"
fi
git check-ref-format --branch "$BRANCH" >/dev/null 2>&1 || fail "invalid branch name: $BRANCH"

BRANCH_EXISTS=false
if git -C "$PROJECT" show-ref --verify --quiet "refs/heads/$BRANCH"; then
  BRANCH_EXISTS=true
  [[ "$BRANCH_EXPLICIT" == true ]] || \
    fail "default branch already exists: $BRANCH (use a new task ID or pass --branch explicitly to resume it)"
fi

PROJECT_NAME="$(basename "$PROJECT")"
PROJECT_HASH="$(printf '%s' "$PROJECT" | hash_text)"
WORKTREE_ROOT="${DISPATCHER_WORKTREE_ROOT:-${TMPDIR:-/tmp}/kiro-dispatcher-worktrees}"
WORKTREE="${WORKTREE_ROOT%/}/${PROJECT_NAME}-${PROJECT_HASH}/$TASK_ID"
[[ ! -e "$WORKTREE" ]] || fail "worktree path already exists: $WORKTREE"
mkdir -p "$(dirname "$WORKTREE")"

CREATED_WORKTREE=false
cleanup_on_error() {
  local rc=$?
  if [[ "$rc" -ne 0 && "$CREATED_WORKTREE" == true && -d "$WORKTREE" ]]; then
    if [[ -z "$(git -C "$WORKTREE" status --porcelain 2>/dev/null)" ]]; then
      git -C "$PROJECT" worktree remove "$WORKTREE" >/dev/null 2>&1 || true
    fi
  fi
  if [[ "$rc" -ne 0 ]]; then
    rm -f "$META_FILE" "$STATUS_FILE"
  fi
  exit "$rc"
}
trap cleanup_on_error EXIT

if [[ "$BRANCH_EXISTS" == true ]]; then
  git -C "$PROJECT" worktree add "$WORKTREE" "$BRANCH"
else
  git -C "$PROJECT" worktree add -b "$BRANCH" "$WORKTREE" HEAD
fi
CREATED_WORKTREE=true

SESSION="${DISPATCHER_TMUX_SESSION:-$(read_config tmux-session kiro-dispatcher)}"
validate_id "tmux session" "$SESSION"
WINDOW="crew-$TASK_ID"
if tmux has-session -t "$SESSION" 2>/dev/null && \
   tmux list-windows -t "$SESSION" -F '#{window_name}' | grep -Fxq "$WINDOW"; then
  fail "tmux window already exists: $SESSION:$WINDOW"
fi

cat >"$META_FILE" <<EOF
task=$TASK_ID
kind=$KIND
profile=$PROFILE
project=$PROJECT
worktree=$WORKTREE
branch=$BRANCH
harness=$HARNESS
autonomy=$AUTONOMY
session=$SESSION
window=$WINDOW
spawned_at=$(date -u +%Y-%m-%dT%H:%M:%SZ)
EOF
printf 'spawned: awaiting harness start\n' >"$STATUS_FILE"

if ! tmux has-session -t "$SESSION" 2>/dev/null; then
  tmux new-session -d -s "$SESSION" -n control
fi
printf -v RUN_CMD 'DISPATCHER_HOME=%q exec %q %q' \
  "$DISPATCHER_HOME" "$DISPATCHER_HOME/bin/dispatch-run-crew.sh" "$TASK_ID"
tmux new-window -d -t "$SESSION" -n "$WINDOW" "$RUN_CMD"

trap - EXIT
printf 'Spawned task %s\n' "$TASK_ID"
printf '  kind: %s\n  profile: %s\n  harness: %s\n  autonomy: %s\n' \
  "$KIND" "$PROFILE" "$HARNESS" "$AUTONOMY"
printf '  branch: %s\n  worktree: %s\n  tmux: %s:%s\n' "$BRANCH" "$WORKTREE" "$SESSION" "$WINDOW"
