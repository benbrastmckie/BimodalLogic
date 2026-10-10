# Implementation Summary: Task #750

- **Task**: 750 - (W)'s run layer, phase 1: the deadline-ladder frame scheme, landed and gate-compiled
- **Status**: [COMPLETED]
- **Started**: 2026-10-10T08:44:58Z
- **Completed**: 2026-10-10T09:13:04Z
- **Effort**: ~35 minutes wall clock (plan estimate 6.5 hours)
- **Dependencies**: None (no edge to the bound record, by the task's instruction)
- **Artifacts**: plans/01_w-run-layer-ladder-scheme.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Requirement (W)'s run layer had its phase-1 design question settled by research (the deadline
ladder, depth `k = 1`); this round landed that decision as code and record. A new library module
`RaySummary/RunLayer.lean` carries the finitely branching sliced constructor
`ofSlicedStepFinBranch` (`ofSlicedStep`'s body with `[Finite W]` replaced by two-sided finite
branching in its one `Saturation` slot) and the deadline ladder `Rlad` with its regular frame
`ladderFrame`; the verdict is gate-compiled by a ninth wired probe, pinned by twenty axiom pins and
one C14 pair, indexed by one `theorem-index` row, and recorded in the README's (W) section with
the measured figures, `k = 1`, the phase-2 obstacle, phase 3 verbatim and the literature
paragraph. Phases 2-3 of the task (obligation (ii), both halves) were characterized and NOT
attempted, by instruction. No statement mentions `PlusValidZTime`; no complexity bound anywhere.

## What Changed

- `FormalSystem/Metalogic/Decidability/RaySummary/RunLayer.lean` — new module, 373 lines (header
  1–71; branching core + constructor 72–250 = 179 lines; ladder + `ladderFrame` 251–373 = 123
  lines). Twenty Goals declarations: `FwdFinBranch`, `BwdFinBranch`, `iterS_fwd_finite`,
  `iterS_bwd_finite`, `fib_finite_of_finBranch`, `saturation_of_finBranch` (transcribed from
  Probe746), `ofSlicedStepFinBranch`, `ofSlicedStepFinBranch_isRegular`,
  `ofSlicedStepFinBranch_step`, `ofSlicedStepFinBranch_not_finite_worldState`,
  `ofSlicedStepFinBranch_mem_HF_iff` (one-slot transcriptions of `SlicedFrame.lean`), `Drift`,
  `Count`, `Rlad`, `Rlad_fwd`, `Rlad_bwd`, `Rlad_slice_infinite` (from the compiled research
  scratch), `ladderFrame`, `ladderFrame_isRegular` (with its `Paper: —` line), `ladderFrame_step`;
  plus the three permitted helpers `ofSlicedStepFinBranch_taskRel`, `tri`, `tri_finite`.
- `FormalSystem/Metalogic/Decidability/RaySummary.lean` — import of `RunLayer` after
  `AnchorLayer`; a `RaySummary.RunLayer` module-docstring bullet.
- `FormalSystem.lean` — generated-root import line (`mk_all --check` clean).
- `specs/evidence/seam-gluing-ray-product/deadline-ladder-branching.lean` — the ninth wired probe
  (`Probe750.ladder_fwd`, `ladder_bwd`, `ladder_slice_infinite`, `ladder_isRegular`,
  `capped_carrier_finite`), citing the library and re-proving nothing; refutes the capped variant.
- `scripts/check-evidence-probes.sh` — comment-table entry and `WIRED` entry (twentieth
  `seam-gluing-ray-product/` entry); 27 of 27 wired probes PASS.
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` — twenty `#guard_msgs` pins (one
  with a reasoned `linter.style.longLine` suppression, see Decisions).
- `scripts/check-module-invariants.sh` — C14 comment sentence, baseline line and `#print axioms`
  line for `ladderFrame_isRegular`; a documented C23 leave-alone class (c) for `Rlad_fwd`,
  `Rlad_bwd`, `Rlad_slice_infinite`.
- `docs/theorem-index.md` — one Decidability row for `ladderFrame_isRegular` (`pcq pinned:C14`).
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` — `RunLayer.lean` table row; the (W)
  section rewritten: obligation (i) landed with measured figures, `k = 1` with grounds,
  obligation (ii) in two halves with the phase-2 obstacle (cells indexed by `(q, deadline
  class)`; stabilization in `c` is phase 2's first statement) and phase 3 verbatim, obligation
  (iii) discharged; the semi-decidability caveat kept verbatim; the Successor paragraph updated;
  the literature paragraph (HWZ 2000 Def. 12 / Remark 13 / Thm 14 ⇐; GKWZ 2003 Thm 13.6) inserted;
  the ninth-probe Evidence paragraph; the (W) verdict row; `*Last verified: 2026-10-10*`.
- Generated files refreshed by their own generators because the gates demanded it:
  `typst/generated/status.typ` (pre-commit typst-sync gate, file/line counts), and the
  generated inventory blocks of `README.md`, `FormalSystem/README.md`,
  `FormalSystem/Metalogic/README.md` (`check-module-invariants.sh --emit-inventory`).

## Decisions

- `ofSlicedStepFinBranch_not_finite_worldState` is proved by
  `not_finite_iff_infinite.mpr (inferInstanceAs (Infinite (ℤ × W)))` with no separate `Infinite`
  instance, keeping the module's declaration set to the twenty Goals plus the three helpers.
- `Rlad_fwd`/`Rlad_bwd`/`Rlad_slice_infinite` keep the names fixed by the plan's Lean Challenge
  Statements (and mirrored by Probe746's `Rbad_fwd`/`Rok_bwd`); C23's `Uppercase_x` finding on
  them is recorded as a documented leave-alone class rather than resolved by a rename.
- The `ofSlicedStepFinBranch_not_finite_worldState` pin needs `set_option linter.style.longLine
  false in` (its `#print axioms` line is 104 characters and cannot be broken; the linter warning
  would otherwise be captured by `#guard_msgs`), carried with the C29 reason comment.
