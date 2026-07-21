#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
TMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/kiro-dispatcher-smoke.XXXXXX")"
HOME_COPY="$TMP_ROOT/home"
PROJECT="$TMP_ROOT/project"
SESSION="kd-smoke-$$"
SPECIALIST_TASK="specialist-task"
GENERIC_TASK="generic-task"

cleanup() {
  tmux kill-session -t "$SESSION" >/dev/null 2>&1 || true
  rm -rf "$TMP_ROOT"
}
trap cleanup EXIT INT TERM

mkdir -p "$HOME_COPY" "$PROJECT"
cp -R "$ROOT/bin" "$ROOT/crew" "$ROOT/harnesses" "$ROOT/profiles" "$HOME_COPY/"
mkdir -p "$HOME_COPY/config" "$HOME_COPY/data" "$HOME_COPY/state/active" "$HOME_COPY/state/done"

cat >"$HOME_COPY/harnesses/mock.sh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
PROMPT="$1"
grep -q 'Generic Crewmate Contract' <<<"$PROMPT"
if grep -q 'AWS MAP Specialist Profile' <<<"$PROMPT"; then
  PROFILE=aws-map-specialist
else
  PROFILE=none
fi
sleep 0.3
printf 'crew smoke output (%s)\n' "$PROFILE" >crew-smoke.txt
git add crew-smoke.txt
git commit -m "smoke: $PROFILE crew change" >/dev/null
printf 'DISPATCH_STATUS: done\nMock harness completed with profile=%s.\n' "$PROFILE"
EOF
chmod +x "$HOME_COPY/harnesses/mock.sh"
printf '%s\n' mock >"$HOME_COPY/config/harness"
printf '%s\n' trusted >"$HOME_COPY/config/autonomy"
printf '%s\n' "$SESSION" >"$HOME_COPY/config/tmux-session"

git -C "$PROJECT" init -b main >/dev/null
git -C "$PROJECT" config user.name 'Kiro Dispatcher Smoke'
git -C "$PROJECT" config user.email 'smoke@example.invalid'
printf 'fixture\n' >"$PROJECT/README.md"
git -C "$PROJECT" add README.md
git -C "$PROJECT" commit -m fixture >/dev/null

for TASK in "$SPECIALIST_TASK" "$GENERIC_TASK"; do
  DISPATCHER_HOME="$HOME_COPY" "$HOME_COPY/bin/dispatch-brief.sh" \
    --task "$TASK" --kind ship --title "Smoke test $TASK" \
    --body 'Create and commit crew-smoke.txt; return the dispatch status marker.' >/dev/null
done

# Spawn both before either mock completes to exercise parallel tmux/worktree isolation.
DISPATCHER_HOME="$HOME_COPY" DISPATCHER_TMUX_SESSION="$SESSION" \
  "$HOME_COPY/bin/dispatch-spawn.sh" --task "$SPECIALIST_TASK" --kind ship \
  --profile aws-map-specialist --harness mock --autonomy trusted --project "$PROJECT" >/dev/null
DISPATCHER_HOME="$HOME_COPY" DISPATCHER_TMUX_SESSION="$SESSION" \
  "$HOME_COPY/bin/dispatch-spawn.sh" --task "$GENERIC_TASK" --kind ship \
  --harness mock --autonomy trusted --project "$PROJECT" >/dev/null

for _ in $(seq 1 100); do
  SPECIALIST_STATUS="$(cat "$HOME_COPY/state/active/$SPECIALIST_TASK.status")"
  GENERIC_STATUS="$(cat "$HOME_COPY/state/active/$GENERIC_TASK.status")"
  case "$SPECIALIST_STATUS $GENERIC_STATUS" in
    *failed:*|*blocked:*)
      printf 'Unexpected task statuses: %s | %s\n' "$SPECIALIST_STATUS" "$GENERIC_STATUS" >&2
      exit 1
      ;;
  esac
  if [[ "$SPECIALIST_STATUS" == done:* && "$GENERIC_STATUS" == done:* ]]; then
    break
  fi
  sleep 0.1
done
[[ "$SPECIALIST_STATUS" == done:* && "$GENERIC_STATUS" == done:* ]] || {
  printf 'Tasks did not finish: %s | %s\n' "$SPECIALIST_STATUS" "$GENERIC_STATUS" >&2
  exit 1
}

grep -q 'profile=aws-map-specialist' "$HOME_COPY/state/active/$SPECIALIST_TASK.report.md"
grep -q 'profile=none' "$HOME_COPY/state/active/$GENERIC_TASK.report.md"
JSON="$(DISPATCHER_HOME="$HOME_COPY" "$HOME_COPY/bin/dispatch-status.sh" --json)"
if command -v python3 >/dev/null 2>&1; then
  printf '%s' "$JSON" | python3 -m json.tool >/dev/null
fi
grep -q '"id":"specialist-task"' <<<"$JSON"
grep -q '"id":"generic-task"' <<<"$JSON"
grep -q '"total":2' <<<"$JSON"

SPECIALIST_BRANCH="$(awk -F= '$1 == "branch" {sub(/^[^=]*=/, ""); print}' "$HOME_COPY/state/active/$SPECIALIST_TASK.meta")"
GENERIC_BRANCH="$(awk -F= '$1 == "branch" {sub(/^[^=]*=/, ""); print}' "$HOME_COPY/state/active/$GENERIC_TASK.meta")"
SPECIALIST_WORKTREE="$(awk -F= '$1 == "worktree" {sub(/^[^=]*=/, ""); print}' "$HOME_COPY/state/active/$SPECIALIST_TASK.meta")"
GENERIC_WORKTREE="$(awk -F= '$1 == "worktree" {sub(/^[^=]*=/, ""); print}' "$HOME_COPY/state/active/$GENERIC_TASK.meta")"
git -C "$PROJECT" show "$SPECIALIST_BRANCH:crew-smoke.txt" | grep -q 'aws-map-specialist'
git -C "$PROJECT" show "$GENERIC_BRANCH:crew-smoke.txt" | grep -q 'none'

# A watcher started after completion must still observe terminal state and exit.
DISPATCHER_HOME="$HOME_COPY" "$HOME_COPY/bin/dispatch-watch.sh" --once --poll 0.1 >/dev/null

# Teardown must fail closed while a task worktree is dirty.
printf 'uncommitted\n' >"$SPECIALIST_WORKTREE/dirty.tmp"
if DISPATCHER_HOME="$HOME_COPY" "$HOME_COPY/bin/dispatch-teardown.sh" "$SPECIALIST_TASK" >/dev/null 2>&1; then
  printf 'Teardown unexpectedly accepted a dirty worktree.\n' >&2
  exit 1
fi
rm "$SPECIALIST_WORKTREE/dirty.tmp"

for TASK in "$SPECIALIST_TASK" "$GENERIC_TASK"; do
  DISPATCHER_HOME="$HOME_COPY" "$HOME_COPY/bin/dispatch-teardown.sh" "$TASK" >/dev/null
done
[[ ! -d "$SPECIALIST_WORKTREE" && ! -d "$GENERIC_WORKTREE" ]]
[[ -f "$HOME_COPY/state/done/$SPECIALIST_TASK.report.md" ]]
[[ -f "$HOME_COPY/state/done/$GENERIC_TASK.report.md" ]]
git -C "$PROJECT" show-ref --verify --quiet "refs/heads/$SPECIALIST_BRANCH"
git -C "$PROJECT" show-ref --verify --quiet "refs/heads/$GENERIC_BRANCH"

printf 'Smoke test: PASS (parallel generic + specialist crew)\n'
