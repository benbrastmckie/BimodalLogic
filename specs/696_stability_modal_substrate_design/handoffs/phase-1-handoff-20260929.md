# Phase 1 handoff — task 696

- **Phase**: 1, Land the `untl`-side incompleteness — COMPLETED
- **Next action**: Phase 2, free-standing `LiftableRaw` + `liftable_of_full` +
  `liftable_of_spliceClosed` + constant-path corollary, in `Sharing/Skeleton.lean`.

## State

Both round-1 probes re-elaborated clean against the current tree before porting, as the
phase's Scope Hypothesis required. Three declarations landed in
`PlusWitnessFamily/Incompleteness.lean`: `untl_shift_share_congr`, `stabUntlTarget` +
`not_plusCertifies_stabUntl`, and `not_plusValidZTime_stabUntl`. C2 baseline went from
sixteen to nineteen rows; `docs/theorem-index.md` gained three matching `pcq pinned:C2` rows.

The rule-of-thumb correction landed in both READMEs and in the `Incompleteness.lean` and
`PlusWitnessFamily.lean` docstrings: the defect is about a condition quantifying over the
one-step *reach* of a position when that reach is a whole `share`-class, at either time —
not about the quantifier naming the label's own time. The "position = history type"
paragraph is in `Sharing/README.md`'s correction section.

## Verification

`lake build` green (2771 jobs). `scripts/check-module-invariants.sh` exit 0, C2 reporting
nineteen. `scripts/readme-lint.sh` PASS. The generated inventory blocks in `README.md` and
`FormalSystem/Metalogic/README.md` were regenerated via `--emit-inventory` (line counts only).

## Deviations

None. All seven checklist items executed as written.
