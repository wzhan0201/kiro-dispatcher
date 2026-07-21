#!/usr/bin/env bash
# fm-spawn.sh — Spawn a crewmate in a tmux window with an isolated git worktree
#
# Usage: fm-spawn.sh --task <id> --profile <developer|reviewer|scout> --project <path> [--backend kiro|q] [--branch <name>]
#
# Creates:
#   - A git worktree for isolation
#   - A tmux window running the agent
#   - State files for tracking

set -euo pipefail

DISPATCHER_HOME="${DISPATCHER_HOME:-$HOME/.kiro-dispatcher}"
STATE_DIR="$DISPATCHER_HOME/state/active"
AGENTS_DIR="$DISPATCHER_HOME/agents"
BIN_DIR="$DISPATCHER_HOME/bin"

# --- Parse arguments ---
TASK_ID=""
PROFILE=""
PROJECT=""
BACKEND=""
BRANCH=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --task)    TASK_ID="$2"; shift 2 ;;
    --profile) PROFILE="$2"; shift 2 ;;
    --project) PROJECT="$2"; shift 2 ;;
    --backend) BACKEND="$2"; shift 2 ;;
    --branch)  BRANCH="$2"; shift 2 ;;
    -h|--help)
      echo "Usage: fm-spawn.sh --task <id> --profile <developer|reviewer|scout> --project <path> [--backend kiro|q] [--branch <name>]"
      exit 0
      ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

# --- Validate ---
if [[ -z "$TASK_ID" || -z "$PROFILE" || -z "$PROJECT" ]]; then
  echo "Error: --task, --profile, and --project are required"
  echo "Usage: fm-spawn.sh --task <id> --profile <developer|reviewer|scout> --project <path>"
  exit 1
fi

if [[ ! -d "$PROJECT/.git" && ! -f "$PROJECT/.git" ]]; then
  echo "Error: $PROJECT is not a git repository"
  exit 1
fi

if [[ ! -f "$AGENTS_DIR/$PROFILE.md" ]]; then
  echo "Error: Unknown profile '$PROFILE'. Available: developer, reviewer, scout"
  exit 1
fi

# --- Determine backend ---
if [[ -z "$BACKEND" ]]; then
  if [[ -f "$DISPATCHER_HOME/config/crew-backend" ]]; then
    BACKEND=$(cat "$DISPATCHER_HOME/config/crew-backend")
  else
    BACKEND="q"  # Default to Amazon Q (unlimited)
  fi
fi

case "$BACKEND" in
  kiro) AGENT_CMD="kiro chat" ;;
  q)    AGENT_CMD="q chat" ;;
  *)    echo "Error: Unknown backend '$BACKEND'. Use 'kiro' or 'q'"; exit 1 ;;
esac

# --- Set up branch name ---
if [[ -z "$BRANCH" ]]; then
  BRANCH="crew/${TASK_ID}"
fi

# --- Create worktree ---
WORKTREE_DIR="/tmp/kiro-dispatcher/${TASK_ID}"
mkdir -p "$(dirname "$WORKTREE_DIR")"

# Clean up existing worktree if present
if [[ -d "$WORKTREE_DIR" ]]; then
  echo "Warning: Worktree already exists at $WORKTREE_DIR, removing..."
  git -C "$PROJECT" worktree remove "$WORKTREE_DIR" --force 2>/dev/null || rm -rf "$WORKTREE_DIR"
fi

# Create fresh worktree
echo "Creating worktree: $WORKTREE_DIR (branch: $BRANCH)"
git -C "$PROJECT" worktree add "$WORKTREE_DIR" -b "$BRANCH" 2>/dev/null || \
  git -C "$PROJECT" worktree add "$WORKTREE_DIR" "$BRANCH" 2>/dev/null || \
  git -C "$PROJECT" worktree add "$WORKTREE_DIR" -B "$BRANCH" HEAD

# --- Ensure brief exists ---
BRIEF_FILE="$STATE_DIR/${TASK_ID}.brief.md"
if [[ ! -f "$BRIEF_FILE" ]]; then
  echo "Warning: No brief found at $BRIEF_FILE — crewmate will need instructions"
