# Implementation Summary: Task #665

- **Task**: 665 - Witness-family certificate soundness (the quasimodel / ShiftSet route, soundness half)
- **Status**: [COMPLETED]
- **Started**: 2026-09-24T23:21:41Z
- **Completed**: 2026-09-24T17:35:00Z
- **Effort**: ~4 hours
- **Dependencies**: None blocking. Held-stable neighbour `BiLasso/Basic.lean` untouched. Concurrent sibling this cycle: task 667.
- **Artifacts**: plans/01_witness-family-certificate-soundness.md, reports/01_witness-family-certificate-soundness.md, evidence/t1-agreement-spike.lean
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Landed the soundness half of the quasimodel / ShiftSet route as a new presentation-free
subdirectory `FormalSystem/Metalogic/Decidability/WitnessFamily/` (7 modules, 2,042 lines, plus a
sibling aggregator and a directory README). A labelled bi-lasso family satisfying local
coherence, fulfilment and box faithfulness now provably presents a `ShiftSet intOrder` model
whose truth agrees with the labels on the target closure, so any such family with a `Target` is a
machine-checkable refutation of a ℤ-time consequence. All four certificate predicates are
decidable by bounded window scans that compute, and both non-vacuity directions are witnessed.
All ten plan phases completed; `lake build` and `scripts/check-module-invariants.sh` are green.

## What Changed

All files below are new unless noted.

- `FormalSystem/Metalogic/Decidability/WitnessFamily/Closure.lean` (131 lines) — `closureOf`, the
  set-level subformula closure of a `Context`, with `mem_closureOf`, `self_mem_closureOf` and the
  seven projections the agreement induction consumes.
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Basic.lean` (201 lines) — the
  `LabelledLasso` and `WitnessFamily` structures (field names are the ModelChecker JSON export
  contract), the decoded label functions `LabelledLasso.lab` and `WitnessFamily.L`, the two
  periodicities `lab_sub_back_length` / `lab_add_fwd_length`, and `lab_subset` /
  `subset_closureOf`.
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Predicates.lean` (127 lines) —
  `LocalCoherentLab`, `FulfillingLab`, `BoxFaithful`, `Target`, with a clause-by-clause
  correspondence table against `BiLasso/Annotation.lean`'s `LocalCoherent`.
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Std.lean` (120 lines) — `WitnessFamily.std`,
  the presented `ShiftSet intOrder`, with `std_isZTime`, `std_sat_ztime`, `std_sat_base` and
  `sh_surj`.
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Agreement.lean` (247 lines) — **T1**
  `shiftTruth_iff_mem` and `truth_iff_mem`; **T1'** `not_consequence_ztime`,
  `not_consequence_base`, `joint_countermodel`; the two inner ℤ-distance inductions
  `untl_mem_of_witness` and `snce_mem_of_witness`.
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Decide.lean` (933 lines) — **T2**: the label
  window machinery (`lab_reduce_fwd`/`lab_reduce_back`, `lab_congr_fwd`/`lab_congr_back`,
  `scan_forward`/`scan_backward`, `mem_all_neg_of_period`/`mem_all_fwd_of_period`), the
  `LocalCoherentLab` and `FulfillingLab` window collapses, the new `BoxFaithful` collapse
  `mem_all_iff_window`, and the four named instances `decidableLocalCoherentLab`,
  `decidableFulfillingLab`, `decidableBoxFaithful`, `decidableTarget`.
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Examples.lean` (283 lines) — **T3**: the
  non-vacuity witness `posFamily` for `□(p ∨ Fp ∨ Pp) ∧ □(p → ¬Pp)`, the separation witness
  `sepFamily` (`LocalCoherentLab` but not `FulfillingLab`), six `#guard`s that run the four named
  instances, and the impossibility theorems `no_witnessFamily_of_validZTime` and
  `no_witnessFamily_of_MF`.
- `FormalSystem/Metalogic/Decidability/WitnessFamily.lean` (68 lines) — the sibling aggregator
  (C8).
- `FormalSystem/Metalogic/Decidability/WitnessFamily/README.md` — directory README (required by
  `readme-lint.sh` check 1).
- `FormalSystem.lean` — modified, regenerated with `lake exe mk_all --lib FormalSystem` (C33);
  eight added import lines, no hand edits.
