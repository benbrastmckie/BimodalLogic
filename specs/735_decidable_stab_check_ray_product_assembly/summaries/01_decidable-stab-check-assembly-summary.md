# Implementation Summary: Task #735

- **Task**: 735 - Assemble the decidable stab check on the ray-product presentation: Decidable (PlusValidZTime phi)
- **Status**: [IN PROGRESS]
- **Started**: 2026-10-08T16:52:03Z
- **Completed**: 2026-10-08T17:32:00Z
- **Effort**: ~25 minutes (Phase 1) + ~40 minutes (Phase 2) + ~35 minutes (Phase 3); 3 of 4 phases
- **Dependencies**: 711, 737, 742 (all complete)
- **Artifacts**: plans/01_decidable-stab-check-assembly.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Phases 1 and 2 of the four-phase plan are complete. Phase 1 wired the verdict's machine-checked
carrier, `Probe735.not_presented` (`Presented` is false on fixture model A at the seam for every
finite presentation), into `specs/evidence/seam-gluing-ray-product/presented-not-complete.lean`
and `scripts/check-evidence-probes.sh`. Phase 2 landed the one positive in-frame result, stated
and documented as **conditional on `Presented`** and therefore vacuous on model A: the run-level
`⊡` bridge `plusStab_iff_forall_run_of_presented` (`Trace.lean`) and the new module
`RaySummary/StabCheck.lean` — the `now`-free step graphs, `OnRun` and its liveness
characterization `onRun_iff_live`, the presentation-level decider `stabCheckSig` with
`stabCheckSig_iff`, and the closure instance `stabCheck_iff_of_presented` /
`decidableStabOfPresented`. `Decidable (PlusValidZTime φ)` is not stated in any form; no
declaration statement mentions `PlusValidZTime`. Phases 3-4 (pins, `#guard` witnesses and
Conditional index rows; the recorded verdict and ROADMAP correction) remain.

## What Changed

- `specs/evidence/seam-gluing-ray-product/presented-not-complete.lean` — (Phase 1) new wired
  probe, body byte-identical to the research probe; header in the collection's house style.
- `scripts/check-evidence-probes.sh` — (Phase 1) `WIRED` entry and table row labelled
  `OBSTRUCTION (verdict on the ray-product assembly)`, naming (C), (S), (W) as not in the tree.
- `FormalSystem/Metalogic/Decidability/RaySummary/Trace.lean` — (Phase 2)
  `plusStab_iff_forall_run_of_presented` after `plusStab_iff_forall_hitOf_of_presented`,
  statement and proof verbatim from `probes/stab-run-check.lean`; docstring names `Presented`
  and cites the refuting probe. The two existing 742 docstrings are untouched.
- `FormalSystem/Metalogic/Decidability/RaySummary/StabCheck.lean` — (Phase 2) new module,
  250 lines: `fwdNowFree`, `bwdNowFree`, `OnRun`, `onRun_iff_live` (two `ℕ`-chains glued at
  the anchor by `if t ≤ z then f (z - t).toNat else g (t - z).toNat`), `stabCheckSig`,
  `stabCheckSig_iff`, `stabCheck_iff_of_presented`, `decidableStabOfPresented`. Header and every
  docstring say the closure-instance results are conditional on `Presented`, refuted on model A
  by `presented-not-complete.lean`, hence vacuous there; nothing is a decision procedure for any
  model in the tree or for `PlusValidZTime`; no complexity bound; (C), (S), (W) named with a
  pointer to the RaySummary README. (Phase 3) one line `Paper: — (the formalization's own
  device)` added to `decidableStabOfPresented`'s docstring, required by the C15 index-anchor gate
  for its new index row; no statement or proof changed.
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` — (Phase 3) a new prose block and
  four `#guard_msgs`/`#print axioms` pins for `plusStab_iff_forall_run_of_presented`,
  `onRun_iff_live`, `stabCheck_iff_of_presented`, `decidableStabOfPresented`; the block says the
  four rows are conditional, that `Presented` is refuted as a completeness carrier by the wired
  probe, and that the existing four `Presented` rows above are vacuous on that fixture for the
  same reason. The existing 742 prose block is untouched.
