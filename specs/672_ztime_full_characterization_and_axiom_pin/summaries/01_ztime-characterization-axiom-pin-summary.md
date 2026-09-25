# Implementation Summary: Task #672

- **Task**: 672 - Strengthen the `.ZTime` sharpness results to a full `ValidIn fc φ ↔ fc = .ZTime`
  characterization for `Axiom.prior_UZ` and `Axiom.z1`, and pin the resulting headline theorems on
  `FormalSystem/MainResults.lean`'s build-time axiom audit
- **Status**: [COMPLETED]
- **Started**: 2026-09-25T09:48:00Z
- **Completed**: 2026-09-25T10:12:00Z
- **Effort**: ~1.4 hours (5 phases; most wall-time in two full builds and two full gate runs)
- **Dependencies**: None open. Built on task 670's landed `ZTimeSharpness.lean`.
- **Artifacts**: plans/01_ztime-characterization-axiom-pin.md,
  reports/01_ztime-characterization-axiom-pin.md,
  summaries/01_ztime-characterization-axiom-pin-summary.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Six new sorry-free declarations in `FormalSystem/Metalogic/Independence/ZTimeSharpness.lean`
convert four scattered refutations into one exhaustive characterization: each `.ZTime`-tagged
axiom's atomic instance is valid at `FrameClass.ZTime` and at no other frame class. The six names,
together with the four pre-existing headline results, are now build-visible on
`FormalSystem/MainResults.lean`'s axiom-audit page, pinned by a coupled four-edit-site change
across three files. The whole tree builds clean and every check group of
`scripts/check-module-invariants.sh` is green.

## What Changed

- `FormalSystem/Metalogic/Independence/ZTimeSharpness.lean` — added
  `import FormalSystem.Semantics.Correspondence.RigidityReal` (with a comment recording the latent
  `realOrder` ambiguity), and six documented theorems:
  `not_validIn_dense_prior_UZ`, `not_validIn_dense_z1` (over `ztimeSharpOrder`, discharging
  `Sat .Dense` as a pair of instances); `not_validIn_rtime_prior_UZ`, `not_validIn_rtime_z1` (over
  `realOrder`, discharging `TaskFrame.IsComplete` from `Real.exists_isLUB`);
  `prior_UZ_validIn_iff_ztime`, `z1_validIn_iff_ztime` (the biconditionals, by four-way
  `cases fc` plus `prior_UZ_valid` / `z1_valid`). Module docstring upgraded to the stronger claim.
  292 → 423 lines.
- `FormalSystem/MainResults.lean` — new trailing
  `## Frame-class sharpness of the .ZTime axioms` section: prose, 6 `#check @` and 6
  `#print axioms` lines; the stale "105 in all" pinned-declaration figure corrected to 202.
- `scripts/check-module-invariants.sh` — 6 lines appended to `C14_BASELINE` and 6 matching
  `#print axioms` lines to the `C14LEAN` heredoc, in identical order. Both heredocs 192 → 198.
- `scripts/debug-artifact-allowlist.txt` — `FormalSystem/MainResults.lean` count 54 → 66.
- `FormalSystem/Metalogic/Independence.lean`,
  `FormalSystem/Metalogic/Independence/README.md` — ledger entries upgraded from the minimality
  claim to the characterization claim; the README's pre-existing
  `<!-- TODO: add description -->` inventory row for `ZTimeSharpness.lean` filled.
- `FormalSystem/Metalogic/README.md`, `FormalSystem/README.md`, `README.md` — regenerated
  inventory blocks and metric tables (`--emit-inventory` output only).

## Decisions

- Followed the research report's Option B for the `.RTime` witness (import
  `FormalSystem.Semantics.Correspondence.RigidityReal`, use the bare `realOrder`) rather than the
  dispatch's `DedekindNonCompactness` route, which produces `Ambiguous term realOrder`. Option A
  (a local `ztimeSharpRealOrder` abbrev) was the fallback and was not needed: the Phase 2 scoped
  build over the 12-module reverse-dependency set found zero `Ambiguous term` occurrences.
