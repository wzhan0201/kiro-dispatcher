#!/usr/bin/env bash
# fm-status.sh — Show current fleet status
#
# Usage: fm-status.sh [--json]

set -euo pipefail

DISPATCHER_HOME="${DISPATCHER_HOME:-$HOME/.kiro-dispatcher}"
STATE_DIR="$DISPATCHER_HOME/state/active"

JSON_MODE=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --json) JSON_MODE=true; shift ;;
    -h|--help)
      echo "Usage: fm-status.sh [--json]"
      exit 0
      ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

# Count active tasks
TASK_COUNT=0
for f in "$STATE_DIR"/*.meta 2>/dev/null; do
  [[ -f "$f" ]] && ((TASK_COUNT++)) || true
done

if [[ "$TASK_COUNT" -eq 0 ]]; then
  if [[ "$JSON_MODE" == "true" ]]; then
    echo '{"tasks":[],"total":0}'
  else
    echo "No active crewmates."
  fi
  exit 0
fi

if [[ "$JSON_MODE" == "true" ]]; then
  echo '{"tasks":['
  first=true
  for meta_file in "$STATE_DIR"/*.meta; do
    [[ -f "$meta_file" ]] || continue
    task_id=$(basename "$meta_file" .meta)
    status_file="$STATE_DIR/${task_id}.status"
    current_status=$(tail -1 "$status_file" 2>/dev/null || echo "unknown")
    profile=$(grep "^profile=" "$meta_file" | cut -d= -f2-)
    backend=$(grep "^backend=" "$meta_file" | cut -d= -f2-)
    project=$(grep "^project=" "$meta_file" | cut -d= -f2-)

    [[ "$first" == "true" ]] && first=false || echo ","
    printf '  {"id":"%s","status":"%s","profile":"%s","backend":"%s","project":"%s"}' \
      "$task_id" "$current_status" "$profile" "$backend" "$project"
  done
  echo '],"total":'$TASK_COUNT'}'
else
  echo "═══════════════════════════════════════════════════"
  echo " Kiro Dispatcher — Fleet Status"
  echo "═══════════════════════════════════════════════════"
  echo ""
  printf "%-20s %-12s %-10s %-6s %s\n" "TASK" "STATUS" "PROFILE" "BACK" "PROJECT"
  printf "%-20s %-12s %-10s %-6s %s\n" "----" "------" "-------" "----" "-------"

  for meta_file in "$STATE_DIR"/*.meta; do
    [[ -f "$meta_file" ]] || continue
    task_id=$(basename "$meta_file" .meta)
    status_file="$STATE_DIR/${task_id}.status"

    # Get latest status line
    current_status="unknown"
    if [[ -f "$status_file" ]]; then
      current_status=$(tail -1 "$status_file" | cut -d: -f1)
    fi

    profile=$(grep "^profile=" "$meta_file" | cut -d= -f2-)
    backend=$(grep "^backend=" "$meta_file" | cut -d= -f2-)
    project=$(grep "^project=" "$meta_file" | cut -d= -f2- | xargs basename 2>/dev/null || echo "?")

    # Status emoji
    case "$current_status" in
      done)    icon="✅" ;;
      failed)  icon="❌" ;;
      blocked) icon="⚠️ " ;;
      running) icon="🔄" ;;
      spawned) icon="🆕" ;;
      *)       icon="❓" ;;
    esac

    printf "%-20s %s %-10s %-10s %-6s %s\n" "$task_id" "$icon" "$current_status" "$profile" "$backend" "$project"
  done

  echo ""
  echo "Total: $TASK_COUNT active crewmate(s)"
  echo ""

  # Show tmux windows
  if tmux has-session -t dispatcher 2>/dev/null; then
    echo "tmux windows:"
    tmux list-windows -t dispatcher -F "  #{window_index}: #{window_name} #{window_active}" 2>/dev/null
  else
    echo "No tmux 'dispatcher' session active."
  fi
fi