- `Tests/BimodalTest/Metalogic/KTypeFinEvalTest.lean` — (Phase 3) a
  `## stabCheckSig on finite labelled presentations` section with the new labelling `labX`
  (`fun q p => q && p`) and four `#guard`s: `stabCheckSig labW stepW true false` (`true`),
  `!stabCheckSig labX stepW true false` (the discriminator), `stabCheckSig labX stepAlt true false`
  (`true` vacuously — the liveness guard is load-bearing), `stabCheckSig labAlt stepAlt true false`
  (`true`, no `now` state). Values observed by `#eval` before pinning; all four matched the plan.
- `docs/theorem-index.md` — (Phase 3) three **Conditional** rows directly after the
  `hit_eq_hitOf_of_presented` row (`plusStab_iff_forall_run_of_presented`,
  `stabCheck_iff_of_presented`, `decidableStabOfPresented`), each ending with the refutation
  citation and "nothing is stated about `PlusValidZTime`"; frame class ZTime, `pcq pinned:C14`.
  The 742 row is untouched.
- `scripts/check-module-invariants.sh` — (Phase 3) three C14 matched pairs appended at the same
  trailing position of `C14BASE` and `C14LEAN`, and one sentence appended to the C14 comment
  block naming the three `StabCheck` rows as conditional on `Presented`; the existing "final
  eight lines" sentence is left verbatim.
- `FormalSystem/Metalogic/Decidability/RaySummary.lean` — (Phase 2) import, `## Modules` line
  for `StabCheck`, one added header sentence; existing sentences verbatim.
- `FormalSystem.lean` — regenerated by `lake exe mk_all --lib FormalSystem`.
- `typst/generated/status.typ`, `README.md`, `FormalSystem/README.md`,
  `FormalSystem/Metalogic/README.md` — generated count blocks regenerated for the new module
  (`typst-sync-check.sh --fix`, `check-module-invariants.sh --emit-inventory`).

## Decisions

- Additive-only with respect to task 742's deliverables (user ruling, Option A): no 742 sentence
  edited in either phase.
- The decider is a `def` named `decidableStabOfPresented` (plan: `decidableStab_of_presented`):
  the enforced C26 lint rejects a snake_case `def` and the plan's R7 pre-authorizes fixing
  forward; the signature is the plan's Challenge statement verbatim.
- Three `show` tactics replaced by `change` (C28, `linter.style.show`), no suppressions.
- (Phase 1) the probe header's axiom record avoids the literal substring "sorry".
- (Phase 3) the landed name `decidableStabOfPresented` is what is pinned and indexed; the plan's
  `decidableStab_of_presented` appears nowhere in the tree.

## Plan Deviations

- **Task 1.3** altered: the gate script's total line reads `PASS  all 22 wired probe(s)` (it
  counts the three `WIRED_REPO` entries); the 19 `WIRED` probes are confirmed PASS.
- **Task 2.5** altered: `decidableStab_of_presented` landed as `decidableStabOfPresented`
  (C26); Phase 3's pin and index row must use the landed name (annotated in the plan).
- **Task 2.9** altered: one phase commit `ec59eae7c` instead of three sub-step commits — the
  pre-commit typst-sync gate requires `status.typ` to reflect the untracked new module, so the
  regenerated count files are staged with the phase.
