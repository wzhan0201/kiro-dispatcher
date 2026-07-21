# Firstmate Functional Parity Matrix

Pinned upstream: `kunchenguid/firstmate@f9a89c3962a5ad0db3ef79756a477053998c2529`.

This matrix is the scope ledger. Status values are defined in [`README.md`](README.md). “Evidence” must satisfy [`VERIFICATION.md`](VERIFICATION.md). Initial statuses describe Kiro Dispatcher before parity implementation.

## A. Agent distro, instructions, skills, and Kiro integration

| ID | Capability | Initial | Pinned upstream owners | Required parity evidence |
|---|---|---:|---|---|
| A01 | Pinned upstream manifest and drift policy | PARTIAL | `AGENTS.md`, repository tree | Machine-readable pin, inventory check, documented re-pin process |
| A02 | Complete always-loaded operating contract | PARTIAL | `AGENTS.md` sections 1–14 | Contract tests for every authority/lifecycle section |
| A03 | Native Kiro workspace agent | PARTIAL | Harness launch contract; Kiro adaptation | Agent schema validation, discovery, resource-loading smoke test |
| A04 | Plain workspace launch/default agent | NOT_STARTED | Firstmate clone-and-launch UX; Kiro workspace settings | Clean-clone `kiro-cli chat` selects dispatcher without global side effects |
| A05 | Progressive internal skill loader | NOT_STARTED | `.agents/skills/*/SKILL.md` | Kiro `skill://` discovery and on-demand loading tests |
| A06 | Two-tier internal/public skill layout | NOT_STARTED | `.agents/skills/`, `skills/stow/` | Internal skills hidden from standalone use; public skill independent |
| A07 | Kiro session-start hook | NOT_STARTED | `fm-session-start.sh`, session-start adapters | `agentSpawn` hook emits bounded verified startup context |
| A08 | Kiro pre-tool project/fleet guards | NOT_STARTED | CD/ARM/continuity pretool scripts | Exit-2 blocking tests for unauthorized mutation and unhealthy supervision |
| A09 | Kiro post-tool and prompt hooks where needed | NOT_STARTED | Harness integrations | Hook event/schema tests and no duplicate side effects |
| A10 | Kiro stop/turn-end continuity adaptation | NOT_STARTED | turn-end guard scripts/docs | External follow-up/block-equivalent E2E; warning-only hook is insufficient |
| A11 | Granular tool/path/command policy | NOT_STARTED | hard rules, command-policy scripts | Allowed/denied path and command tests, fail-closed malformed policy |
| A12 | Runtime instructions do not load parity handover | PARTIAL | Context ownership conventions | Resource inventory test proving implementation docs are opt-in only |

## B. Operational home, bootstrap, configuration, and locks

| ID | Capability | Initial | Pinned upstream owners | Required parity evidence |
|---|---|---:|---|---|
| B01 | Operational home override and directory ownership | PARTIAL | `FM_HOME`, configuration docs | Default/override tests and cross-home isolation |
| B02 | Canonical `data/`, `state/`, `config/`, `projects/` schemas | PARTIAL | configuration docs, producer headers | Schema docs, parsers, malformed-state tests |
| B03 | Primary session lock and stale-lock recovery | NOT_STARTED | `fm-lock*`, session start | Concurrency, owner identity, stale/dead/live lock tests |
| B04 | Detect-only/read-only session mode | NOT_STARTED | session start/guard contracts | Second-session refusal and read-only behavior tests |
| B05 | Bootstrap tool/version detection and install consent | NOT_STARTED | `fm-bootstrap.sh`, configuration toolchain | Missing/old/valid tools, no-install default, exact suggested commands |
| B06 | Backend-specific dependency delta | NOT_STARTED | `fm-backend.sh`, backend docs | Per-backend dependency matrix and no unrelated install prompts |
| B07 | Primary checkout tangle detection and remediation | NOT_STARTED | `fm-tangle-lib.sh`, `fm-guard.sh` | default/detached/non-default/locked checkout tests |
| B08 | Session-start digest and bounded status tails | NOT_STARTED | `fm-session-start.sh` | Ordering, bounds, malformed state, no duplicate run tests |
| B09 | Local config parsing, precedence, and validation | PARTIAL | configuration docs | CLI/env/file/default precedence and invalid-value tests |
| B10 | Config inheritance into secondmate homes | NOT_STARTED | provisioning/config-push contracts | inherit/non-inherit/quarantine/idempotency tests |

