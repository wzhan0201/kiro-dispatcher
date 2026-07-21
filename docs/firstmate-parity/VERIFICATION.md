# Firstmate Parity Verification Contract

This file defines what counts as implementation evidence. It is binding for every row in [`MATRIX.md`](MATRIX.md).

## Evidence hierarchy

A row may become `VERIFIED` only with all applicable layers:

1. **Static evidence** — schema/config validation, lint, type checks, syntax checks.
2. **Unit evidence** — deterministic functions, parsers, state transitions, policy decisions.
3. **Contract evidence** — common backend/harness/state interfaces against fixtures and fakes.
4. **Integration evidence** — multiple real local components, isolated filesystem/process/session resources.
5. **Failure and safety evidence** — malformed input, races, timeouts, crashes, dirty state, ambiguous liveness, unauthorized action.
6. **Restart evidence** — kill/restart/reconcile without conversation memory.
7. **Live adapter evidence** — required when behavior depends on a real external CLI, GUI, API, auth session, or provider.
8. **Documentation evidence** — operator setup, limits, recovery, migration, and security boundaries match tested behavior.

Reasoning, code inspection, generated prose, mocked-only adapter results, and an agent saying “done” are not sufficient alone.

## Status transitions

Allowed transitions:

```text
NOT_STARTED -> IN_PROGRESS
PARTIAL -> IN_PROGRESS
IN_PROGRESS -> PARTIAL | BLOCKED | UNVERIFIED_LIVE | VERIFIED
BLOCKED -> IN_PROGRESS
UNVERIFIED_LIVE -> IN_PROGRESS | VERIFIED
VERIFIED -> IN_PROGRESS   # regression or baseline change reopens the row
```

Every transition to `VERIFIED` must add stable evidence references. A changed implementation invalidates stale evidence unless the relevant tests rerun.

## Baseline and provenance checks

Required automated checks:

- Pin equals `f9a89c3962a5ad0db3ef79756a477053998c2529`.
- Public upstream tree inventory matches the recorded baseline or reports drift.
- Upstream MIT notice is present.
- Copied/adapted files identify their source where material portions remain.
- No upstream credentials, local state, `.env`, screenshots, or private artifacts are vendored.

## Test design rules

- Use temporary directories and uniquely named sessions/workspaces.
- Cleanup only resources created by the test.
- Never use global destructive commands such as killing all sessions/workspaces.
- Control time through injectable clocks/poll intervals instead of long sleeps.
- Sanitize ANSI/terminal fixtures deterministically.
- Mock network calls by default.
- Tests requiring credentials or external applications must be explicitly gated and skipped with a clear reason when unavailable.
- A skipped required live test leaves its row `UNVERIFIED_LIVE`.
- Verify both success and refusal behavior.
- Prefer behavior assertions over exact incidental output.
- Test Bash 3.2 where scripts claim macOS compatibility, plus the CI shell environment.

## Mandatory safety scenarios

At minimum, automated tests must prove:

- Dispatcher cannot write project code directly outside authorized guarded exceptions.
- A crewmate cannot accidentally run in a primary project checkout.
- Dirty or unlanded work is not destroyed.
- Live Git lock files are never removed as stale.
- Unknown liveness does not trigger duplicate agents or destructive recovery.
- An unhealthy/missing watcher is surfaced while work is in flight.
- Wake records survive watcher/dispatcher crashes.
- Decision holds and incomplete scout reports block teardown.
- Merge/deploy/public-post/security-sensitive actions require correct authority.
- `+yolo` does not authorize destructive, irreversible, or security-sensitive actions.
- Cross-home sends and state changes resolve to the intended home.
- Public/X dry-run performs no network operation.
- Secrets are redacted and absent from logs/fixtures/reports.
- Backend test cleanup is scoped to test-created resources.

## Restart and continuity suite

The suite must cover:

1. Dispatcher exits with idle fleet.
2. Dispatcher exits with active crewmates and healthy watcher.
3. Watcher exits before queue drain.
4. Queue record exists when process exits.
5. Crewmate endpoint dies while status says working.
6. Status says terminal while matching validation/PR process still runs.
7. Declared external wait persists across restart.
8. Secondmate is alive, dead, or liveness-unknown at restart.
9. Lock owner dies during acquisition and after acquisition.
10. Primary/session resumes and reconciles without relying on prior chat context.

## Backend adapter acceptance

Every selectable backend must demonstrate:

- Dependency and version gate.
- Endpoint creation with unique home/task identity.
- Bounded capture.
- Text and key send with submit confirmation.
- Current-path/worktree discovery where applicable.
- Busy/idle/unknown semantics.
- Agent-process liveness where claimed; otherwise honest `unknown`.
- Safe endpoint teardown.
- Restart discovery/adoption behavior.
- Isolated test cleanup.
- Real live trial on the documented version.

Experimental upstream backends may remain labeled experimental, but still require equivalent tested behavior and documented limitations.

## Harness adapter acceptance

Every admitted harness must demonstrate:

- Exact installed version in evidence.
- Launch and prompt delivery.
- Trust/approval behavior.
- Model/effort flags only where supported.
- Busy signatures and completion detection.
- Interrupt and clean exit.
- Skill invocation behavior.
- Watcher wake/continuity behavior.
- Turn-end backstop behavior.
- Sanitized live trial with no credential material captured.

Kiro additionally requires evidence that the external continuity mechanism closes the documented non-blocking `stop`-hook gap.

## Network and public integration acceptance

Before any live network test:

- Obtain explicit user approval.
- Use a test account/tenant where possible.
- Confirm endpoint allowlist and payload redaction.
- Keep tokens only in approved local secret storage.
- Record request IDs and outcomes, never token values.
- Provide a dry-run path covering payload shape and state transitions.

## Phase gate commands

Each phase must define targeted commands. The minimum repository-wide gate remains:

```bash
tests/lint.sh
python3 tests/handover.py
tests/smoke.sh
git diff --check
```

As the suite grows, add one canonical test runner rather than relying on undocumented command lists. CI and local gates must call the same owner script.

## Evidence record format

For each verified matrix row, record:

```text
Status: VERIFIED
Implementation: <paths and commit>
Automated: <test paths and exact pass result>
Safety/failure: <test paths and exact pass result>
Restart: <test/run when applicable>
Live: <sanitized record, version, date when applicable>
Docs: <operator/developer docs>
Limitations: <upstream-equivalent limitations only>
Reviewer: <independent review reference when required>
```

## Full parity acceptance

A final parity recommendation is invalid unless:

- Every matrix row is `VERIFIED`.
- No required test is skipped.
- Clean-checkout bootstrap and full suite pass.
- Required live backend/harness trials pass.
- GitHub CI is green on the proposed commit.
- Dependency versions and external limitations are documented.
- Migration from the original 24-file Dispatcher baseline is tested.
- Attribution is complete.
- Independent review has no unresolved critical/high findings.
- The user explicitly approves the final parity report.

If any condition is unmet, report the precise percentage/count of verified matrix rows and the remaining blockers; do not round up to “100%.”
