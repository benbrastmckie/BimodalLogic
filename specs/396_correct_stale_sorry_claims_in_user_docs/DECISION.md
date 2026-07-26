# User Decision: Task 396 scope

**Date**: 2026-07-26
**Decided by**: user, in the orchestration session.

## Decision

**Implement the FULL sweep as one task.** Do not split.

Every verified-stale claim found by the research sweep is in scope for this task, not just the
two targets named in the original charter (`architecture.md`, `tactic-registry.md:68`). The
research report already carries per-hit replacement text, so the verification work is done.

## In scope

All hits classified STALE or SCHEMATIC in
`reports/01_docs-staleness-sweep.md`, across: `architecture.md`,
`tactic-registry.md`, `implementation-status.md`, `known-limitations.md`, `README.md`,
`test-coverage.md`, `troubleshooting.md`, `examples.md`, `tutorial.md`,
`tactic-development.md`.

## Out of scope (separate follow-up)

The `Logos/Core/Automation/...` namespace referenced throughout `tactic-registry.md` and
`examples.md` that exists nowhere in the repo. Flagged by the research as its own task.

## Binding constraints (unchanged from charter)

- Verify each claim against the code BEFORE rewriting. Never replace an unverified claim with
  its unverified inverse.
- SCHEMATIC hits (illustrative code blocks, not status claims) get a prose disclaimer —
  do NOT delete the example and do NOT "correct" it into a status claim.
- Documentation-only. Do not modify any .lean file and do not write any proof.