fi

# --- Write metadata ---
META_FILE="$STATE_DIR/${TASK_ID}.meta"
cat > "$META_FILE" << EOF
task=$TASK_ID
profile=$PROFILE
project=$PROJECT
worktree=$WORKTREE_DIR
branch=$BRANCH
backend=$BACKEND
window=dispatcher-${TASK_ID}
spawned_at=$(date -u +%Y-%m-%dT%H:%M:%SZ)
EOF

# --- Write initial status ---
STATUS_FILE="$STATE_DIR/${TASK_ID}.status"
echo "spawned: crewmate created with profile=$PROFILE backend=$BACKEND" > "$STATUS_FILE"

# --- Build the agent launch command ---
REPORT_FILE="$STATE_DIR/${TASK_ID}.report.md"
PROFILE_PATH="$AGENTS_DIR/$PROFILE.md"

# Create a startup script for the crewmate
STARTUP_SCRIPT="/tmp/kiro-dispatcher/${TASK_ID}-startup.sh"
cat > "$STARTUP_SCRIPT" << 'SCRIPT_HEADER'
#!/usr/bin/env bash
set -euo pipefail
SCRIPT_HEADER

cat >> "$STARTUP_SCRIPT" << SCRIPT_BODY
export TASK_ID="$TASK_ID"
export WORKTREE="$WORKTREE_DIR"
export STATUS_FILE="$STATUS_FILE"
export BRIEF_FILE="$BRIEF_FILE"
export REPORT_FILE="$REPORT_FILE"
export PROJECT_ROOT="$PROJECT"

cd "$WORKTREE_DIR"

echo "═══════════════════════════════════════════════════"
echo " Kiro Dispatcher — Crewmate Session"
echo " Task:    $TASK_ID"
echo " Profile: $PROFILE"
echo " Backend: $BACKEND"
echo " Worktree: $WORKTREE_DIR"
echo "═══════════════════════════════════════════════════"
echo ""
echo "Reading brief from: $BRIEF_FILE"
echo "Status file: $STATUS_FILE"
echo "Report file: $REPORT_FILE"
echo ""

# Update status to running
echo "running: agent started" >> "$STATUS_FILE"

# Build prompt from profile + brief
PROMPT="You are operating as a crewmate in the Kiro Dispatcher system.

Your profile instructions:
\$(cat "$PROFILE_PATH")

---

Your task brief:
\$(cat "$BRIEF_FILE" 2>/dev/null || echo 'No brief file found. Ask for instructions.')

---

Environment:
- TASK_ID=$TASK_ID
- WORKTREE=$WORKTREE_DIR
- STATUS_FILE=$STATUS_FILE
- REPORT_FILE=$REPORT_FILE
- PROJECT_ROOT=$PROJECT

When you finish, write your final status to \$STATUS_FILE:
  echo \"done: <summary>\" > $STATUS_FILE

If writing a report, save it to: $REPORT_FILE
"

# Launch the agent
$AGENT_CMD --prompt "\$PROMPT"
SCRIPT_BODY

chmod +x "$STARTUP_SCRIPT"

# --- Spawn tmux window ---
WINDOW_NAME="dispatcher-${TASK_ID}"

# Check if tmux session exists, create if not
if ! tmux has-session -t dispatcher 2>/dev/null; then
  tmux new-session -d -s dispatcher -n "control"
  echo "Created new tmux session: dispatcher"
fi

# Create a new window for this crewmate
tmux new-window -t dispatcher -n "$WINDOW_NAME" "bash $STARTUP_SCRIPT"

echo ""
echo "✓ Crewmate spawned successfully!"
echo "  Task:     $TASK_ID"
echo "  Profile:  $PROFILE"
echo "  Backend:  $BACKEND"
echo "  Window:   tmux → dispatcher:$WINDOW_NAME"
echo "  Worktree: $WORKTREE_DIR"
echo ""
echo "Monitor: $BIN_DIR/fm-status.sh"
echo "Watch:   tmux attach -t dispatcher"
