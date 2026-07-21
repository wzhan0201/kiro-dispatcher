#!/usr/bin/env bash
# fm-teardown.sh — Clean up a finished crewmate's worktree and tmux window
#
# Usage: fm-teardown.sh <task-id> [--force]
#
# Removes:
#   - tmux window
#   - git worktree
#   - startup script
# Preserves:
#   - state/active/<id>.status (moved to state/done/)
#   - state/active/<id>.report.md (moved to state/done/)
#   - state/active/<id>.meta (moved to state/done/)

set -euo pipefail

DISPATCHER_HOME="${DISPATCHER_HOME:-$HOME/.kiro-dispatcher}"
STATE_DIR="$DISPATCHER_HOME/state/active"
DONE_DIR="$DISPATCHER_HOME/state/done"
FORCE=false

TASK_ID="${1:-}"
shift || true

while [[ $# -gt 0 ]]; do
  case $1 in
    --force) FORCE=true; shift ;;
    -h|--help)
      echo "Usage: fm-teardown.sh <task-id> [--force]"
      echo "  --force  Skip landed-work check and force removal"
      exit 0
      ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

if [[ -z "$TASK_ID" ]]; then
  echo "Error: task-id required"
  echo "Usage: fm-teardown.sh <task-id> [--force]"
  exit 1
fi

META_FILE="$STATE_DIR/${TASK_ID}.meta"
if [[ ! -f "$META_FILE" ]]; then
  echo "Error: No metadata found for task '$TASK_ID'"
  echo "Available tasks:"
  ls "$STATE_DIR"/*.meta 2>/dev/null | xargs -I{} basename {} .meta | sed 's/^/  /'
  exit 1
fi

# Read metadata
WORKTREE=$(grep "^worktree=" "$META_FILE" | cut -d= -f2-)
WINDOW=$(grep "^window=" "$META_FILE" | cut -d= -f2-)
PROJECT=$(grep "^project=" "$META_FILE" | cut -d= -f2-)
BRANCH=$(grep "^branch=" "$META_FILE" | cut -d= -f2-)

# --- Safety check: no uncommitted work ---
if [[ "$FORCE" != "true" && -d "$WORKTREE" ]]; then
  if [[ -n "$(git -C "$WORKTREE" status --porcelain 2>/dev/null)" ]]; then
    echo "⚠️  Worktree has uncommitted changes!"
    echo "   Path: $WORKTREE"
    echo ""
    git -C "$WORKTREE" status --short
    echo ""
    echo "Refusing to tear down. Use --force to override."
    exit 1
  fi
fi

echo "Tearing down task: $TASK_ID"

# --- Kill tmux window ---
if tmux has-session -t dispatcher 2>/dev/null; then
  if tmux list-windows -t dispatcher -F '#{window_name}' | grep -q "^${WINDOW}$"; then
    tmux kill-window -t "dispatcher:${WINDOW}" 2>/dev/null && \
      echo "  ✓ Killed tmux window: $WINDOW" || \
      echo "  ⚠ Could not kill window: $WINDOW"
  else
    echo "  - Window already gone: $WINDOW"
  fi
fi

# --- Remove worktree ---
if [[ -d "$WORKTREE" ]]; then
  git -C "$PROJECT" worktree remove "$WORKTREE" --force 2>/dev/null && \
    echo "  ✓ Removed worktree: $WORKTREE" || \
    (rm -rf "$WORKTREE" && echo "  ✓ Force-removed worktree: $WORKTREE")
else
  echo "  - Worktree already gone: $WORKTREE"
fi

# --- Clean up startup script ---
STARTUP_SCRIPT="/tmp/kiro-dispatcher/${TASK_ID}-startup.sh"
if [[ -f "$STARTUP_SCRIPT" ]]; then
  rm -f "$STARTUP_SCRIPT"
  echo "  ✓ Removed startup script"
fi

# --- Archive state files ---
mkdir -p "$DONE_DIR"
for ext in status meta report.md brief.md; do
  src="$STATE_DIR/${TASK_ID}.${ext}"
  if [[ -f "$src" ]]; then
    mv "$src" "$DONE_DIR/"
    echo "  ✓ Archived: ${TASK_ID}.${ext} → state/done/"
  fi
done

# --- Optionally delete the branch ---
echo ""
echo "  Branch '$BRANCH' preserved. Delete manually when merged:"
echo "    git -C $PROJECT branch -d $BRANCH"

echo ""
echo "✓ Teardown complete for: $TASK_ID"