- The biconditionals do **not** route through `eq_base_of_lt_ztime`. `.Dense` and `.RTime` are
  incomparable with `.ZTime` rather than below it, so the order fact reaches only one of the three
  refuted classes; a four-way `cases fc` covers all of them.
- Every statement is at `Formula.atom p`, never schematic in `φ`: `Axiom.prior_UZ ⊥` has an
  unsatisfiable antecedent and so is valid at every class, which would falsify the `∀ φ` form.
- The C27 allow-list value was read off the gate's own report (`allow-list 54, tree 66`), not
  computed as `54 + 12`.

## Plan Deviations

- None (implementation followed plan).

## Verification

- Build: Success. `lake-build-guard.sh build --timeout 1800 -- build`, detached, guard exit 0,
  "Build completed successfully (2735 jobs)", 0 `error:` lines, and `.olean` newer than source for
  every module touched (`ZTimeSharpness`, `Independence`, `MainResults`).
- Gate: `bash scripts/check-module-invariants.sh` exits **0** with **zero** `FAIL` lines. C1, C2,
  C3, C14 (both halves), C16, C17, C19, C20, C21 (33 declarations, all pinned), C24, C27 (66 live
  directives) and INV all green in one run.
- Sorry count: 0 (`lean-sorry-census.sh` over all eight resolved source roots; C3's structural
  inventory independently reports ZERO).
- Vacuous count: 0. The single-line grep raises one hit,
  `FormalSystem/Examples/TemporalStructures.lean:495`
  (`theorem int_domain_universal (t : Int) : intTimeHistory.domain t := trivial`), which is
  byte-identical at the pre-task baseline commit, sits in a file this task never opened, and is a
  false positive: the goal is definitionally `True` for the total ℤ history, so `trivial` is the
  honest proof rather than a placeholder.
- Axiom count: 14 `axiom` declarations across the source roots, identical to the pre-task baseline
  — no increase, and none introduced by this task.
- Measured axiom set: all ten names on the new MainResults section report exactly
  `[propext, Classical.choice, Quot.sound]`, read off the gate's own C14 output.
- Files verified: Yes.

## Impacts

- The `.ZTime` row of `Axiom.minFrameClass` is now characterized rather than bounded on both
  sides, and the claim is machine-checked in three independent places (the `#check`, the C14
  baseline, and C21's closure property) rather than carried by prose or a literature citation.
- A future regression in any of the ten pinned names' axiom dependencies now fails the build's
  gate rather than scrolling past in the log.
- The C14 heredoc pair and the C27 allow-list entry are the sites any further MainResults addition
  must move together; both are now at 198 entries and 66 directives respectively.

## Follow-ups

- `README.md:11` and `README.md:463` still state the harness "checks the axiom sets of 105
  declarations"; the measured figure is now 202. Out of this task's SCOPE clause (repository-root
  README), recorded here rather than fixed.
- `docs/development/CI_CD_PROCESS.md:95` states `MainResults.lean` "emits 54 deliberate `info:`
  messages (25 `#check` plus 29 `#print axioms`)". Both the total (now 66) and the pre-existing
  breakdown (the file had 27 of each before this change, 33 of each now) are stale. `docs/` is out
  of scope.
- Sharpness for the `.Dense` and `.RTime` rows of `Axiom.minFrameClass` (`density`,
  `dense_indicator`, `prior_U_gap`, `sep`) remains upper-bound-only. Separate work, explicitly
  excluded here.
- `FormalSystem/ProofSystem/Axioms.lean`'s `Axiom.minFrameClass` docstring remains true but is now
  weaker than what is proved. Left unedited because the edit costs a full-tree rebuild.

## References

- `specs/672_ztime_full_characterization_and_axiom_pin/plans/01_ztime-characterization-axiom-pin.md`
- `specs/672_ztime_full_characterization_and_axiom_pin/reports/01_ztime-characterization-axiom-pin.md`
- `specs/672_ztime_full_characterization_and_axiom_pin/handoffs/` (per-phase handoffs 1-4)
- `specs/670_minframeclass_sharpness_prior_uz_z1/plans/01_ztime-sharpness-theorems.md`
  (Phases 5 and 6 Reasoned Exclusions tables, which specified this work item by item)