- `FormalSystem/Metalogic/Decidability/README.md` — modified, two new Modules rows.
- `FormalSystem/Metalogic/Decidability/BiLasso/README.md` — modified, sibling-directory pointer
  from the Modules section and from the `Basic.lean is held stable` section.
- `FormalSystem/Metalogic/README.md`, `FormalSystem/README.md`, `README.md` — modified,
  machine-regenerated inventory blocks (`--emit-inventory`); counts only.

`BiLasso/Basic.lean` and `BiLasso/Decide.lean` are unmodified: `git diff 332b05b01 --stat --
FormalSystem/` lists neither.

## Decisions

- **Index the lasso by `Fin W.lassos.length`, not by a separate `k` field.** The plan's task list
  said "derive `WitnessFamily.k`, `L : Fin (k+1) → …`" while its authoritative Lean Challenge
  Statements block said `L (i : Fin W.lassos.length)`. The latter was followed, with
  `lassos_length_pos` and `mainIdx` derived from `lassos_ne`; the two are equivalent and this one
  avoids `k+1` juggling at every use site.
- **Namespace is `FormalSystem.Metalogic.Decidability`, not `…Decidability.WitnessFamily`.** A
  namespace ending in `WitnessFamily` containing a structure named `WitnessFamily` produced ten
  `dupNamespace` warnings, which C28's zero-warning budget forbids. The BiLasso precedent
  (`namespace …Decidability` + inner `namespace Annot`) was followed instead, with inner
  `namespace LabelledLasso` / `namespace WitnessFamily`.
- **Six `Decide.lean` declarations carry a `lab`/`Lab` prefix their ancestors do not**
  (`labClauseAt`, `instDecidableLabClauseAt`, `labCohWindowLo`, `labCohWindowHi`,
  `labFulWindowLo`, `labFulWindowHi`). C23's outer-shadows-inner assertion rejects an inner-
  namespace declaration sharing a base name with one in an enclosing namespace, because C17's
  dead-declaration census keys on the last dot-segment. `Examples.lean`'s `pForm` / `qForm` were
  renamed from `pF` / `qF` for the same reason.
- **`WitnessFamily.L_subset` renamed to `subset_closureOf`** — C23 rejects `Uppercase_x` names.
- **Kept the plan's `BiLasso/`-row verification instruction.** The Decidability README's existing
  `BiLasso/` row calls that directory "outside the build graph", which contradicts the BiLasso
  README's own Dependencies section and the regenerated root. The new `WitnessFamily/` row states
  the accurate version (inside the build graph, via the generated root) rather than propagating
  the tension; the pre-existing `BiLasso/` row was left alone as out of scope.
- **Two arithmetic lemmas (`reduce_emod`, `emod_shift`) are restated in `Decide.lean`** rather
  than imported from `BiLasso/Basic.lean`, so the directory stays free of the presentation layer.

## Plan Deviations

- **Phase 2** altered: `WitnessFamily.k` was not defined; `lassos_length_pos` + `mainIdx` +
  `L : Fin W.lassos.length → ℤ → Finset Formula` were, matching the plan's own Lean Challenge
  Statements block. See Decisions above.
- **Phase 2, 6** altered: the top-level namespace is `FormalSystem.Metalogic.Decidability`
  throughout, not `…Decidability.WitnessFamily`. Forced by C28 + `dupNamespace`.
- **Phase 6, 8, 9** altered: six `Decide.lean` names and two `Examples.lean` names carry
  disambiguating prefixes. Forced by C23.
- **Phase 8** altered: the plan's "`#eval` on each of the four instances" verification was
  discharged by `#guard` naming each instance explicitly
  (`@Decidable.decide _ (WitnessFamily.decidableLocalCoherentLab posFamily)`) rather than by
  `#eval`. `#eval` in library code is gated by C27 and would have needed a
  `scripts/debug-artifact-allowlist.txt` entry; `#guard` is not gated, runs the same compiled
  instance, and additionally *asserts* the answer instead of only printing it.
- **Phase 9** altered: the positive witness's premise/conclusion split is `Γ = [phiPos]`,
  `Δ = []`, so it is a satisfiability certificate (`phiPos_satisfiable`) rather than a refutation
  of a named consequence. The plan did not fix the split; this is the one that makes the example
  say what its prose says.
- **Phase 10** added: `FormalSystem/Metalogic/Decidability/WitnessFamily/README.md` was created.
  The plan listed only the two existing READMEs, but `readme-lint.sh` check 1 (gated) requires a
  README in every directory containing `.lean` files.