## C. Projects, worktrees, synchronization, and memory

| ID | Capability | Initial | Pinned upstream owners | Required parity evidence |
|---|---|---:|---|---|
| C01 | Project registry and exact project resolution | NOT_STARTED | `data/projects.md`, project-management skill | duplicate/unknown/path/mode validation tests |
| C02 | Project clone provisioning | NOT_STARTED | project management/bootstrap | clone/adopt/refuse dirty or malformed destinations |
| C03 | Project delivery modes: `no-mistakes`, `direct-PR`, `local-only` | NOT_STARTED | project mode and lifecycle contracts | Mode-specific E2E and authority tests |
| C04 | Optional `+yolo` with protected decisions | NOT_STARTED | intake/authority rules | Routine autonomy tests; destructive/security actions still escalate |
| C05 | Pooled Treehouse worktrees and leases | PARTIAL | `fm-spawn.sh`, Treehouse contracts | allocate/reuse/return/lease/collision/live-lock tests |
| C06 | Orca-owned worktree lifecycle | NOT_STARTED | Orca backend | Live Orca create/remove tests and common teardown gates |
| C07 | Primary/project/worktree separation proof | PARTIAL | spawn/guard contracts | Refuse primary checkout and wrong-root task execution |
| C08 | Landed-work proof before teardown | PARTIAL | `fm-teardown.sh` | dirty, unpushed, unmerged, merged, scout-complete cases |
| C09 | Stale Git lock bounded recovery | NOT_STARTED | teardown/fleet-sync lock contracts | live-holder refusal, stale-age proof, bounded retry tests |
| C10 | Safe project fleet refresh and branch pruning | NOT_STARTED | `fm-fleet-sync.sh` | clean FF, dirty/diverged/off-default/detached/checked-out branch tests |
| C11 | Project `AGENTS.md` ownership and maintenance skeleton | NOT_STARTED | `fm-ensure-agents-md.sh` | create/promote/reconcile/case-sensitive hazard tests |
| C12 | Operational memory routing and inspect-then-update | PARTIAL | stow skill, memory ownership | captain/shared/learnings/project/backlog routing tests |

## D. Task, backlog, decision, validation, and delivery lifecycle

| ID | Capability | Initial | Pinned upstream owners | Required parity evidence |
|---|---|---:|---|---|
| D01 | Ship/scout classification and intake authority | PARTIAL | AGENTS lifecycle | ambiguous request, destructive request, ship/scout tests |
| D02 | Standalone brief generation and validation | PARTIAL | `fm-brief.sh`, brief contract | Required sections, path/authority/mode/profile validation |
| D03 | Task IDs, metadata schema, and selector vocabulary | PARTIAL | spawn/backend metadata owners | collision, malformed metadata, exact selector precedence tests |
| D04 | Append-only status event vocabulary | NOT_STARTED | classify/state contracts | recognized/unrecognized/decision-only/paused event tests |
| D05 | Current-state reconciliation | NOT_STARTED | `fm-crew-state.sh` | run/backend/status precedence and dead-pane stale-log tests |
| D06 | Backlog sections, dependencies, and atomic transitions | NOT_STARTED | `.tasks.toml`, tasks-axi contract | queued/in-flight/done/archive/dependency tests |
| D07 | Manual backlog fallback | NOT_STARTED | backlog backend config | same file format and behavior without tasks-axi |
| D08 | Keyed decision holds and resolutions | NOT_STARTED | decision-hold skill/scripts | hold/resolution/same-key/teardown gate/restart tests |
| D09 | Scout report storage, decision inventory, and promotion | PARTIAL | scout lifecycle | complete/incomplete report, unresolved decisions, promote-to-ship tests |
| D10 | Validation/check registration and execution | NOT_STARTED | check libs, no-mistakes | command ownership, timeout, evidence, failure propagation tests |
| D11 | Diff review against authoritative base/PR head | NOT_STARTED | `fm-review-diff.sh` | remote PR ref, offline fallback, stale local branch tests |
| D12 | PR discovery, checking, and polling | NOT_STARTED | `fm-pr-*` | URL/repo/head/check status and auth failure tests |
| D13 | Guarded PR merge | NOT_STARTED | `fm-pr-merge.sh` | approval, malformed URL, repo override, method, recorded state tests |
| D14 | Approved local fast-forward merge | NOT_STARTED | `fm-merge-local.sh` | approval, FF-only, dirty/diverged/refusal tests |
| D15 | Teardown archives state and preserves evidence | PARTIAL | teardown contract | backend/worktree/status/report/branch cleanup and refusal matrix |

