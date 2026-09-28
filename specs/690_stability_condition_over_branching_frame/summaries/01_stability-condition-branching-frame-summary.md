# Implementation Summary: Task #690

- **Task**: 690 - Build the stability condition (C5) StabFaithful on the branching witness frame
- **Status**: [COMPLETED]
- **Started**: 2026-09-28T19:35:00Z
- **Completed**: 2026-09-28T20:30:00Z
- **Effort**: ~4 hours (this dispatch; phases 16-22 of a 22-phase plan)
- **Dependencies**: None outstanding
- **Artifacts**: plans/01_stability-condition-branching-frame.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

This dispatch closed the last seven phases of the task. Phase 16 was unblocked by the user's
cycle-5 decision (adopt `SharingWindow`), and phases 16, 17, 18, 19, 20 and 22 were executed in
order; phase 21 had landed in an earlier cycle. The result is a complete L⁺-indexed certificate
stack in which the stability condition (C5) `StabFaithful` is stated natively over
`PlusFormula.stab`, decided by a bounded window scan, consumed by the agreement theorem's seventh
case, and carried as one of six checked components of the certificate bundle. The shipping
deterministic export contract is untouched.

## What Changed

- `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Window.lean` — **new, 639 lines.**
  `SharingWindow extends SharingSkeleton` with the combined-period triple `(NB, NF, NM)` and six
  compatibility facts; the window, the position graph (`verts`, `nextTime`, `prevTime`, `succF`,
  `predF`), the two folding relations, and the walk layer `FwdWalk`/`BwdWalk` with their
  `toThread`. Entirely label-free: it mentions no formula, no label and no language, and is
  consumed by both certificate sides.
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Fulfil.lean` — **new, ~1,090 lines.**
  The label-dependent half of (C2') at L⁺: `L_nextTime`/`L_prevTime`, `foldRel_L`/`foldRelB_L`,
  `atPos`, `untlFix`/`snceFix` (instantiations of the reused generic `AUFix`), the (C1')
  propagation layer, the two soundness theorems, `PlusFulfilWindow`,
  `plusThreadFulfilling_iff_window`, `decidablePlusThreadFulfilling` and the genuine instance
  `decidablePlusCoherentShareAndFulfilling`, plus a computed smoke test.
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Agreement.lean` — **new, ~420 lines.**
  `model` (the `Quotient.lift` valuation), `valuation_cls`, the two inner inductions,
  `plusTruth_iff_mem` with **all seven cases**, the six-component `PlusCertifies` bundle,
  `decidablePlusCertifies`, `PlusWitnessFamily.PlusRefutes`, `plusJoint_countermodel` and
  `plusRefutes_of_certifies`.
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Decide.lean` — the `window` projection
  onto `SharingWindow` (amended Phase 13), and the (C3)/(C4) decision layer that no phase of the
  plan had assigned.
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily.lean` and `PlusWitnessFamily/README.md`
  — new aggregator and directory documentation.
- Registrations: `FormalSystem/Metalogic/Decidability.lean`, `FormalSystem/PlusLanguage.lean`,
  and a repository-wide `FormalSystem.lean` regeneration (21 import lines).
- `docs/theorem-index.md` (six rows), `scripts/check-module-invariants.sh` (C2 census extended
  from four to ten pinned axiom sets), `scripts/module-invariants-allowlist.txt`,
  `WitnessFamily/README.md`, `WitnessFamily/Sharing/Predicates.lean`.

## Decisions

- **`SharingWindow` rather than `SharingSkeleton` for the position graph.** Phase 1's measurement
  found the combined periods do not factor through the skeleton — `perBack` joins the skeleton's
  representative-segment lengths with the lassos' label-segment lengths. Carrying the triple as
  *data* on a structure extending the skeleton is what makes the graph factor. This was the
  user's recorded decision; it is additive to Stage A and revises nothing.
- **`AUFix` reused verbatim.** It is already stated at an arbitrary vertex type with an arbitrary
  `Finset`-valued successor function, so the fixpoint theory was not developed a second time.
- **`Sharing/Fulfil.lean` was not restructured.** The `Formula`-side device keeps its own copies
  of the position graph; the only edits to it in this whole dispatch are two lint-reason comments
  and the removal of a redundant `@[simp]`. Its behaviour is unchanged.
