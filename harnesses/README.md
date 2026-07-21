# Harness adapters

A harness adapter launches one crewmate. `dispatch-run-crew.sh` calls it as:

```text
adapter <complete-prompt> <supervised|trusted>
```

The adapter must:
- run in the assigned git worktree;
- keep the prompt as one argument without evaluating it as shell code;
- stream human-readable output to stdout/stderr;
- remain attached until the agent exits; and
- return zero only when the harness itself completed successfully.

`kiro-cli.sh` is bundled and verified against the installed Kiro CLI help. Other provider adapters should be added only after their executable, authentication, noninteractive behavior, tool-approval flags, and exit codes have been tested locally. Merely changing a command name is not a valid adapter.