## E. Supervision, watcher continuity, recovery, and fleet views

| ID | Capability | Initial | Pinned upstream owners | Required parity evidence |
|---|---|---:|---|---|
| E01 | Durable actionable wake queue | NOT_STARTED | watcher architecture, wake libs | enqueue-before-advance, drain, crash recovery, dedupe tests |
| E02 | Singleton watcher lock and liveness beacon | NOT_STARTED | watcher lock/arm | race, stale PID, stale beacon, successor identity tests |
| E03 | Event classification and benign-wake absorption | NOT_STARTED | classify lib | terminal/progress/free-text/heartbeat/paused tests |
| E04 | Busy, idle, dead, unknown endpoint evidence | PARTIAL | backend/state contracts | backend-specific and fail-open/unknown tests |
| E05 | Stale pane, pause resurfacing, and wedge escalation | NOT_STARTED | watcher | time-controlled escalation count and deep-inspection tests |
| E06 | Slow checks: PR, custom checks, X poll | NOT_STARTED | watcher/check contracts | cadence, timeout, authentication failure, batching tests |
| E07 | Watch arm, checkpoint, and cycle ledger | NOT_STARTED | watch-arm/checkpoint | started/attached/failed/successor/empty-close tests |
| E08 | Pull-based fleet guard | NOT_STARTED | `fm-guard.sh` | tangle, watcher down, queued wakes, read-only warnings |
| E09 | Push-based turn-end continuity | NOT_STARTED | turn-end guard integrations | Kiro external-injection E2E and loop prevention |
| E10 | Session-start dead crew/secondmate recovery | NOT_STARTED | recovery skills/session start | alive/dead/unknown, no duplicate, confirmed-dead respawn tests |
| E11 | Structured fleet snapshot JSON | NOT_STARTED | `fm-fleet-snapshot.sh` | schema, bounds, malformed inputs, cross-home tests |
| E12 | Human fleet view and bearings report | NOT_STARTED | fleet view/bearings skill | deterministic render and optional live PR enrichment |
| E13 | Safe send, peek, interrupt, and submit confirmation | NOT_STARTED | send/backend/composer libs | pending/empty/unknown composer and retry tests |

## F. AFK supervision and alerts

| ID | Capability | Initial | Pinned upstream owners | Required parity evidence |
|---|---|---:|---|---|
| F01 | AFK skill and presence-gated supervisor daemon | NOT_STARTED | afk skill/scripts | enter/operate/exit lifecycle tests |
| F02 | Routine self-handling and escalation batching | NOT_STARTED | supervise daemon | classification, batching, heartbeat, pause tests |
| F03 | Crash-loop protection and watcher restoration | NOT_STARTED | daemon/watch continuity | bounded retries/backoff/single-flight tests |
| F04 | Safe primary-terminal digest injection | NOT_STARTED | supervisor target/backend | empty/pending/unknown/dead composer tests |
| F05 | Wedge detection and durable marker | NOT_STARTED | daemon | defer threshold, marker, retry tests |
| F06 | Active alert channels and rate limits | NOT_STARTED | wedge alarm docs | macOS/mock command/herdr/off/fallback/timeout tests |
| F07 | Ordered AFK return and catch-up gate | NOT_STARTED | afk return | live task/blocker/durable catch-up/fail-closed tests |

## G. Runtime backends

