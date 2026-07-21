#!/usr/bin/env bash
# fm-watch.sh — Monitor fleet status, wake on completion
#
# Usage: fm-watch.sh [--poll <seconds>] [--once]
#
# Watches all active task status files for changes.
# Reports when any crewmate signals done, failed, or blocked.

set -euo pipefail

DISPATCHER_HOME="${DISPATCHER_HOME:-$HOME/.kiro-dispatcher}"
STATE_DIR="$DISPATCHER_HOME/state/active"

POLL_INTERVAL=5
ONCE=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --poll) POLL_INTERVAL="$2"; shift 2 ;;
    --once) ONCE=true; shift ;;
    -h|--help)
      echo "Usage: fm-watch.sh [--poll <seconds>] [--once]"
      echo "  --poll <sec>  Poll interval (default: 5)"
      echo "  --once        Exit after first completion detected"
      exit 0
      ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

echo "🔍 Watching fleet status (poll every ${POLL_INTERVAL}s)..."
echo "   State dir: $STATE_DIR"
echo "   Press Ctrl+C to stop"
echo ""

# Track last known states
declare -A LAST_STATES

while true; do
  FOUND_CHANGE=false

  for status_file in "$STATE_DIR"/*.status 2>/dev/null; do
    [[ -f "$status_file" ]] || continue

    task_id=$(basename "$status_file" .status)
    current_state=$(tail -1 "$status_file" 2>/dev/null || echo "unknown")
    last_state="${LAST_STATES[$task_id]:-}"

    if [[ "$current_state" != "$last_state" ]]; then
      LAST_STATES[$task_id]="$current_state"

      # Skip initial population
      if [[ -n "$last_state" ]]; then
        FOUND_CHANGE=true
        timestamp=$(date +%H:%M:%S)

        # Color-code by state
        case "$current_state" in
          done:*)
            echo "[$timestamp] ✅ $task_id — $current_state"
            ;;
          failed:*)
            echo "[$timestamp] ❌ $task_id — $current_state"
            ;;
          blocked:*)
            echo "[$timestamp] ⚠️  $task_id — $current_state"
            ;;
          running:*)
            echo "[$timestamp] 🔄 $task_id — $current_state"
            ;;
          *)
            echo "[$timestamp] 📋 $task_id — $current_state"
            ;;
        esac
      fi
    fi
  done

  if [[ "$FOUND_CHANGE" == "true" && "$ONCE" == "true" ]]; then
    echo ""
    echo "Change detected. Exiting (--once mode)."
    exit 0
  fi

  sleep "$POLL_INTERVAL"
done
