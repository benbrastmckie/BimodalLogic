# Implementation Summary: Task #745

- **Task**: 745 - Requirement (C) of the ray-product verdict: Hit-level completeness with a computable bound -- settle HitPresented first
- **Status**: [IN PROGRESS]
- **Started**: 2026-10-08T23:51:39Z
- **Completed**: 2026-10-09T00:02:00Z
- **Effort**: ~0.2 hours
- **Dependencies**: None ((S) is an independent sibling record; (W) is downstream of both)
- **Artifacts**: plans/01_hit-presented-model-a.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Single-phase dispatch: Phase 1 of the eight-phase plan only, per the dispatch's phase mission.
Phase 1 states the Hit-level hypothesis `HitPresented` in the library beside `Presented` and
records that it is strictly weaker, via `hitPresented_of_presented`. Both declarations land
sorry-free in `FormalSystem/Metalogic/Decidability/RaySummary/Trace.lean` with the axiom foot the
plan required. Phases 2-8 — the probe itself, the fixture transcription, the splice
identification, the truncation bound, the presentation data, the run characterization, the
assembly, and the wiring/pins/docs/bound-verdict — are NOT attempted here and remain
`[NOT STARTED]`.

Nothing is claimed about requirement (C) itself by this phase. `HitPresented` is now a
*declaration*, not a *discharged* hypothesis: no model satisfies it in the tree yet, and the
fixture-level discharge is phases 2-7's work.

## What Changed

- `FormalSystem/Metalogic/Decidability/RaySummary/Trace.lean` — +44 lines inside
  `section Presented`, after `hit_eq_hitOf_of_presented`:
  - `HitPresented` — a `def … : Prop`, body `HitCl M τ t φ k = ↑(hitOf lab step (clNow φ) k)`:
    (C) at the HIT level, an equality of family-triple sets rather than of trace sets.
  - `hitPresented_of_presented` — `Presented → HitPresented` at every depth `k ≥ 1`, as the term
    `hit_eq_hitOf_of_presented M τ t φ lab step k hk hP`.
- `typst/generated/status.typ` — regenerated line count (347508 → 347552, exactly the +44 above)
  and commit/date stamp. Not a plan-declared file; staged because the blocking pre-commit gate's
  own remedy requires it (see Plan Deviations).

## Decisions

- `HitPresented` is a `def … : Prop` whose body IS its pinned statement, so
  `hitPresented_of_presented` closes by definitional unfolding to `hit_eq_hitOf_of_presented`'s
  conclusion — a bare term application, no tactic block and no `unfold`/`show` step.
- Both docstrings carry the plan's three disclaimers explicitly: fixture-only, forward-only, and
  non-constructive (`∃ L` out of `Set.Finite.bddAbove`, so no bound). Neither mentions
  decidability, a decision procedure, or `PlusValidZTime` in any form — audited mechanically over
  the new block, whose only `Decidab`-shaped hits are the `[DecidableEq Q]` instance binders the
  pinned signature requires.
- Both docstrings state that `Probe735.not_presented` is NOT weakened or retired: that probe
  refutes a TRACE-set equality, `HitPresented` is a FAMILY-TRIPLE-set equality, the pumped trace's
  forward type is what the refutation turns on, and a type-level demand gives that argument
  nothing to bite on — so both hold of the same fixture at once.

## Plan Deviations

- **Task 1.3** (the `HitPresented` docstring) altered: the plan directs the docstring to say the
  hypothesis "is discharged in this tree … by the wired probe
  `specs/evidence/seam-gluing-ray-product/hit-presented-model-a.lean`". That file does not exist
  at phase 1 — the plan's own phase 2 creates it and phase 8 wires it — so the reference is
  written as a forward reference ("landed by this record's later phases"). Every other element of
  the item (Hit-vs-trace weakening, `presented_localRun` unavailable, finiteness by
  `kType_finite`, fixture-only, non-constructive, no bound, `Paper: —` anchor) is verbatim.
  Annotated inline on the plan's checklist item.
- **Phase 1 Scope Hypothesis** overrun, not a step deviation: predicted ~15-25 added lines,
  actual 44. The two declarations plus bodies are 12 lines; the remaining 32 are docstring prose
  the phase's own task list mandates in detail. Recorded in `issues.jsonl`.
- **Out-of-scope staged path**: `typst/generated/status.typ`. The pre-commit
  `typst-sync-check.sh` Check 2 gate BLOCKED the phase commit because the committed
  `formalsystem-line-count` lagged live by exactly the 44 lines this phase added. The gate's
  `--no-verify` bypass is explicitly reserved for drift caused by *another* writer, so it did not
  apply; the documented remedy (full `lake build`, then `typst-sync-check.sh --fix`, then stage
  the file) was run instead. Every later phase of this record that adds Lean lines will hit the
  same gate, and this path is not in the plan's `file_scope` — recorded in `issues.jsonl` so
  phases 2-8 expect it.