| ID | Capability | Initial | Pinned upstream owners | Required parity evidence |
|---|---|---:|---|---|
| G01 | Backend interface and selection precedence | NOT_STARTED | `fm-backend.sh` | explicit/env/config/autodetect/default/invalid tests |
| G02 | tmux reference backend | PARTIAL | `bin/backends/tmux.sh` | full create/capture/send/cwd/busy/alive/kill E2E |
| G03 | Herdr experimental backend | NOT_STARTED | Herdr adapter/docs | version gate, workspace/tab/pane, event wait, live E2E |
| G04 | Zellij experimental backend | NOT_STARTED | Zellij adapter/docs | version gate, tab identity, exit-code mitigation, live E2E |
| G05 | Orca experimental backend | NOT_STARTED | Orca adapter/docs | terminal/worktree ownership, selector, live E2E |
| G06 | cmux experimental backend | NOT_STARTED | cmux adapter/docs | socket auth, workspace/surface, fresh-screen quirks, live E2E |
| G07 | Backend selector and metadata compatibility | NOT_STARTED | configuration selector owner | task ID, explicit endpoint, aliases, backend fields tests |
| G08 | Shared ANSI/composer classification | NOT_STARTED | composer lib | ghost/border/prompt/placeholder/theme fixtures |
| G09 | Backend-safe test cleanup | NOT_STARTED | backend safety tests | isolated resources only; never global kill/close |
| G10 | Document Codex App boundary (not selectable) | NOT_STARTED | Codex App backend doc | explicit refusal and accurate boundary documentation |

## H. Harnesses and dispatch profiles

| ID | Capability | Initial | Pinned upstream owners | Required parity evidence |
|---|---|---:|---|---|
| H01 | Harness abstraction and capability schema | PARTIAL | harness adapter skill/spawn | launch, model, effort, trust, busy, interrupt, exit, skill syntax |
| H02 | Kiro CLI harness | PARTIAL | Kiro adaptation | pinned version help plus supervised/trusted/live task tests |
| H03 | Claude Code harness | NOT_STARTED | verified upstream adapter | live launch, wake, turn-end, busy/exit trial |
| H04 | Codex CLI harness | NOT_STARTED | verified upstream adapter | live checkpoint, model/effort, busy/exit trial |
| H05 | Grok harness | NOT_STARTED | verified upstream adapter | live background notify, hook, busy/exit trial |
| H06 | Pi harness | NOT_STARTED | verified upstream adapter | live extensions/watch, model/effort, exit trial |
| H07 | OpenCode harness | NOT_STARTED | verified upstream adapter | live plugin, queued submit, busy/exit trial |
| H08 | Static crew/secondmate harness config | NOT_STARTED | configuration docs | precedence, defaults, inheritance, invalid values |
| H09 | Natural-language dispatch profile schema | NOT_STARTED | crew-dispatch config | JSON shape, explicit resolution requirement, malformed tests |
| H10 | Model/effort propagation and compatibility | NOT_STARTED | spawn/harness contracts | supported/unsupported/override/audit metadata tests |
| H11 | Quota-balanced deterministic selector | NOT_STARTED | `fm-dispatch-select.sh`, quota-axi | data/no-data/tie/fallback tests |
| H12 | Empirical adapter admission process | NOT_STARTED | harness skill/docs | recorded version, sanitized evidence, supervised trial gate |

## I. Persistent secondmates and cross-home operation

| ID | Capability | Initial | Pinned upstream owners | Required parity evidence |
|---|---|---:|---|---|
| I01 | Secondmate route registry and scope routing | NOT_STARTED | provisioning skill, `data/secondmates.md` | parser, duplicates, overlaps, judgment handoff tests |
| I02 | Transactional home seeding | NOT_STARTED | `fm-home-seed.sh` | clone/init/rollback/identity marker tests |
| I03 | Project-less durable leased homes | NOT_STARTED | provisioning/treehouse | lease/restart/return/refusal tests |
| I04 | Independent home state/config/projects/lock | NOT_STARTED | `FM_HOME`/secondmate contracts | cross-home isolation and wrong-home send refusal |
| I05 | Secondmate harness/model/effort | NOT_STARTED | secondmate harness config | fallback/override/no nested secondmate tests |
| I06 | Backlog handoff | NOT_STARTED | `fm-backlog-handoff.sh` | queued-only, atomic move, malformed body, idempotency tests |
| I07 | Shared preference/config propagation | NOT_STARTED | provisioning/config-push | read-only copy, quarantine, skip/error tests |
| I08 | Version sync and reread nudges | NOT_STARTED | update/provisioning | FF-only, divergent/dirty refusal, idempotent retry tests |
| I09 | Liveness recovery and safe retirement | NOT_STARTED | session start/teardown | alive/dead/unknown, in-flight refusal, lease return tests |
| I10 | Authoritative cross-home state projection | NOT_STARTED | fleet snapshot architecture | structured-home precedence, bounded unknown/error tests |

## J. Skills, memory, self-update, and optional public mode

