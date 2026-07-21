#!/usr/bin/env bash
# Remove a task's tmux window and worktree, then archive its state.
# Usage: dispatch-teardown.sh TASK_ID [--force]

set -euo pipefail
# shellcheck source=lib.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)/lib.sh"

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  sed -n '2,3p' "$0"
  exit 0
fi
TASK_ID="${1:-}"
[[ -n "$TASK_ID" ]] || fail "task ID is required"
shift
FORCE=false
while (($#)); do
  case "$1" in
    --force) FORCE=true; shift ;;
    *) fail "unknown option: $1" ;;
  esac
done
validate_id "task ID" "$TASK_ID"
ensure_state_dirs

META_FILE="$STATE_ACTIVE/$TASK_ID.meta"
[[ -f "$META_FILE" ]] || fail "active task metadata not found: $META_FILE"
WORKTREE="$(meta_value "$META_FILE" worktree)"
PROJECT="$(meta_value "$META_FILE" project)"
BRANCH="$(meta_value "$META_FILE" branch)"
SESSION="$(meta_value "$META_FILE" session)"
WINDOW="$(meta_value "$META_FILE" window)"

if [[ -d "$WORKTREE" && -n "$(git -C "$WORKTREE" status --porcelain 2>/dev/null)" && "$FORCE" != true ]]; then
  git -C "$WORKTREE" status --short >&2
  fail "worktree has uncommitted changes; preserve them or rerun with --force after explicit discard approval"
fi

if tmux has-session -t "$SESSION" 2>/dev/null && \
   tmux list-windows -t "$SESSION" -F '#{window_name}' | grep -Fxq "$WINDOW"; then
  tmux kill-window -t "$SESSION:$WINDOW"
fi

if [[ -d "$WORKTREE" ]]; then
  if [[ "$FORCE" == true ]]; then
    git -C "$PROJECT" worktree remove --force "$WORKTREE"
  else
    git -C "$PROJECT" worktree remove "$WORKTREE"
  fi
fi

for SUFFIX in brief.md meta report.md status; do
  SOURCE="$STATE_ACTIVE/$TASK_ID.$SUFFIX"
  [[ ! -e "$SOURCE" ]] || mv "$SOURCE" "$STATE_DONE/"
done

printf 'Tore down task %s; branch preserved: %s\n' "$TASK_ID" "$BRANCH"
