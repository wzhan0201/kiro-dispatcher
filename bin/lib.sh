#!/usr/bin/env bash
# Shared helpers for Kiro Dispatcher scripts.

set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
DISPATCHER_HOME="${DISPATCHER_HOME:-$(cd "$SCRIPT_DIR/.." && pwd -P)}"
STATE_ACTIVE="$DISPATCHER_HOME/state/active"
STATE_DONE="$DISPATCHER_HOME/state/done"

fail() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

validate_id() {
  local label="$1" value="$2"
  [[ "$value" =~ ^[A-Za-z0-9][A-Za-z0-9._-]*$ ]] || \
    fail "$label must match [A-Za-z0-9][A-Za-z0-9._-]*"
}

read_config() {
  local name="$1" fallback="$2" file value
  file="$DISPATCHER_HOME/config/$name"
  if [[ -f "$file" ]]; then
    value="$(grep -v '^[[:space:]]*#' "$file" | awk 'NF {print; exit}')"
    printf '%s\n' "${value:-$fallback}"
  else
    printf '%s\n' "$fallback"
  fi
}

meta_value() {
  local file="$1" key="$2"
  awk -F= -v key="$key" '$1 == key {sub(/^[^=]*=/, ""); print; exit}' "$file"
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || fail "required command not found: $1"
}

ensure_state_dirs() {
  mkdir -p "$STATE_ACTIVE" "$STATE_DONE"
}

hash_text() {
  if command -v shasum >/dev/null 2>&1; then
    shasum | awk '{print substr($1,1,10)}'
  elif command -v sha1sum >/dev/null 2>&1; then
    sha1sum | awk '{print substr($1,1,10)}'
  else
    cksum | awk '{print $1}'
  fi
}