- The pre-existing `check-metalogic-cycles.sh` failure (below) is recorded as a Reasoned
  Exclusion on Phase 5 rather than left as `[PARTIAL]` per the plan's contingency clause: the
  failure predates this task by many commits, is reproducible at the plan commit, and the plan
  forbids this task from editing the file it names, so a `[PARTIAL]` would re-dispatch work this
  task cannot do.

## Plan Deviations

- **Phase 3, pins** altered: one pin carries a reasoned `linter.style.longLine` suppression.
- **Phase 3, C14 pair** altered: the same script gained a C23 leave-alone entry (class (c)) for
  the three `Rlad_*` names; `--emit-inventory` regenerated three READMEs' inventory blocks.
- **Phase 3, inventory diff** observed: `generate-decidability-inventory.sh --diff` does not diff
  PROVED rows by design, and its probe diff was already 14 entries off the committed baseline;
  the only delta attributable here is `+ REFUTED probe:…/deadline-ladder-branching` (exit 0).
- **Phases 1 and 3, commits**: `typst/generated/status.typ` had to be regenerated and staged
  (pre-commit typst-sync gate) — a generated file the plan's file lists omit.
- **Phase 5, `check-metalogic-cycles.sh`** excluded (pre-existing failure outside this plan's
  scope; see Verification and the plan's `#### Reasoned Exclusions`). The plan's contingency
  clause would have left the task `[PARTIAL]`; the exclusion route was taken instead, for the
  reason stated under Decisions.

## Verification

- Build: Success — full `lake build` through the guard (2840 jobs, exit 0, 0 errors), `lake
  build BimodalTest` exit 0; `.olean` newer than source for `RunLayer`, the aggregator,
  `FormalSystem` and `KTypeSummaryAxiomTest`.
- Sorry count: 0 (`lean-sorry-census.sh` over the resolved source roots).
- Vacuous count: 0 in this task's files. The single-line grep over the whole tree returns ONE
  pre-existing hit, `FormalSystem/Examples/TemporalStructures.lean:495`
  (`int_domain_universal … := trivial`, a `True`-valued domain predicate), present unchanged at
  the plan commit `66090a45f` and not touched by this task.
- Axiom count: 14 before (at `66090a45f`) and 14 after — unchanged.
- Axiom profiles: all twenty Goals declarations and the probe's five headlines within
  `[propext, Classical.choice, Quot.sound]` (`FwdFinBranch`, `BwdFinBranch`, `Drift`, `Count`,
  `Rlad` use no axioms); no `sorryAx`.
- Plan compliance: all twenty Goals names found in the source roots (`passed`).
- Gates: `check-evidence-probes.sh` PASS (27/27); `check-module-invariants.sh` exit 0 (INV,
  C14, C15, C23, C29 all PASS); `check-copyright-headers.sh --strict` 0 missing; `readme-lint.sh`
  PASS; `lake exe mk_all --lib FormalSystem --check` "No update necessary"; `lake exe lint-style`
  clean; `verify-deploy.sh` PASS (14 checks); `check-task-references.sh` PASS on every touched
  non-`specs/**` file; `grep "Decidable (PlusValidZTime"` in the README hits only sentences
  saying it is not stated; no version language in the README diff.
- **Pre-existing gate failure, excluded**: `bash scripts/check-metalogic-cycles.sh` exits 1 —
  `FAIL unlayered module FormalSystem.PlusLanguage.PlusRayFibre: the per-file table
  LANGUAGE_FILE_LAYERS["PlusLanguage"] has no row PlusRayFibre`. `PlusRayFibre.lean` landed in
  commit `6cd41837f`; neither it, `scripts/check-metalogic-cycles.sh` nor
  `scripts/measure-refactor-partitions.py` changed since the plan commit, where the same table
  has no such row. Not caused by and not fixable within this task.
- Tests: N/A beyond the `#guard_msgs` pins (all match).
- Files verified: Yes.

## Impacts

- `ofSlicedStepFinBranch` is now available to any record that needs a regular `ℤ`-frame on an
  infinite slice from a finitely branching time-indexed relation; `ladderFrame` is the run layer's
  frame scheme, ready for the phase-2 realization theorem to be stated against.
- The README's (W) section is the current design of record for the run layer: obligation (i)
  regularity part landed, obligation (ii) open in two halves with its first statement fixed,
  obligation (iii) discharged, `k = 1`.

## Follow-ups

- Run-layer phase 2 (soundness half): state and prove the stabilization of realized type sets in
  the deadline counter `c` for `ladderFrame`; its own record, no cost figure until that lemma.
- Run-layer phase 3 (completeness half, (C)'s general row): open; its own record.
- Repository hygiene, outside this task: add the `PlusRayFibre` row to
  `LANGUAGE_FILE_LAYERS["PlusLanguage"]` in `scripts/measure-refactor-partitions.py` so that
  `check-metalogic-cycles.sh` (a CI step) goes green again.
- Advisory: `scripts/decidability-inventory-baseline.txt` is 15 probe entries behind the tree.

## References

- specs/750_w_run_layer_closure_wide_lift/plans/01_w-run-layer-ladder-scheme.md
- specs/750_w_run_layer_closure_wide_lift/reports/01_w-run-layer-design.md
- specs/750_w_run_layer_closure_wide_lift/evidence/01_deadline-ladder-branching.lean
- specs/750_w_run_layer_closure_wide_lift/handoffs/ (one handoff per phase)
- specs/750_w_run_layer_closure_wide_lift/issues.jsonl
