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
```

There is no required install or startup script. Kiro CLI discovers the committed workspace agent in `.kiro/agents/` when invoked from the repository. The runtime scripts derive the home directory from the clone location; `DISPATCHER_HOME` is only needed when code and state are intentionally separated.

`bin/dispatch-init.sh` is optional. Run it only if you want template files for local preferences and explicit local config; the runtime creates state directories and uses safe defaults without it.

## Start the dispatcher

From the repository root, launch the native workspace agent:

```bash
kiro-cli chat --agent dispatcher
```

Then enter requests normally, for example: `Audit ~/src/example and dispatch independent fixes in parallel.`

This is the Kiro equivalent of launching a supported harness inside the Firstmate repository: Kiro discovers `.kiro/agents/dispatcher.json`, loads `DISPATCHER.md` as a repository-relative resource, and starts an ordinary interactive chat. No prompt injection wrapper or `.sh` launcher is involved.

The explicit `--agent dispatcher` remains necessary because Kiro discovers workspace agents but does not automatically select one over its configured default. Avoid globally setting this workspace-only agent as Kiro's default, because it is unavailable outside this repository.

For a fully autonomous dispatcher session, Kiro's native trust flag can be added explicitly:

```bash
kiro-cli chat --agent dispatcher --trust-all-tools
```

This allows the dispatcher itself to run all available tools without approval. It does not change crewmate autonomy, which remains controlled separately per task; use it only when that authority is intentional.

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
.kiro/agents/dispatcher.json  native workspace-agent definition
crew/CREWMATE.md           generic contract loaded for every task
profiles/                  optional specialist overlays
harnesses/                 tested CLI launch adapters
bin/dispatch-init.sh       optional local preference/config initialization
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
python3 tests/handover.py
tests/smoke.sh
```

The smoke test uses a local mock harness; it does not consume Kiro quota. It exercises brief creation, worktree isolation, tmux launch, status/report creation, JSON output, commit preservation, and teardown.

## Amazon Q parity implementation handover

The repository includes a tracked, opt-in implementation package for porting Kiro Dispatcher to functional parity with pinned Firstmate commit `f9a89c3962a5ad0db3ef79756a477053998c2529`:

- Start with [`Q_IMPLEMENTATION_HANDOVER.md`](Q_IMPLEMENTATION_HANDOVER.md).
- Track scope in [`docs/firstmate-parity/MATRIX.md`](docs/firstmate-parity/MATRIX.md).
- Follow [`docs/firstmate-parity/ROADMAP.md`](docs/firstmate-parity/ROADMAP.md).
- Apply the evidence rules in [`docs/firstmate-parity/VERIFICATION.md`](docs/firstmate-parity/VERIFICATION.md).
- Preserve [`THIRD_PARTY_NOTICES.md`](THIRD_PARTY_NOTICES.md).

These files are implementation instructions for an explicitly directed coding agent. They are intentionally not included in the runtime dispatcher agent’s resources or Kiro steering, so ordinary dispatcher sessions are not redirected into self-modification work.

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
