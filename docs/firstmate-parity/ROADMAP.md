# Firstmate Parity Implementation Roadmap

This roadmap is dependency-ordered. The implementing agent must execute one user-approved phase at a time and update [`MATRIX.md`](MATRIX.md) with evidence.

## Phase 0 — Baseline, provenance, and harness-safe workspace

**Rows:** A01, A12, K01, K07.

Deliverables:
- Verify clean local baseline and existing tests.
- Create a dedicated `parity/...` branch.
- Create disposable pinned upstream checkout at `f9a89c3962a5ad0db3ef79756a477053998c2529`.
- Record a machine-readable pin and inventory assertion.
- Confirm MIT attribution and copied/adapted-file header policy.
- Verify and extend the tracked matrix validation script so it rejects unknown status values and missing or duplicate IDs.

Exit gate:
- Existing `tests/lint.sh` and `tests/smoke.sh` pass unchanged.
- Pin/inventory/notice checks pass.
- No runtime agent auto-loads this handover.

## Phase 1 — Kiro-native distro contract, skills, settings, and hooks

**Rows:** A02–A11, J03–J09.

Deliverables:
- Expand the authoritative operating contract to upstream-equivalent sections under Kiro Dispatcher naming.
- Add progressive `.kiro/skills/*/SKILL.md` resources with valid frontmatter.
- Configure workspace default agent without modifying global settings.
- Implement `agentSpawn`, prompt, pre/post-tool, and stop hook scripts.
- Add granular tool path/command policy.
- Design and prototype the external turn-end continuity workaround.

Exit gate:
- Clean-clone native launch works.
- Skill metadata loads progressively.
- Unauthorized dispatcher writes are blocked by pre-tool tests.
- Stop-warning behavior is not misrepresented as continuity parity.

## Phase 2 — Operational home, schemas, locks, and bootstrap

**Rows:** B01–B10, C01–C02.

Deliverables:
- Canonical home/root/state/data/config/projects resolvers with compatibility aliases.
- Machine-validated state and registry formats.
- Session lock, stale recovery, detect-only/read-only mode.
- Tool/version detection with consent-only installation guidance.
- Tangle guard and bounded startup digest.
- Project registration and clone/adoption flow.

Exit gate:
- Concurrent session and stale-lock tests pass.
- No install occurs during tests or without explicit approval.
- Wrong-home and cross-home mutations fail closed.

## Phase 3 — Reference tmux/backend abstraction and worktree lifecycle

**Rows:** C05–C09, D03, G01–G02, G07–G09, E13.

Deliverables:
- Backend operation interface and selection precedence.
- Full tmux reference adapter.
- Treehouse pooled worktree integration and leases.
- Shared selector, capture, send, submit, composer, interrupt, and teardown contracts.
- Primary-checkout exclusion and landed-work proof.
- Stale lock bounded recovery.

Exit gate:
- tmux live E2E covers create/capture/send/work/cancel/exit/teardown.
- Dirty, unlanded, wrong-root, and ambiguous composer paths refuse safely.
- Current raw-worktree users have a migration path.

## Phase 4 — Task, backlog, decision, and scout lifecycle

**Rows:** D01–D09, D15, C12.

Deliverables:
- Intake and authority classification.
- Complete brief schema.
- Append-only status events and current-state reconciliation.
- Backlog with dependencies, archive, tasks-axi and manual paths.
- Keyed decision holds.
- Scout reports, decision inventory, promotion, and teardown gate.
- Memory routing and stow foundations.

Exit gate:
- Every transition has deterministic tests.
- Restart reconstructs state without trusting stale terminal text.
- Unresolved decisions and incomplete scouts block teardown.

## Phase 5 — Project modes, validation, PRs, and landing

**Rows:** C03–C04, D10–D14, C10–C11.

Deliverables:
- `no-mistakes`, `direct-PR`, `local-only`, and protected `+yolo` authority.
- Validation/check registration and evidence.
- Authoritative diff and PR-head handling.
- PR poll/check/merge and local FF merge.
- Project `AGENTS.md` management.
- Safe post-landing clone refresh and pruning.

Exit gate:
- Mode-by-mode E2E passes with mocked GitHub and approved live GitHub trial.
- Merge paths require proper authority.
- Teardown proves landing rather than merely cleanliness.

## Phase 6 — Durable event-driven supervision and Kiro continuity

**Rows:** E01–E10.

