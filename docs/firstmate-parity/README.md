# Firstmate Parity Package

This directory is the detailed execution package referenced by [`Q_IMPLEMENTATION_HANDOVER.md`](../../Q_IMPLEMENTATION_HANDOVER.md).

## Baseline

- Upstream: `kunchenguid/firstmate`
- Pinned commit: `f9a89c3962a5ad0db3ef79756a477053998c2529`
- Target: Kiro-native functional parity, including the pinned revision’s documented experimental labels and limitations.

## Files

- [`MATRIX.md`](MATRIX.md) — scope ledger and evidence status for every functional domain.
- [`ROADMAP.md`](ROADMAP.md) — dependency-ordered implementation phases and phase exit gates.
- [`VERIFICATION.md`](VERIFICATION.md) — what counts as evidence and when parity may be claimed.

## Rules for the implementing agent

1. Read all four handover files before editing source.
2. Work one approved phase at a time.
3. Update matrix status and evidence in the same change as implementation.
4. Never replace `BLOCKED` or `UNVERIFIED_LIVE` with `VERIFIED` based on reasoning alone.
5. Preserve pinned upstream attribution in [`THIRD_PARTY_NOTICES.md`](../../THIRD_PARTY_NOTICES.md).
6. Keep these implementation instructions out of the runtime dispatcher’s always-loaded resources.

## Status vocabulary

- `NOT_STARTED` — no parity implementation exists.
- `PARTIAL` — some behavior exists, but required contracts/evidence are missing.
- `IN_PROGRESS` — active phase work, not yet accepted.
- `BLOCKED` — implementation cannot proceed without a decision, dependency, credential, or upstream clarification.
- `UNVERIFIED_LIVE` — implementation and isolated tests exist, but required real adapter/integration evidence is absent.
- `VERIFIED` — all evidence required by `VERIFICATION.md` is recorded and passing.

No other status is allowed. `N/A` requires explicit user approval and means the project is no longer targeting literal full functional parity.
