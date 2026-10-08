# Implementation Summary: Task #735

- **Task**: 735 - Assemble the decidable stab check on the ray-product presentation: Decidable (PlusValidZTime phi)
- **Status**: [COMPLETED]
- **Started**: 2026-10-08T00:40:00Z
- **Completed**: 2026-10-08T17:50:00Z
- **Effort**: 4 phases across 18 dispatches (this dispatch, Phase 4: ~1 hour)
- **Dependencies**: 711, 737, 742 (all complete)
- **Artifacts**: plans/01_decidable-stab-check-assembly.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

The task closed on the acceptance criterion's **second branch**: a recorded, cited verdict that
the ray-product presentation (`seamOmegaEquiv` + `hitOf` + `Presented`) cannot deliver
`Decidable (PlusValidZTime φ)`, with the obstruction carried as a wired, machine-checked probe
(`Probe735.not_presented`, `specs/evidence/seam-gluing-ray-product/presented-not-complete.lean`,
axioms `[propext, Classical.choice, Quot.sound]`) rather than prose. Phases 1-3 wired the probe,
landed the one positive in-frame result (the run-level `⊡` bridge
`plusStab_iff_forall_run_of_presented` and the liveness decider `onRun_iff_live`, `stabCheckSig`,
`stabCheckSig_iff`, `stabCheck_iff_of_presented`, `decidableStabOfPresented`, all **conditional on
`Presented`** and vacuous on model A), pinned them and indexed them as Conditional. Phase 4, this
dispatch, recorded the verdict where the programme reads it and corrected the ROADMAP's critical
path. `Decidable (PlusValidZTime φ)` is stated nowhere in any form; no task dependency was
changed and no task was filed.

## What Changed

- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` — `StabCheck.lean` table row; one
  new "What it does not do" bullet (**It does not decide `PlusValidZTime φ`, and the presentation
  cannot**); the new `## The verdict` section: the verbatim `Probe735.not_presented` statement,
  the two-sentence proof shape (pumping-closed run-trace sets vs. the trace map's discontinuity in
  the `untl` letter), the three-row table naming (C) Hit-level completeness with a computable
  bound, (S) Hit-level soundness (the unfiled B2b record restated at `hitOf` level, whose
  consistency conditions must exclude pumpable eventuality-deferring run sets by
  `presented_localRun`) and (W) a closure-wide quasimodel over all seams and times, each with its
  statement shape under `[F.IsRegular]`, L⁺, ℤ time and why the landed substrate does not supply
  it; what the verdict does not establish (`⊡(Pp)`, `HitPresented` OPEN, infinite slices, any
  bound, any negative decidability result); literature position (HWZ 2000 Thm 14 ⇐, corpus entry
  UNVERIFIED-summary, context only). The fifth wired probe in "Evidence", an adjacent sentence on
  the four `stabCheckSig` `#guard`s, and adjacent pinned-profile sentences in "The consumer
  relation". (Phases 1-3 earlier: `StabCheck.lean`, the `Trace.lean` hunk, pins, `#guard`s,
  index rows, C14 pairs, the `WIRED` entry — see the plan.)
- `FormalSystem/Metalogic/Decidability/README.md` — the `RaySummary/` cell: one appended sentence
  naming `StabCheck.lean`, the probe and the verdict; `7 files` → `8 files`.
- `specs/ROADMAP.md` — both `/orchestrate 735` run-order comments; the
  "Critical path: 742 → successor (B2b) → 735" line replaced by the corrected paragraph (the
  critical path is NOT through B2b; B2b is (S) only; (C), (W) unfiled; the deliverable is the
  verdict plus the conditional per-seam check); one sentence appended to the B2b bullet; the 735
  bullet rewritten to its outcome and marked `[x]`.

## Decisions

- Additive-only beside task 742's deliverables (user ruling, Option A): every 742 sentence in
  both READMEs, the ROADMAP's 742 bullet, the docstrings, index row and pin-test prose stays
  verbatim; the correction set remains scoped in plan Decision D-P5 for the user.
- `Probe735.not_presented` is cited by declaration name and the probe by filename, never by line.
- The landed name `decidableStabOfPresented` is used throughout (the plan's
  `decidableStab_of_presented` spelling appears nowhere outside the plan).
- The ROADMAP's two `/orchestrate 735` lines were annotated "landed 2026-10-08 as a verdict"
  rather than deleted, and the 735 bullet keeps its `(Task 735)` tag beside the plan's
  `*(Completed: Task 735, 2026-10-08)*` marker.

## Plan Deviations

