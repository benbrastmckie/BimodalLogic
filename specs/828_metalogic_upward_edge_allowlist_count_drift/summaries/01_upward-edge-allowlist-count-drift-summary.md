# Implementation Summary: Task #828

- **Task**: 828 - Metalogic upward-edge allowlist count drift (CI red on `main`)
- **Status**: [COMPLETED]
- **Started**: 2026-11-02T22:40:00Z
- **Completed**: 2026-11-02T23:10:00Z
- **Effort**: ~0.5 hours
- **Dependencies**: None
- **Artifacts**: plans/01_upward-edge-allowlist-count-drift.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

`bash scripts/check-metalogic-cycles.sh` was failing on `main` because the measured upward
import set grew to eight lines (all `FormalSystem.MinusLanguage.AxiomDischarge ->
FormalSystem.Theorems.*`) while the recorded allowlist and three documentation files still
recorded seven. The eighth line (`-> Theorems.LinearityDerived`) is a legitimate member of the
same accepted class as the other seven, so the fix was additive: admit the entry to the
allowlist and correct every live count statement from seven to eight across the four in-scope
files, in one atomic commit.

## What Changed

- `scripts/check-metalogic-cycles.sh` — inserted `"LinearityDerived"` into the `ALLOWLIST`
  frozenset (alphabetically between `"GeneralizedNecessitation"` and `"Propositional.Core"`);
  corrected four prose counts from 7/seven to 8/eight (`:7`, `:55`, `:56`, `:186`).
- `scripts/measure-refactor-partitions.py` — corrected five docstring/comment counts from 7 to 8
  (`:49`, `:51`, `:57`, `:175`, `:179`); `LAYERS`/`LANGUAGE_FILE_LAYERS` tables left untouched,
  as required (the script already classifies `AxiomDischarge`/`Theorems` correctly, which is
  why the edge measures as upward).
- `docs/ARCHITECTURE.md` — corrected seven prose/diagram counts from seven/7 to eight/8
  (diagram label, heading, bolded count, two "same lines" references, the verification-page
  count, and the fenced-block comment); inserted `LinearityDerived` into the parenthesized
  theorem-name list between `GeneralizedNecessitation` and `Propositional.Core`.
- `ORGANISATION.md` — corrected three prose counts from 7 to 8 (`:51`, `:53`, and the
  fenced-block comment at `:220`); left the dated counterfactual snapshot table (`:73`-`:78`)
  and the "seven sibling aggregators" line (`:91`) unchanged per the plan's Decisions section,
  since neither is a live claim about the upward-set count.

## Decisions

- `ORGANISATION.md:73-78`'s counterfactual table (pre-dating `OpenLanguage/`, `HybridLanguage/`,
  `QuantLanguage/`) was left at its historical `7` values rather than hand-bumped, per the
  plan's Decisions section: its rows carry co-dependent totals that cannot be re-derived by
  incrementing one cell, and the measurement script exposes no re-run mode for it.
- `LinearityDerived`'s insertion position (alphabetical) is cosmetic only; `ALLOWLIST` is a
  `frozenset`, so literal ordering never affects the gate's behavior.

## Plan Deviations

- None (implementation followed plan exactly; every re-grepped line number in the plan's
  inventory matched the file state precisely, including the forbidden/out-of-scope line lists).

## Verification

- Build: N/A (no `.lean` file touched)
- Tests:
  - `bash scripts/check-metalogic-cycles.sh` exits 0, `PASS  upward import set is exactly the
    recorded 8 line(s)`.
  - `python3 scripts/measure-refactor-partitions.py upward-edges` reports the same eight
    `AxiomDischarge -> Theorems.*` edges, no syntax damage from the docstring edits.
  - `bash scripts/check-module-invariants.sh --no-build` exits 0, `ALL CHECKS PASSED` (46 PASS +
    1 `INFO C36b skipped (--no-build)`).
  - `bash .claude/scripts/verify-deploy.sh` (unfiltered): `PASS -- 15 check(s), 0 failure(s)`.
  - Residual sweep `grep -nE 'seven|\b7\b|7-line|7 line'` over all four in-scope files: every
    surviving hit is on the explicitly-forbidden list (dated counterfactual table, "seven
    language directories", "7 inference rules", "seven sibling aggregators"); none is a live
    upward-set count.
  - `git diff` scope: exactly the four in-scope files edited; no `FormalSystem/**` path touched.
- Files verified: Yes

## Impacts

- CI's `check-metalogic-cycles.sh` step (and the aggregating gate that reports its outcome) is
  green again on `main`.
- `docs/ARCHITECTURE.md` and `ORGANISATION.md` now state the correct upward-edge count
  consistently with the mechanically-enforced allowlist, closing the count-drift class of defect
  for this specific set of files.

## Follow-ups

- The structural cause (a count hand-typed in N prose places rather than generated from
  `len(ALLOWLIST)`) was explicitly out of scope for this task and remains a candidate follow-up,
  as noted by the research report.
- Two residual, deliberately out-of-scope "7" mentions remain untouched:
  `scripts/README.md:18` and `docs/development/PUBLICATION_REFACTOR.md` (a dated program
  record); neither is named by `FILE SCOPE` or the acceptance line.

## References

- Plan: `specs/828_metalogic_upward_edge_allowlist_count_drift/plans/01_upward-edge-allowlist-count-drift.md`
- Research report: `specs/828_metalogic_upward_edge_allowlist_count_drift/reports/01_upward_edge_allowlist_count_drift.md`
- Progress files: `specs/828_metalogic_upward_edge_allowlist_count_drift/progress/phase-1-progress.json`, `specs/828_metalogic_upward_edge_allowlist_count_drift/progress/phase-2-progress.json`
