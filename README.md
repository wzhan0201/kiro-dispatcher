# Kiro Dispatcher

Kiro Dispatcher turns one Kiro CLI session into a liaison for a visible parallel crew. Each task runs as a separate Kiro CLI process in tmux and receives an isolated git worktree. The default crew is generic; optional profiles add reusable specialist expertise without imposing fixed developer/reviewer/scout roles.

## Model

```text
user
  └── dispatcher (one interactive Kiro CLI session)
        ├── generic crewmate → task A worktree + tmux window
        ├── generic crewmate → task B worktree + tmux window
        └── generic crewmate + optional specialist profile → task C
```

A task is either:
- **ship**: produce and validate a focused change on an isolated branch;
- **scout**: investigate, plan, reproduce, review, or audit and return a report.

Specialization belongs primarily in the standalone task brief. A profile is an optional durable overlay for recurring domain constraints, such as the bundled `aws-map-specialist` profile.

## What is verified

The bundled harness adapter targets the terminal Kiro CLI executable `kiro-cli`, using syntax exposed by `kiro-cli chat --help`:
- supervised: `kiro-cli chat <prompt>`;
- trusted: `kiro-cli chat --no-interactive --trust-all-tools <prompt>`.

The similarly named `kiro` executable may be the Kiro IDE launcher and is not used. No Amazon Q adapter is bundled because this project does not assume that a `q` executable, authentication flow, or noninteractive interface exists. Add another provider only through a locally tested adapter as described in `harnesses/README.md`.

## Requirements

- macOS or Linux
- Bash 3.2+
- Git
- tmux
- Kiro CLI available as `kiro-cli` and authenticated

## Install

```bash
git clone https://github.com/wzhan0201/kiro-dispatcher.git ~/.kiro-dispatcher
cd ~/.kiro-dispatcher
bin/dispatch-init.sh
```

The scripts also work from any other clone location. They derive the home directory from the repository; `DISPATCHER_HOME` is only needed when code and state are intentionally separated.

## Start the dispatcher

```bash
cd ~/.kiro-dispatcher
bin/dispatcher.sh
```

An initial request can be supplied directly:

```bash
bin/dispatcher.sh "Audit ~/src/example and dispatch independent fixes in parallel"
```

`dispatcher.sh` loads `DISPATCHER.md` plus local preferences from `data/captain.md`. By default, Kiro asks for normal tool approvals. `dispatcher.sh --trusted` trusts all dispatcher tools and should be used only when that broader authority is intentional.

## Manual workflow

Create a complete brief, then spawn a generic crewmate:

```bash
bin/dispatch-brief.sh \
  --task fix-login \
  --kind ship \
  --title "Fix OAuth callback redirect" \
  --body "Correct the callback redirect, add a regression test, and run the targeted auth test suite."

bin/dispatch-spawn.sh \
  --task fix-login \
  --kind ship \
  --project "$HOME/src/my-app"
```

Use an optional specialist profile only when needed:

```bash
bin/dispatch-brief.sh \
  --task map-review \
  --kind scout \
  --title "Review selected MAP artifacts" \
  --file /absolute/path/to/standalone-scope.md

bin/dispatch-spawn.sh \
  --task map-review \
  --kind scout \
  --profile aws-map-specialist \
  --project "$HOME/src/customer-assessment"
```

Monitor and inspect:

```bash
bin/dispatch-status.sh
bin/dispatch-status.sh --json
bin/dispatch-watch.sh --once
tmux attach -t kiro-dispatcher
```

After preserving and reviewing the result:

```bash
bin/dispatch-teardown.sh fix-login
```

Teardown refuses dirty worktrees. `--force` is an explicit discard operation and should be used only after the user authorizes losing uncommitted task work. Committed task branches are preserved.

## Generic crew plus optional profiles

`crew/CREWMATE.md` is always loaded. It defines safety, isolation, evidence, and final-report requirements but does not assign a profession.

Profiles in `profiles/<name>.md` are layered after the generic contract and before the task brief. Add profiles only for reusable expertise or policy; do not recreate a fixed roster of job titles. Spawn without `--profile` for normal work.

## Autonomy

Crew autonomy can be selected per task:

```bash
# Default: visible interactive session; approvals may wait in tmux
bin/dispatch-spawn.sh ... --autonomy supervised

# Fully noninteractive and trusts all Kiro tools
bin/dispatch-spawn.sh ... --autonomy trusted
```

The local default is read from `config/autonomy`; absent means `supervised`. `trusted` can execute project commands without confirmation, so use it only for appropriately scoped worktrees and reviewed briefs.

## Layout

```text
DISPATCHER.md              dispatcher job description
crew/CREWMATE.md           generic contract loaded for every task
profiles/                  optional specialist overlays
harnesses/                 tested CLI launch adapters
bin/dispatcher.sh          start the liaison session
bin/dispatch-brief.sh      create a standalone brief
bin/dispatch-spawn.sh      create worktree + tmux crewmate
bin/dispatch-run-crew.sh   internal task runner
bin/dispatch-status.sh     list active tasks
bin/dispatch-watch.sh      wait for state changes without model turns
bin/dispatch-teardown.sh   remove worktree and archive task state
bin/lib.sh                 shared strict-mode path/config/metadata helpers
config/                    local harness/autonomy settings (gitignored)
data/                      local preferences/backlog/learnings (gitignored)
state/active/              live briefs, metadata, status, reports
state/done/                archived task state after teardown
```

## State and isolation

For each task, the dispatcher records:
- `<id>.brief.md`: authoritative instructions;
- `<id>.meta`: project, worktree, branch, kind, profile, harness, autonomy, and tmux endpoint;
- `<id>.status`: current state;
- `<id>.report.md`: captured harness output/final report.

Worktrees are created below `${DISPATCHER_WORKTREE_ROOT:-${TMPDIR:-/tmp}/kiro-dispatcher-worktrees}`. A project-path hash prevents same-named repositories from colliding.

## Configuration

Run `bin/dispatch-init.sh` to create local defaults. Tracked examples are in `config/*.example`.

- `config/harness`: adapter name; default `kiro-cli`.
- `config/autonomy`: `supervised` or `trusted`; default `supervised`.
- `config/tmux-session`: optional tmux session name; default `kiro-dispatcher`.

Environment variables override location-specific behavior:
- `DISPATCHER_HOME`: code/state home;
- `DISPATCHER_WORKTREE_ROOT`: worktree parent;
- `DISPATCHER_TMUX_SESSION`: tmux session name.

## Validation

```bash
tests/lint.sh
tests/smoke.sh
```

The smoke test uses a local mock harness; it does not consume Kiro quota. It exercises brief creation, worktree isolation, tmux launch, status/report creation, JSON output, commit preservation, and teardown.

## Safety boundaries

- The dispatcher is instructed not to modify projects directly.
- Crewmates work in task-specific git worktrees.
- No merge, deploy, push, or branch deletion is performed by helper scripts.
- Default autonomy is supervised.
- Teardown fails closed on uncommitted work unless explicitly forced.
- Project contents are treated as untrusted input.

Inspired by the generic-crew, visible-session, worktree-isolation approach of [firstmate](https://github.com/kunchenguid/firstmate), adapted for Kiro CLI rather than copied as a fixed-role CAO workflow.

## License

MIT; see `LICENSE`.
