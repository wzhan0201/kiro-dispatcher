#!/usr/bin/env bash
# Wait for task state changes without using model turns.
# Usage: dispatch-watch.sh [--poll SECONDS] [--once]

set -euo pipefail
# shellcheck source=lib.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)/lib.sh"

POLL=5
ONCE=false
while (($#)); do
  case "$1" in
    --poll) [[ $# -ge 2 ]] || fail "--poll requires a value"; POLL="$2"; shift 2 ;;
    --once) ONCE=true; shift ;;
    -h|--help) sed -n '2,3p' "$0"; exit 0 ;;
    *) fail "unknown option: $1" ;;
  esac
done
[[ "$POLL" =~ ^[0-9]+([.][0-9]+)?$ ]] || fail "--poll must be a positive number"
ensure_state_dirs

WATCH_CACHE="$(mktemp -d "${TMPDIR:-/tmp}/kiro-dispatch-watch.XXXXXX")"
trap 'rm -rf "$WATCH_CACHE"' EXIT INT TERM
printf 'Watching %s every %ss (Ctrl-C to stop)\n' "$STATE_ACTIVE" "$POLL"

while true; do
  CHANGED=false
  shopt -s nullglob
  STATUS_FILES=("$STATE_ACTIVE"/*.status)
  shopt -u nullglob

  for STATUS_FILE in "${STATUS_FILES[@]}"; do
    TASK_ID="$(basename "$STATUS_FILE" .status)"
    CURRENT="$(tail -n 1 "$STATUS_FILE" 2>/dev/null || printf unknown)"
    CACHE_FILE="$WATCH_CACHE/$TASK_ID"
    PREVIOUS=""
    [[ ! -f "$CACHE_FILE" ]] || PREVIOUS="$(cat "$CACHE_FILE")"
    TERMINAL=false
    case "$CURRENT" in done:*|blocked:*|failed:*) TERMINAL=true ;; esac

    if [[ -z "$PREVIOUS" ]]; then
      printf '%s\n' "$CURRENT" >"$CACHE_FILE"
      if [[ "$TERMINAL" == true ]]; then
        printf '[%s] %s — %s\n' "$(date +%H:%M:%S)" "$TASK_ID" "$CURRENT"
        CHANGED=true
      fi
    elif [[ "$CURRENT" != "$PREVIOUS" ]]; then
      printf '%s\n' "$CURRENT" >"$CACHE_FILE"
      printf '[%s] %s — %s\n' "$(date +%H:%M:%S)" "$TASK_ID" "$CURRENT"
      CHANGED=true
    fi
  done

  if [[ "$ONCE" == true && "$CHANGED" == true ]]; then
    exit 0
  fi
  sleep "$POLL"
done