- **Task 3.3** altered: `RaySummary/StabCheck.lean` (not in Phase 3's file list) gained one
  `Paper:` docstring line on `decidableStabOfPresented`, because C15 requires every
  theorem-index row's declaration to carry one; no statement changed.
- **Task 3.6** altered: sub-steps 3.1 and 3.2 landed as one commit `daca91f79` (typst-sync
  pre-commit gate on `tests-line-count`); 3.3 is `87535f34b`.

## Verification

- Build: Success (scoped guarded build of `FormalSystem.Metalogic.Decidability.RaySummary`
  and full guarded `lake build`, both guard exit 0, "Build completed successfully", 0 `error:`
  and 0 `warning:` lines; `.olean` newer than source for `StabCheck`, `Trace`, the aggregator
  and the root)
- Axioms: `plusStab_iff_forall_run_of_presented`, `onRun_iff_live`, `stabCheckSig_iff`,
  `stabCheck_iff_of_presented`, `decidableStabOfPresented` each depend on exactly
  `[propext, Classical.choice, Quot.sound]`
- Invariants: `bash scripts/check-module-invariants.sh --no-build` exits 0 (C26, C28, INV PASS
  after the fixes above)
- Sorry count: 0 (census over the resolved source roots; `StabCheck.lean` and the `Trace.lean`
  hunk each `grep -c sorry` = 0)
- Sorry inventory: None
- Vacuous count: 1 — pre-existing `int_domain_universal` in
  `FormalSystem/Examples/TemporalStructures.lean`, unchanged
- Axiom count: 14 (= baseline; unchanged)
- `grep -n PlusValidZTime StabCheck.lean` returns only docstring lines saying it is NOT decided
- (Phase 3) Full gate set: full guarded `lake build` after the docstring edit (2836 jobs,
  0 `error:`, guard exit 0, `StabCheck.olean` newer than source); scoped guarded build of
  `BimodalTest.Metalogic.KTypeSummaryAxiomTest` and `BimodalTest.Metalogic.KTypeFinEvalTest`
  (guard exit 0; both also elaborate cleanly under `lake env lean`, every `#guard_msgs` matched);
  `bash scripts/check-module-invariants.sh` exit 0 (55 PASS, C14 with the eleven decidability
  pairs, C15 green); `bash scripts/check-evidence-probes.sh` exit 0;
  `bash .claude/scripts/verify-deploy.sh` exit 0; `lean-sorry-census.sh --cross-check`
  `sorry_count: 0`, compiler 0, `cross_check: MATCH`; `grep -rn "task 735" FormalSystem docs
  Tests scripts` empty.
- (Phase 3, pre-existing, not touched) `scripts/typst-sync-check.sh` Check 1 reports
  `FormalSystem.Semantics.validZTime_iff_validInt` as unresolved from
  `typst/FormalFoundations.typ`; the declaration exists at
  `FormalSystem/Semantics/IntTransfer.lean:338` and neither file was changed by this task
  (last commits: tasks 722, 695). Check 2 (counts) is current after `--fix`.

## Impacts

- `stabCheckSig` is a computable per-presentation check of the run-level `⊡` condition; the
  closure-instance results are available to Phase 3's pins and `#guard` witnesses.
- Nothing downstream may read `decidableStabOfPresented` as a decision procedure: its hypothesis
  is refuted on model A, and the module header says so in its first "What is NOT decided" bullet.

## Follow-ups

- Phase 4 (next): the recorded verdict (RaySummary README `## The verdict`, Decidability README
  cell, aggregator header) naming (C), (S), (W), and the ROADMAP critical-path correction —
  additive beside 742's sentences.
- The pre-existing `typst-sync-check.sh` Check 1 resolution failure on
  `validZTime_iff_validInt` is outside this task; report, do not fix here.
- The D-P5 correction of 742's own text remains the user's to file (ruling: Option A).

## References

- specs/735_decidable_stab_check_ray_product_assembly/plans/01_decidable-stab-check-assembly.md
- specs/735_decidable_stab_check_ray_product_assembly/reports/01_decidable-stab-check-assembly.md
- specs/735_decidable_stab_check_ray_product_assembly/handoffs/phase-1-handoff-20261008T165553Z.md
- specs/735_decidable_stab_check_ray_product_assembly/handoffs/phase-2-handoff-20261008T170926Z.md
- specs/735_decidable_stab_check_ray_product_assembly/handoffs/phase-3-handoff-20261008T173008Z.md
- specs/735_decidable_stab_check_ray_product_assembly/probes/stab-run-check.lean
- Commits ebd3f4cb0 (Phase 1), ec59eae7c (Phase 2), daca91f79 and 87535f34b (Phase 3)
