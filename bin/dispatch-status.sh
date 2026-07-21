#!/usr/bin/env bash
# Show active crewmates.
# Usage: dispatch-status.sh [--json]

set -euo pipefail
# shellcheck source=lib.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)/lib.sh"

JSON=false
case "${1:-}" in
  "") ;;
  --json) JSON=true ;;
  -h|--help) sed -n '2,3p' "$0"; exit 0 ;;
  *) fail "unknown option: $1" ;;
esac
[[ $# -le 1 ]] || fail "too many arguments"
ensure_state_dirs

META_COUNT=0
for META_FILE in "$STATE_ACTIVE"/*.meta; do
  [[ -f "$META_FILE" ]] || continue
  META_COUNT=$((META_COUNT + 1))
done

json_escape() {
  local value="$1"
  value=${value//\\/\\\\}
  value=${value//\"/\\\"}
  value=${value//$'\n'/\\n}
  value=${value//$'\r'/\\r}
  value=${value//$'\t'/\\t}
  printf '%s' "$value"
}

if [[ "$JSON" == true ]]; then
  printf '{"tasks":['
  SEP=""
  for META_FILE in "$STATE_ACTIVE"/*.meta; do
    [[ -f "$META_FILE" ]] || continue
    TASK_ID="$(basename "$META_FILE" .meta)"
    STATUS="$(tail -n 1 "$STATE_ACTIVE/$TASK_ID.status" 2>/dev/null || printf unknown)"
    printf '%s{"id":"%s","status":"%s","kind":"%s","profile":"%s","harness":"%s","project":"%s","branch":"%s"}' \
      "$SEP" "$(json_escape "$TASK_ID")" "$(json_escape "$STATUS")" \
      "$(json_escape "$(meta_value "$META_FILE" kind)")" \
      "$(json_escape "$(meta_value "$META_FILE" profile)")" \
      "$(json_escape "$(meta_value "$META_FILE" harness)")" \
      "$(json_escape "$(meta_value "$META_FILE" project)")" \
      "$(json_escape "$(meta_value "$META_FILE" branch)")"
    SEP=,
  done
  printf '],"total":%d}\n' "$META_COUNT"
  exit 0
fi

if [[ "$META_COUNT" -eq 0 ]]; then
  printf 'No active crewmates.\n'
  exit 0
fi

printf '%-22s %-9s %-7s %-22s %-12s %s\n' TASK STATE KIND PROFILE HARNESS BRANCH
printf '%-22s %-9s %-7s %-22s %-12s %s\n' '----' '-----' '----' '-------' '-------' '------'
for META_FILE in "$STATE_ACTIVE"/*.meta; do
  [[ -f "$META_FILE" ]] || continue
  TASK_ID="$(basename "$META_FILE" .meta)"
  STATUS="$(tail -n 1 "$STATE_ACTIVE/$TASK_ID.status" 2>/dev/null || printf unknown)"
  STATE="${STATUS%%:*}"
  printf '%-22s %-9s %-7s %-22s %-12s %s\n' \
    "$TASK_ID" "$STATE" "$(meta_value "$META_FILE" kind)" \
    "$(meta_value "$META_FILE" profile)" "$(meta_value "$META_FILE" harness)" \
    "$(meta_value "$META_FILE" branch)"
done
printf '\nTotal: %d active crewmate(s)\n' "$META_COUNT"