## Verification

- Build: Success. Scoped `FormalSystem.Metalogic.Decidability.RaySummary.Trace` (guard exit 0,
  1929 jobs); the two plan-enumerated direct dependents
  `FormalSystem.Metalogic.Decidability.RaySummary` (guard exit 0, 1931 jobs) and
  `BimodalTest.Metalogic.KTypeSummaryAxiomTest` (guard exit 0, 2178 jobs); and the full project
  (guard exit 0, 2836 jobs, `Build completed successfully`). Zero `error:` lines across every
  captured stream. `Trace.olean` is newer than `Trace.lean`.
- Sorry count: 0, repo-wide, via `lean-sorry-census.sh --cross-check` over all eight resolved
  source roots — `stripper_sorry_count: 0`, `compiler_sorry_count: 0`, `cross_check: MATCH`.
- Sorry inventory: empty. None introduced, none inherited.
- Vacuous count: 1, unchanged from `HEAD~1` and pre-existing —
  `FormalSystem/Examples/TemporalStructures.lean`'s `int_domain_universal`, where
  `intTimeHistory.domain t` genuinely reduces to `True`, so `trivial` is the honest proof. Zero
  introduced by this phase; the baseline is reported rather than rounded to 0.
- Axiom count: 14, unchanged from `HEAD~1` (verified by `git grep` at both revisions). No `axiom`
  added.
- Axiom foot: `#print axioms …hitPresented_of_presented` reports exactly
  `[propext, Classical.choice, Quot.sound]` — the list the plan's Phase 1 verification requires.
- Statement fidelity: both signatures confirmed against the plan's
  `## Lean Challenge Statements` entries by `#check @…` against the live build — same binders,
  same instance binders, same order, same conclusion.
- Comparator gate: not run. `compare_flag` is absent from the delegation context, so the gate's
  precondition is unmet and no `comparator` block is recorded.

## Impacts

- `HitPresented` is now a declaration in `FormalSystem.Metalogic.Decidability.RaySummary`, so
  phases 2-7's probe can discharge a library name rather than a local one, and the ray-product
  verdict's requirement (C) has a formal statement to be measured against.
- `hitPresented_of_presented` fixes the hypothesis ordering formally: anything proved under
  `Presented` transfers to `HitPresented` at `k ≥ 1` for free, so the two hypotheses need not be
  carried separately downstream.
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` now contains a FALSE claim in three
  places — the `(C)` requirements-table row and two prose occurrences say `HitPresented` "is not
  a declaration in this tree". Phase 8 owns that README update; flagged in the phase handoff.

## Follow-ups

- Phases 2-8 of `plans/01_hit-presented-model-a.md`, all `[NOT STARTED]`. Phase 2 (probe scaffold,
  fixture, step-path classification) is next and touches only the new probe file.
- Phase 2's transcription source is a session-scoped `/tmp` scratch file (`rigid745.lean`);
  confirm it is still present before relying on it, and reconstruct from the report's recorded
  tactic survey if it has been cleaned.
- Phase 8 owes: the README verdict update, `docs/theorem-index.md` rows for both new
  declarations, axiom pins in `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` in the
  same commit as the index rows, and the recorded bound verdict. Both docstrings already end with
  a `Paper: —` anchor line so the index rows are admissible when they land.
- The `typst-sync-check.sh` Check 2 gate will block every later phase commit that adds Lean
  lines; budget the full guarded build plus `--fix` into each.

## References

- `specs/745_hit_level_completeness_computable_bound/plans/01_hit-presented-model-a.md` — the plan,
  Phase 1 and the `## Lean Challenge Statements` pins.
- `specs/745_hit_level_completeness_computable_bound/reports/01_hit-level-completeness-probe.md` —
  the research the plan executes.
- `specs/745_hit_level_completeness_computable_bound/handoffs/phase-1-handoff-20261008T235902Z.md`
  — phase-end handoff with the next action and the phase-8 notes.
- `specs/745_hit_level_completeness_computable_bound/issues.jsonl` — the scope-hypothesis overrun
  and the pre-commit gate collision.
- `FormalSystem/Metalogic/Decidability/RaySummary/Trace.lean` — the two new declarations.
- `specs/evidence/seam-gluing-ray-product/presented-not-complete.lean` — `Probe735.not_presented`,
  the trace-level refutation these docstrings are careful not to weaken.