| ID | Capability | Initial | Pinned upstream owners | Required parity evidence |
|---|---|---:|---|---|
| J01 | AFK skill | NOT_STARTED | `.agents/skills/afk` | Skill trigger and F-domain acceptance |
| J02 | Bearings skill | NOT_STARTED | bearings skill/scripts | standalone dated report and read-mostly behavior |
| J03 | Bootstrap diagnostics skill | NOT_STARTED | bootstrap diagnostics | missing-tool and recovery guidance tests |
| J04 | Decision-hold skill | NOT_STARTED | decision hold skill | D08 acceptance |
| J05 | Diagnostic reasoning skill | NOT_STARTED | diagnostic skill | evidence/uncertainty/recovery output tests |
| J06 | Coding guidelines skill | NOT_STARTED | coding guidelines | loaded-on-demand and project-convention behavior |
| J07 | Harness adapter skill | NOT_STARTED | harness adapter skill | H-domain capability reference and admission process |
| J08 | Project management skill | NOT_STARTED | project management skill | C-domain behavior and scope routing |
| J09 | Secondmate provisioning skill | NOT_STARTED | provisioning skill | I-domain lifecycle |
| J10 | Internal stow skill | NOT_STARTED | internal stow | C12 routing and resume pointer tests |
| J11 | Standalone public stow skill | NOT_STARTED | `skills/stow` | Works without dispatcher paths/vocabulary |
| J12 | Stuck-crewmate recovery skill | NOT_STARTED | recovery skill | E10 recovery and safe replacement tests |
| J13 | Self-update skill | NOT_STARTED | update skill/scripts | FF-only primary/secondmate update, reread, refusal tests |
| J14 | Public-response/X skill | NOT_STARTED | fmx-respond/X scripts | J16–J20 acceptance |
| J15 | Dispatcher self-update and instruction reload | NOT_STARTED | `fm-update.sh` | offline/dirty/diverged/success/nudge tests |
| J16 | Public relay opt-in and secure token boundary | NOT_STARTED | X mode config | absent-token no-op; no secret output; explicit consent gate |
| J17 | Inbox/context/outbox and offer dedupe | NOT_STARTED | X mode scripts | retention, reoffer, concurrent IDs, malformed payload tests |
| J18 | Reply/dismiss/thread/image/dry-run clients | NOT_STARTED | X clients | split limits, media validation, network-free dry-run tests |
| J19 | Task links, milestones, final follow-ups | NOT_STARTED | X link/followup | count/window/platform carry/final cleanup tests |
| J20 | Public-request security classification | NOT_STARTED | X skill/authority | reversible action, destructive escalation, owner/context tests |

## K. Documentation, CI, migration, provenance, and release acceptance

| ID | Capability | Initial | Pinned upstream owners | Required parity evidence |
|---|---|---:|---|---|
| K01 | Upstream attribution and copied-file headers | PARTIAL | MIT license | Notice review and source mapping |
| K02 | Architecture/configuration/script/backend docs | PARTIAL | 24 upstream docs | User/operator/developer docs for every implemented domain |
| K03 | Compatibility and migration guide | NOT_STARTED | Current Dispatcher baseline | Existing command/config/state migration tests |
| K04 | Unit and contract test parity | PARTIAL | 93 upstream tests | Crosswalk from every relevant upstream test family |
| K05 | Integration/restart/safety test parity | NOT_STARTED | upstream E2E/safety tests | Clean, failure, crash, restart, race, destructive refusal suites |
| K06 | Live backend/harness evidence | NOT_STARTED | sanitized live evidence docs | Versioned, sanitized, reproducible trial records |
| K07 | CI dependency and matrix coverage | PARTIAL | upstream CI | Pinned Actions, deterministic suite, optional live jobs gated |
| K08 | Clean-checkout bootstrap and operation | NOT_STARTED | quick start | New clone, no hidden local files, documented consent flow |
| K09 | Independent security/correctness review | NOT_STARTED | contribution gate | No unresolved critical/high findings |
| K10 | Final parity report and user acceptance | NOT_STARTED | entire pin | Every row `VERIFIED`, final report, explicit user approval |

## Evidence column update format

When work begins, append an `Evidence` item beneath the relevant section or extend the row’s final cell with stable references:

```text
Evidence: commit <sha>; tests <paths> (pass); live run <record>; docs <paths>
```

Do not use “implemented,” “looks correct,” or an agent summary as evidence.
