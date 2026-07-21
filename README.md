# Kiro Dispatcher

Talk to one agent. Ship with a crew.

Kiro Dispatcher is an agent orchestration system for [Kiro CLI](https://kiro.dev). It spawns parallel autonomous agents in tmux windows, each working in an isolated git worktree, so you can run multiple tasks concurrently without conflicts.

## How It Works

```
You (captain)
  └─→ Kiro CLI (dispatcher) ← you talk here
        ├─→ tmux window 1: crewmate (developer)
        ├─→ tmux window 2: crewmate (reviewer)
        └─→ tmux window 3: crewmate (scout)
```

1. You give the dispatcher a task (or multiple).
2. It breaks work into subtasks and writes briefs.
3. It spawns crewmates — each in its own tmux window and git worktree.
4. Crewmates work autonomously and signal completion via status files.
5. Dispatcher reads results, synthesizes, and reports back to you.

## Features

- **One liaison** — talk only to the dispatcher; it manages the crew.
- **Parallel execution** — crewmates run simultaneously in tmux windows you can inspect.
- **Git worktree isolation** — each task gets a clean branch in a separate worktree; no conflicts.
- **Mixed backends** — use Amazon Q (unlimited) for routine work, Kiro CLI for complex decisions.
- **Two task shapes** — "ship" (deliver code) and "scout" (investigate/report).
- **Restart-proof** — all state lives on disk as plain markdown files.
- **Visible crew** — `tmux attach -t dispatcher` to watch any crewmate live.

## Quick Start

### Prerequisites

- [Kiro CLI](https://kiro.dev) installed and authenticated
- [Amazon Q CLI](https://aws.amazon.com/q/developer/) installed (optional, for unlimited crewmates)
- [tmux](https://github.com/tmux/tmux) installed
- git

### Setup

```bash
git clone https://github.com/wzhan0201/kiro-dispatcher.git ~/.kiro-dispatcher
```

### Usage

Start a Kiro CLI session and load the dispatcher prompt:

```bash
cd ~/.kiro-dispatcher
kiro chat
```

Then tell the dispatcher what you need:

```
> I need to add pagination to the /users API and fix the login bug. Run both in parallel.
```

The dispatcher will:
1. Create briefs for each task
2. Spawn crewmates in tmux windows
3. Monitor progress
4. Report results when done

### Manual Script Usage

```bash
# Create a task brief
./bin/fm-brief.sh --task fix-login --title "Fix login redirect bug" --body "The login page redirects to 404 after OAuth callback..."

# Spawn a crewmate
./bin/fm-spawn.sh --task fix-login --profile developer --project ~/myapp

# Check fleet status
./bin/fm-status.sh

# Watch for completions
./bin/fm-watch.sh

# Clean up when done
./bin/fm-teardown.sh fix-login
```

## Directory Structure

```
~/.kiro-dispatcher/
├── agents/                 # Agent profiles
│   ├── dispatcher.md       # Main orchestrator instructions
│   ├── developer.md        # Developer crewmate profile
│   ├── reviewer.md         # Code reviewer profile
│   └── scout.md            # Investigation/audit profile
├── bin/                    # Helper scripts
│   ├── fm-spawn.sh         # Spawn a crewmate (tmux + worktree)
│   ├── fm-watch.sh         # Monitor fleet for completions
│   ├── fm-teardown.sh      # Clean up finished tasks
│   ├── fm-status.sh        # Show fleet status
│   └── fm-brief.sh         # Create task briefs
├── config/                 # Operating configuration
│   ├── crew-backend        # Default agent backend (q or kiro)
│   ├── delivery-mode       # How ship tasks land (direct-pr, local-only)
│   └── autonomy            # Permission level (conservative, yolo)
├── data/                   # Persistent fleet records
│   ├── captain.md          # Your preferences
│   ├── backlog.md          # Task queue
│   └── learnings.md        # Accumulated knowledge
├── state/                  # Runtime state
│   ├── active/             # Current task state files
│   └── done/               # Archived completed tasks
└── projects/               # Project registrations
```

## Configuration

### Crew Backend (`config/crew-backend`)

Which agent runs your crewmates:
- `q` — Amazon Q CLI (default, unlimited usage)
- `kiro` — Kiro CLI (premium models, uses subscription quota)

### Delivery Mode (`config/delivery-mode`)

How ship tasks deliver changes:
- `direct-pr` — push branch and create PR (default)
- `local-only` — commit locally, present for manual merge
- `no-mistakes` — full review pipeline before push

### Autonomy (`config/autonomy`)

- `conservative` — always ask before merging/deploying (default)
- `yolo` — crewmates can push without asking

## Architecture Decisions

### Why tmux?

- Each crewmate is a real, independent terminal session.
- You can `tmux attach` and watch or intervene anytime.
- No shared context window — each agent gets full context budget.
- Process isolation — one crewmate crashing doesn't affect others.

### Why git worktrees?

- True file-level isolation — parallel tasks can't conflict.
- Each task works on its own branch from the start.
- Clean teardown — remove the worktree and the mess is gone.
- The main repo stays clean.

### Why Amazon Q as default backend?

- No hard usage limits — spawn as many crewmates as needed.
- Save Kiro subscription quota for the dispatcher (complex decisions).
- Override per-task when you need premium model quality.

## Inspired By

- [firstmate](https://github.com/kunchenguid/firstmate) — the original agent distro concept for Claude Code

## License

MIT
