# Implementation Summary: Task #803

- **Task**: 803 - Cut the elaboration time of `FormalSystem/Metalogic/Decidability/Verified/Termination/SubformulaProperty.lean`
- **Status**: [COMPLETED]
- **Started**: 2026-11-13T16:45:07Z
- **Completed**: 2026-11-13T19:25:00Z
- **Effort**: about 2.7 hours wall-clock, most of it nine guarded full builds
- **Dependencies**: None
- **Artifacts**: plans/01_cut-subformulaproperty-elaboration-time.md, evidence/01_elaboration-baseline.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

All 36 per-rule proofs of the signed subformula property were rewritten to rewrite `hg` with one
arm's equation instead of unfolding the whole 900-line `applyRule` match. Summed over the 36
theorems, elaboration fell from 34,095,081 to 79,799 heartbeats (a factor of 427), and Lake now
reports the module at about 3 seconds where it reported 438-478 seconds. No statement changed, no
`sorry` or axiom was added, and the module builds at the default heartbeat budget with all 36
`maxHeartbeats` ceilings deleted.

## What Changed

- `FormalSystem/Metalogic/Decidability/Verified/Termination/SubformulaProperty.lean` — the 36
  `applyRule_<rule>_closed` proof bodies rewritten: `by_cases` on the arm's side conditions, `rw`
  with the rule's `applyRule_<rule>_arm_eq` wrapper, `split`, `simp only … at hg`; the off-arm case
  goes through `applyRule_offArm_eq`, its 38 guards closed by `contradiction`. All 34
  `maxHeartbeats 1200000` and both `maxHeartbeats 3000000` lines removed, both
  `linter.unusedTactic false` options removed, the per-theorem and section cost notes rewritten
  with the measured attribution, and a `linter.style.longFile 1700` baseline added (1,467 -> 1,617
  lines). `applyRule_subformula_closed` and every statement are byte-identical.
- `FormalSystem/Metalogic/Decidability/Tableau.lean` — 38 wrapper theorems added at the end of the
  file, one per generated `applyRule.eq_N` (36 `applyRule_<rule>_arm_eq`,
  `applyRule_z1Rule_offPattern_eq`, `applyRule_offArm_eq`), each stated as
  `type_of% @applyRule.eq_N`, with a note on why downstream proofs must name a wrapper. Long-file
  baseline raised 3200 -> 3300. No existing declaration touched.
- `FormalSystem/Metalogic/Decidability/Verified/Termination/README.md`,
  `FormalSystem/Metalogic/README.md`, `README.md`, `typst/generated/status.typ` — machine-generated
  line counts refreshed (`check-module-invariants.sh --emit-inventory`,
  `typst-sync-check.sh --fix`).
- `specs/803_cut_subformulaproperty_elaboration_time/evidence/01_elaboration-baseline.md` — the
  before/after record: 36-row heartbeat table, both profiling blocks, axiom profiles, the 38
  equation-lemma types.

## Decisions

- **Wrappers are `type_of%` restatements, not hand-copied right-hand sides.** A wrapper then has
  exactly the generated type, and the 760-line definition is not duplicated.
- **Wrapper names end in `_arm_eq`.** `applyRule_boxNeg_eq` and `applyRule_diamondPos_eq` already
  exist in `MintBound/MintPotential.lean` with different statements.
- **Wrappers sit at the end of `Tableau.lean`.** Placed beside `applyRule` they shifted six
  `Tableau.lean:NNN` citations in five other modules and failed invariant C20; those modules are
  outside this task's file scope, so the block was moved rather than the citers edited.
- **`by_cases` on the side conditions, not `cases sf.sign` / `match sf.formula`.** The negated
  hypothesis lets every catch-all guard close by `contradiction`, with no simp call in the off-arm
  branch and no hoisted `have off`.
- **The propagation-block tightening (R3) was measured and not landed.** On a scratch copy it
  changes its eleven users by -0.8% in total, mixed sign per theorem.

## Plan Deviations

- **Phase 2** altered: wrapper shape (`type_of%`), names (`_arm_eq`), count (38, `z1Rule` has two
  arms), long-file baseline bump, and — in sub-step 9.1 — position (end of file).
- **Phases 3-6** altered: `by_cases` case analysis instead of `cases`/`match` plus hoisted
  `have off`; one commit per phase rather than per theorem.
- **Phase 5** altered: `linter.style.longFile 1700` baseline added to the module.
- **Phase 7** closed `[COMPLETED WITH EXCLUSIONS]`: the conversion task skipped on the Scope
  Hypothesis's own negligible-figures condition; record in the plan's Reasoned Exclusions.
- **Phase 9** altered: wrappers number 38 and are new, so their axiom profiles are recorded rather
  than diffed; the "before" profiling block is the research report's.
- **Every phase gate** was a guarded full build, a superset of the scoped builds the plan names.

## Verification

- Build: Success — guarded full `lake build`, `--no-share`, exit 0, 2975 jobs, 0 `error:` lines,
  no warning; `.olean` newer than source for both edited modules.
- Sorry count: 0
- Vacuous count: 0 in the files this task touched. The tree-wide single-line grep has one hit,
  `FormalSystem/Examples/TemporalStructures.lean:495`, present identically at the base commit.
- Axiom count: 14 `axiom` declarations, unchanged from the base commit. `#print axioms` for all 37
  module declarations: empty diff against the pre-change capture
  (`[propext, Classical.choice, Quot.sound]`). The 38 wrappers report `[propext]`, the same as the
  `applyRule.eq_N` lemmas they restate.
- Tests: `bash scripts/check-module-invariants.sh` — `ALL CHECKS PASSED`, exit 0.
  `check-task-references.sh` exit 0 on both edited files. Plan compliance check: skipped (the
  plan names no Goal identifiers).
- Files verified: Yes
- Batch gate: the batch-wide gate set (`.claude/scripts/tests/run-all.sh`, `verify-deploy.sh`)
  was deferred to the batch stage and not run in this dispatch. Neither has a suite or gate that
  covers this task's `.lean` deliverables or `specs/**` evidence, and no `.claude/**` or
  source-store path was touched, so the checks listed above are the complete applicable set.

## Impacts

- A rebuild triggered by an edit to the syntax or proof-system layer no longer pays for this
  module: about 3s instead of roughly 440-480s in a full build. The 668s the final full build
  still took is `Tableau.lean` (122s) and the modules downstream of it.
- `applyRule_<rule>_arm_eq` and `applyRule_offArm_eq` are available to any other proof that
  currently does `unfold applyRule`; `Tableau.lean` and `CountermodelExtraction.lean` carry such
  proofs.

## Follow-ups

- `Decidability.Tableau` (122s here) is the next-largest cost on this build path, and it and
  `CountermodelExtraction.lean` together still carry 15 `unfold applyRule` call sites that the new
  wrappers could serve. Whether that is where their time goes is unmeasured.
- The propagation blocks keep one full simp set (`simp_all [...]`) and one `by simp` each. A
  `simp only`/`contradiction` replacement is written and measured (evidence section 6); it is
  cost-neutral, so landing it would be a style change only.
- A guarded build replays a stale green result if a source file is edited while a build is
  running; recorded in `issues.jsonl`.

## References

- `specs/803_cut_subformulaproperty_elaboration_time/plans/01_cut-subformulaproperty-elaboration-time.md`
- `specs/803_cut_subformulaproperty_elaboration_time/reports/01_cut-subformulaproperty-elaboration-time.md`
- `specs/803_cut_subformulaproperty_elaboration_time/evidence/01_elaboration-baseline.md`
- `specs/803_cut_subformulaproperty_elaboration_time/handoffs/`