- None (implementation followed plan). The one judgement call outside the plan's letter: 742's
  `Trace.lean` row (`336` lines; the file is now 371) and its "thirteen `#guard`s" sentence were
  left verbatim under the additive-only ruling instead of being refreshed; both are listed under
  Follow-ups.

## Verification

- Build: Success — guarded full build `GUARD_EXIT=0`, "Build completed successfully (2836 jobs)",
  0 `error:` lines; `.olean` newer than source for `RaySummary/StabCheck`, `RaySummary/Trace`,
  `KTypeSummaryAxiomTest`, `KTypeFinEvalTest`.
- Sorry count: 0 (`lean-sorry-census.sh --cross-check`: stripper 0, compiler 0, MATCH)
- Sorry inventory: None
- Vacuous count: 1 (pre-existing `FormalSystem/Examples/TemporalStructures.lean`
  `int_domain_universal`, unchanged from the Phase 3 baseline)
- Axiom count: 14 (= baseline, not increased)
- Gates this phase: `check-module-invariants.sh --no-build` exit 0 (ALL CHECKS PASSED; C9/C9D
  zero task-number citations under `FormalSystem/`, `docs/`); `check-evidence-probes.sh` exit 0
  (22/22, `presented-not-complete` PASS); `check-phantom-citations.sh` exit 0 with 1 finding,
  unchanged from the pre-edit baseline (742's probe-defined `quasistate_does_not_determine_hit`);
  `git diff --stat` for the phase commit: three files, no `.lean`; the plan's grep checks
  (`742 → successor`, `B2b → 735`, `add it to 735` absent; `task 735` absent under
  `FormalSystem/` and `docs/`; "L⁺ is decidable" written nowhere) all pass.
- Plan compliance: `plusStab_iff_forall_run_of_presented`, `onRun_iff_live`, `stabCheckSig`,
  `stabCheckSig_iff`, `stabCheck_iff_of_presented`, `decidableStabOfPresented` each declared once
  under the resolved source roots; `theorem not_presented` present and wired.
- Pre-existing, reported and NOT repaired (not this task's): `.claude/scripts/check-task-references.sh`
  exits 1 with 198 repo-wide occurrences (`ModalS5Test.lean`, `C5SmokeTest.lean`, script
  comments), zero in this task's files; `scripts/typst-sync-check.sh` Check 1 reports
  `FormalSystem.Semantics.validZTime_iff_validInt` unresolved from `typst/FormalFoundations.typ`
  (declaration exists at `FormalSystem/Semantics/IntTransfer.lean`).

## Impacts

- The programme's L⁺-decidability front now has a recorded answer for the ray-product route:
  the presentation delivers a conditional per-seam `⊡` decider and cannot deliver
  `Decidable (PlusValidZTime φ)`; the three missing theorems (C), (S), (W) are named with
  statement shapes, so any successor starts from a stated target rather than from "B2b then 735".
- `specs/ROADMAP.md` no longer directs the user to file B2b and add it to 735's dependencies;
  the critical-path paragraph says what B2b is ((S) only) and is not (sufficient).
- `Presented`-conditional statements across `RaySummary/` now sit beside explicit vacuity text and
  a cross-reference to the verdict, so they cannot be read as a decision procedure.

## Follow-ups

- User's call (not performed): filing (C), (S), (W) as records; filing the B2b successor; any
  dependency edit; the scoped correction of 742's own Presented-conditional sentences (plan
  Decision D-P5, ~40-60 prose lines, LOW).
- Housekeeping candidates under the same ruling: 742's `Trace.lean` row count (`336`, file now
  371 lines) and its "thirteen `#guard`s" sentence (four more exist) in the RaySummary README.
- `HitPresented` (Hit-level hypothesis): satisfiability on model A OPEN; the `PathEntry.rep`
  per-triple route is recorded in plan Decision D-P2 as a 250-400 line MEDIUM candidate.
- Pre-existing gate failures above (`check-task-references.sh`, `typst-sync-check.sh` Check 1).

## References

- specs/735_decidable_stab_check_ray_product_assembly/plans/01_decidable-stab-check-assembly.md
- specs/735_decidable_stab_check_ray_product_assembly/reports/01_decidable-stab-check-assembly.md
- specs/735_decidable_stab_check_ray_product_assembly/handoffs/phase-4-handoff-20261008T174900Z.md
- specs/evidence/seam-gluing-ray-product/presented-not-complete.lean
- FormalSystem/Metalogic/Decidability/RaySummary/README.md ("The verdict")
- Commits: `6d678e43e` (phase 4), `c7ff251ad` (phase 3), earlier phase commits per the plan