- **No standalone `Decidable PlusThreadFulfilling`.** (C2')'s window reduction is relative to
  (C1'), exactly as on the `Formula` side, so the exported instance is on the conjunction.

## Plan Deviations

- **Phase 13** amended additively with `SharingWindow`; sited in a new label-free module rather
  than in `PlusWitnessFamily/Decide.lean`.
- **Phase 16**: delegated to `SharingWindow` rather than `SharingSkeleton`; the termination
  measure was not ported (`AUFix` reused); the 16.1/16.2 split was skipped, as the user decision
  directs.
- **Phase 17**: the standalone `inferInstance` example is not available and was not written; the
  bundled one is. Measured 864 lines against a ≈250-line hypothesis — reported, not smoothed.
- **Phase 18**: the seventh case was written in the same pass rather than carried as an open case;
  no `sorry` or placeholder was written at any point.
- **Phase 19**: its single atomic commit also carries Phase 20, because the declarations share a
  file that must build as a unit.
- **Phase 20**: **two of the five component instances did not exist** — neither
  `Decidable PlusBoxFaithful` nor `Decidable (PlusTarget t)` had been assigned to any phase. This
  was a plan gap, closed here with ≈130 lines in `PlusWitnessFamily/Decide.lean`.
- **Phase 22**: census lines went to C2 only, not C14; the aggregator could not be created in the
  same commit as the subdirectory (created in Phase 8); staged by name but landed as one commit,
  since C33 makes the aggregator and the regenerated root inseparable.

Every deviation above is annotated inline on its plan checklist item.

## Verification

- Build: **Success** — full `lake build`, 2,769 jobs, zero errors.
- Sorry count: **0** (`lean-sorry-census.sh` over all four source roots).
- Vacuous count: **1**, pre-existing and a false positive —
  `FormalSystem/Examples/TemporalStructures.lean:495`, `int_domain_universal ... := trivial`,
  where the domain predicate genuinely *is* `True` for ℤ. Not introduced by this task; the
  single-line grep heuristic cannot tell it from a placeholder.
- Axiom count: **14**, identical to the pre-task commit `0a8ac120a`. No axiom was introduced.
- `#print axioms` on all six newly pinned goals: `{propext, Classical.choice, Quot.sound}`.
- Module invariants: C1-C22, C24-C27, C29-C35 and INV pass. **C23 and C28 remain red**; both were
  red before this task and both are documented as exclusions on Phase 22.
- Tests: N/A (no test-suite changes).
- Files verified: Yes.

## Impacts

- (C5) is now a *checked* condition, not a signature: `PlusCertifies` has six components, and a
  per-binder drop-and-re-elaborate check confirms `plusTruth_iff_mem` genuinely consumes
  `StabFaithful` in its `stab` case and nowhere else.
- `SharingWindow` is available to any future certificate over any language — the position graph,
  the folds and the walk layer are now stated once, label-free.
- The deterministic bi-lasso device and its JSON export contract are unchanged.
- Gate C33 is green for the first time in this line of work: `FormalSystem.lean` is byte-for-byte
  the generated root at 603 imports, covering the 16 previously-missing modules from three tasks.

## Follow-ups

- **C28** is one warning above baseline, in `WitnessFamily/Compression/Cycle.lean` (a `push_neg`
  Mathlib deprecation) — another task's file and another task's debt.
- **C23** is red on `NM_nonneg` (both certificate sides) and on eleven outer-shadows-inner pairs.
  Repairing it means a cross-task rename of a landed API; doing it on one side only would break
  the name correspondence the L⁺ re-index is organized around.
- **`lake-build-guard.sh` defect, observed and worth fixing guard-side**: in an earlier cycle the
  guard replayed a stale result across a *differently scoped* build and reported success while
  writing no `.olean` for the module actually requested. Every build in this dispatch therefore
  passed `--no-share`. The guard's scope key appears not to distinguish a whole-project `build`
  from a single-module `build Module.Name`, or the replay window is not invalidated when the
  requested target changes.
- No completeness half was attempted, per the plan's Non-Goals: nothing here claims that every
  L⁺ countermodel compresses to a `PlusSharingWitnessFamily`.

## References

- `specs/690_stability_condition_over_branching_frame/plans/01_stability-condition-branching-frame.md`
- `specs/690_stability_condition_over_branching_frame/.decisions.json` (cycles 1 and 5)
- `specs/690_stability_condition_over_branching_frame/.measurements/01_substrate-measurement.md`
- `specs/690_stability_condition_over_branching_frame/handoffs/` (phases 16, 17, 20, 22)