Deliverables:
- Wake queue, watcher lock, heartbeat, classification, current-state integration.
- Stale/pause/wedge cadence and slow checks.
- Arm/checkpoint/cycle ledger.
- Pull guard and Kiro push/external turn-end continuity.
- Dead endpoint recovery.

Exit gate:
- Zero-token idle operation demonstrated.
- Crash/restart/missed-wake tests recover queued work.
- A Kiro turn cannot silently end with in-flight work and no healthy supervision.

## Phase 7 — Fleet views, bearings, memory, and self-update

**Rows:** E11–E12, J02, J05, J10–J13, J15.

Deliverables:
- Structured fleet snapshot schema and Markdown view.
- Bearings skill with bounded local state and optional PR enrichment.
- Internal/public stow separation.
- Diagnostic/recovery skills.
- Fast-forward-only self-update and instruction reload.

Exit gate:
- Views never treat terminal prose as authoritative state.
- Memory routes to the most specific owner.
- Dirty/diverged/offline updates refuse without loss.

## Phase 8 — Persistent secondmates

**Rows:** I01–I10, B10.

Deliverables:
- Route registry, scope judgment, transactional seeding.
- Project-bearing and project-less leased homes.
- Independent locks/state/config/projects.
- Handoff, preference/config propagation, version sync, liveness recovery, retirement.
- Cross-home state projection.

Exit gate:
- Full secondmate lifecycle/restart/safety suite passes.
- No nested secondmates or local-only routing violations.
- Seed failures roll back completely.

## Phase 9 — Harness dispatch and live adapter matrix

**Rows:** H01–H12.

Deliverables:
- Capability schema and static/secondmate/dispatch-profile selection.
- Model/effort and quota-balanced routing.
- Kiro, Claude, Codex, Grok, Pi, and OpenCode adapters.
- Empirical admission records.

Exit gate:
- Mock contract suite passes for every harness.
- Each available/authenticated harness has a sanitized live trial.
- Unavailable harnesses remain `UNVERIFIED_LIVE`, blocking final parity.

## Phase 10 — Experimental runtime backends

**Rows:** G03–G06, G10, B06.

Deliverables:
- Herdr, Zellij, Orca, and cmux adapters and dependency/version gates.
- Backend-specific metadata, container shape, liveness, and cleanup.
- Accurate Codex App non-selectable boundary.

Exit gate:
- Isolated safety tests pass for all adapters.
- Live trials record exact supported versions and known upstream-equivalent limitations.
- Tests never kill global sessions/workspaces.

## Phase 11 — AFK supervision and active alerts

**Rows:** F01–F07, J01.

Deliverables:
- AFK skill, foreground helper, supervisor daemon.
- Batched digests, pause handling, crash loops, safe injection.
- Wedge marker and alert channels.
- Ordered return and catch-up gate.

Exit gate:
- Time-controlled tests cover routine, actionable, paused, crash, wedge, and return paths.
- Alert tests use seams/mocks and never post real notifications unintentionally.

## Phase 12 — Optional public/X mode

**Rows:** J14, J16–J20.

Precondition: explicit user authorization for networked/public behavior.

Deliverables:
- Presence-gated token opt-in, inbox/context/outbox.
- Poll/reply/dismiss/follow-up clients.
- Thread splitting, images, dry-run, task links, retention and caps.
- Public request security classification.

Exit gate:
- Entire dry-run suite is network-free.
- Live relay trial uses a test tenant and explicit approval.
- Secrets never appear in logs, reports, fixtures, or Git.

## Phase 13 — Documentation, migration, full regression, and acceptance

**Rows:** K02–K10 and every row not yet `VERIFIED`.

Deliverables:
- Architecture, configuration, scripts, skills, backend, troubleshooting, migration, and security docs.
- Crosswalk for all 93 upstream test files to local tests or approved equivalent coverage.
- Clean-checkout bootstrap and restart exercise.
- Full CI and optional gated live matrix.
- Independent security/correctness audit.
- Final parity report.

Exit gate:
- Every matrix row is `VERIFIED`.
- CI and required live trials pass on the proposed commit.
- User explicitly accepts parity.

## Handling blockers

When blocked:

1. Set the row to `BLOCKED` or `UNVERIFIED_LIVE`.
2. Record the exact missing dependency, account, external application, decision, or upstream ambiguity.
3. Provide a mocked/isolated test path where possible.
4. Stop before installing, authenticating, posting publicly, or weakening scope.
5. Ask one concrete question with the safest default.

A blocker is not permission to skip a row or declare phase completion.