- **Phase 10** added: `scripts/check-module-invariants.sh --emit-inventory` was run, rewriting the
  generated inventory blocks in `FormalSystem/Metalogic/README.md`, `FormalSystem/README.md` and
  `README.md`. The plan did not anticipate the INV check; the rewrite is machine-owned and
  touches counts only.

## Verification

- Build: **Success** — full `lake build`, 2,734 jobs, exit 0, 0 `error:` and 0 `warning:` lines
  across both captured streams; every `WitnessFamily/` module's `.olean` is newer than its source.
- Sorry count: **0** (`lean-sorry-census.sh` over the resolved source roots; C3 also PASS).
- Vacuous count: **1**, pre-existing and not introduced here —
  `FormalSystem/Examples/TemporalStructures.lean:495`, `int_domain_universal … := trivial`, where
  `intTimeHistory.domain t` genuinely *is* `True` by construction. Zero in `WitnessFamily/`.
- Axiom count: **14**, unchanged — `grep -rn "^axiom "` over the source roots returns the same
  count as before this task, and `WitnessFamily/` declares none.
- `#print axioms` on every flagship declaration reports exactly
  `[propext, Classical.choice, Quot.sound]`: `truth_iff_mem`, `shiftTruth_iff_mem`,
  `not_consequence_ztime`, `not_consequence_base`, `joint_countermodel`, `std_isZTime`,
  `no_witnessFamily_of_validZTime`, `no_witnessFamily_of_MF`, `posFamily_localCoherent`,
  `sepFamily_not_fulfilling`, `phiPos_satisfiable`.
- `scripts/check-module-invariants.sh`: **ALL CHECKS PASSED** (51 PASS groups, 0 FAIL), including
  C3 (zero sorries), C8 (aggregator convention), C16 `dupNamespace`, C19 (docstring coverage
  93.89%, floor 90%), C23 (naming), C28 (0 warnings across 0 files — no
  `scripts/warning-budget.txt` entry needed), C33 (`FormalSystem.lean` byte-for-byte generated).
- `scripts/readme-lint.sh`: **PASS** — 0 missing READMEs, 0 broken file references.
- Both T3 `#guard` directions pass at elaboration time: the positive witness is accepted by all
  four instances, the separation witness is accepted by `decidableLocalCoherentLab` and rejected
  by `decidableFulfillingLab`.
- Tests: N/A — no test-suite changes in scope.
- Files verified: Yes.

## Impacts

- A model checker emitting a witness family in this shape now has a Lean-checkable soundness
  theorem for its output: `joint_countermodel` hands back an explicit ℤ-time frame, model, world
  history and time. The field names `back`, `mid`, `fwd`, `bx`, `lassos` are the export contract
  and are now load-bearing.
- `no_witnessFamily_of_validZTime` gives the contrapositive guarantee — no certificate can target
  a ℤ-time validity — so a checker that emits one has a bug, not a discovery.
- The four `Decidable` instances make `LocalCoherentLab`, `FulfillingLab`, `BoxFaithful` and
  `Target` runnable checks, so a certificate can be validated without a proof script.
- `Decide.lean` duplicates `BiLasso/Decide.lean`'s window arithmetic at the other carrier of the
  same decoding. Both files now record the same named retirement trigger: when a shared
  periodic-label presentation lands, both collapses should be redefined as its two instances.

## Follow-ups

- The completeness (compression) direction and the `Decidable (ValidZTime φ)` assembly remain with
  task 623, as scoped.
- The `BiLasso/` row in `FormalSystem/Metalogic/Decidability/README.md` still says "outside the
  build graph", which the BiLasso README's own Dependencies section and the generated root both
  contradict. Left unfixed as out of scope for this task; worth a one-line correction.
- The duplicated window arithmetic between `WitnessFamily/Decide.lean` and `BiLasso/Decide.lean`
  is recorded with its retirement trigger, not resolved.

## References

- `specs/665_witness_family_certificate_soundness/plans/01_witness-family-certificate-soundness.md`
- `specs/665_witness_family_certificate_soundness/reports/01_witness-family-certificate-soundness.md`
- `specs/665_witness_family_certificate_soundness/evidence/t1-agreement-spike.lean` — the
  compiled spike Phases 3-5 transcribe
- `FormalSystem/Metalogic/Decidability/WitnessFamily/README.md`
- `FormalSystem/Metalogic/Decidability/BiLasso/README.md`
