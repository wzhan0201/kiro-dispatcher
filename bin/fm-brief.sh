#!/usr/bin/env bash
# fm-brief.sh — Create a task brief for a crewmate
#
# Usage: fm-brief.sh --task <id> --title <title> [--body <text>] [--file <path>]
#
# Creates state/active/<task-id>.brief.md

set -euo pipefail

DISPATCHER_HOME="${DISPATCHER_HOME:-$HOME/.kiro-dispatcher}"
STATE_DIR="$DISPATCHER_HOME/state/active"

TASK_ID=""
TITLE=""
BODY=""
FROM_FILE=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --task)  TASK_ID="$2"; shift 2 ;;
    --title) TITLE="$2"; shift 2 ;;
    --body)  BODY="$2"; shift 2 ;;
    --file)  FROM_FILE="$2"; shift 2 ;;
    -h|--help)
      echo "Usage: fm-brief.sh --task <id> --title <title> [--body <text>] [--file <path>]"
      echo ""
      echo "Options:"
      echo "  --task <id>     Task identifier"
      echo "  --title <title> Brief title / summary"
      echo "  --body <text>   Inline task description"
      echo "  --file <path>   Read task description from file"
      exit 0
      ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

if [[ -z "$TASK_ID" || -z "$TITLE" ]]; then
  echo "Error: --task and --title are required"
  exit 1
fi

mkdir -p "$STATE_DIR"
BRIEF_FILE="$STATE_DIR/${TASK_ID}.brief.md"

{
  echo "# Task Brief: $TITLE"
  echo ""
  echo "**Task ID:** $TASK_ID"
  echo "**Created:** $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo ""
  echo "---"
  echo ""

  if [[ -n "$FROM_FILE" && -f "$FROM_FILE" ]]; then
    cat "$FROM_FILE"
  elif [[ -n "$BODY" ]]; then
    echo "$BODY"
  else
    echo "## Instructions"
    echo ""
    echo "(No body provided — fill in manually or the dispatcher will provide context)"
  fi

  echo ""
  echo "---"
  echo ""
  echo "## Completion Criteria"
  echo ""
  echo "When done, write status to: \`$STATE_DIR/${TASK_ID}.status\`"
  echo "- Success: \`echo \"done: <summary>\" > \$STATUS_FILE\`"
  echo "- Blocked: \`echo \"blocked: <reason>\" > \$STATUS_FILE\`"
  echo "- Failed:  \`echo \"failed: <reason>\" > \$STATUS_FILE\`"
} > "$BRIEF_FILE"

echo "✓ Brief created: $BRIEF_FILE"
