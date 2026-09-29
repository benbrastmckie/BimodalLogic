# Phase 3 handoff — task 696

- **Phase**: 3, `trans` and `lift` as skeleton fields, and every producer — COMPLETED
  (atomic-batch, committed as one unit)
- **Next action**: Phases 4 and 5, insulating the Formula-side and Plus-side `Thread.step`
  consumers behind `thread_share_succ` while `Thread.step` still means `share (u+1)`.

## What landed

`SharingSkeleton` gained eight fields: `transBack`/`transMid`/`transFwd`, their three length
equalities against the `rep` lists, `trans_refl`, and `lift`. The same eight were re-exported
through `SharingWitnessFamily` and `PlusSharingWitnessFamily` and carried by both `skeleton`
projections.

The derived layer in `Skeleton.lean`: `transRaw` (the decoded Boolean matrix), `transRaw_def`,
`transBack_ne`/`transFwd_ne` (from the length equalities), the two periodicity twins
`transRaw_sub_back_length`/`transRaw_add_fwd_length` at the representatives' own periods,
`transRaw_refl`, the arrival-pruned `trans`, `trans_def`, `trans_refl'`, `share_succ_of_trans`,
a `Decidable` instance, and four `rfl` bridges to the raw layer (`rep_eq_repOf`,
`share_iff_shareOf`, `step_iff_stepOf`, `trans_iff_transOf`) so Phase 6 can apply `K.lift` to
`K.Step`-paths without rewriting.

Producers use a free-succession bundle added for the purpose: `transFullOf n l` is one full
matrix per representative map, with `transFullOf_length`, `transFullOf_ne`, `transFullOf_all`,
`transFullOf_refl` and `liftable_of_transFullOf`. Each of the five producers is eight lines.
Because every landed producer is full-succession, the presented tree is exactly the pre-redesign
one, which is why no theorem's content changed.

Two strengthenings were needed beyond the plan's list and are recorded here: `unrollOf_mem`
(with both cycles non-empty the decoding never falls through to the default) and
`transMatOf_full`. The unconditional `unrollOf_mem_or_default` is not enough for fullness,
because the out-of-range default is the identity relation rather than the full one.

## Verification

`lake build` green (2771 jobs), first attempt after wiring. Diff across `FormalSystem/` is 367
added lines and **zero deletions**, so no theorem statement changed.
`scripts/check-module-invariants.sh` exit 0 with C2 unchanged at nineteen. Two new compiler
warnings (a deprecated `push_neg` and one long line) were fixed rather than absorbed into
`scripts/warning-budget.txt`.

## Deviations

None. The Scope Hypothesis was confirmed: the compiler named exactly the five producers and two
projections the plan predicted.
