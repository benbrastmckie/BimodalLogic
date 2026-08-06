# Phase 4.1 handoff (plan v4)

**Plan**: `plans/04_ordtimesknown-strengthening-totality.md` (v4 supersedes v3)

## State

Phase 4.1 `[COMPLETED]`. Pure transcription from `scratch/05_ordtimesknown-repair-check.lean` —
green on the **first** build attempt, no re-derivation needed, no namespace/binder drift despite the
move from `Scratch428Repair` into `FormalSystem.Metalogic.Decidability`.

Landed in `MintBound.lean` (appended after `ordTimes_identifyTime_arm3_false`, all purely
additive): `OrdTimesKnown`, `mem_knownTimes_of_mem`, `exists_mem_of_mem_knownTimes`,
`le_maxTime_of_mem_knownTimes`, `ordTimesLeMaxTime_of_ordTimesKnown`, `counterexample_dies`,
`mem_knownTimes_identifyTime`, `ordTimesKnown_identifyTime`, `knownTimes_mono`,
`ordTimesKnown_mono`, `nextTime_mem_knownTimes_cons`, `sub_append` (private),
`ordTimesKnown_addFuture_cons`, `ordTimesKnown_addPast_cons`, `ordTimesKnown_density_cons`,
`applyRule_ordTimesKnown_nonbranching`, `ordTimesKnown_splitOrdered_arms12`,
`applyRule_irreflOrd_from_known`, `ne_nextTime_from_known`, `ordTimesKnown_empty`. Plus the
do-not-re-attempt register section comment (register entry 7).

Name-collision check done before writing: `mem_knownTimes_of_mem` also exists in
`BoxSaturation.lean:261`, but in namespace `...Decidability.Verified.Bridge` and not on
`MintBound`'s import path — no clash.

## Verification

- `lake build FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound` green, 31s wall /
  2m20s user.
- `lean_verify`: `ordTimesKnown_identifyTime` and `applyRule_ordTimesKnown_nonbranching` both
  `[propext, Classical.choice, Quot.sound]`; `ordTimesLeMaxTime_of_ordTimesKnown` `[propext,
  Quot.sound]`; `ordTimesKnown_empty` `[propext]`. All subsets.
- 0 `sorry`, 0 `^axiom `, 0 `NoSplit`, 0 task-number citations.
- md5 unchanged: `Saturation.lean ae47004e…`, `Tableau.lean cfd82332…`, `Fuel.lean 8a395bd7…`.

## Immediate next action

Phase 4.2 — `applyRule_ordTimesKnown_branching`, the one piece of the repair NOT in the scratch
file (R8). Skeleton is the weak twin `applyRule_ordTimes_branching` (`MintBound.lean:1016`);
substitutions per the plan: `le_maxTime hsf` → `mem_knownTimes_of_mem hsf`, `ordTimes_mono` →
`ordTimesKnown_mono` (note the weak twin uses `ordTimes_mono haux (maxTime_le_append _ _)`; the
strong form takes `sub_append` instead), three `_cons` swaps. Keep `set_option maxHeartbeats
4000000 in`, do not raise.

## Deviations

None. Plan followed exactly.
