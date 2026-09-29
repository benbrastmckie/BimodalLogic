# Phase 2 handoff — task 696

- **Phase**: 2, free-standing `LiftableRaw` and its sufficient lemmas — COMPLETED
- **Next action**: Phase 3, the atomic-batch that adds `trans`/`lift` as `SharingSkeleton`
  fields and updates all seven sites (5 producers + 2 `skeleton` projections).

## What landed

A raw substrate layer in `Sharing/Skeleton.lean`, inserted before the structure so the
structure can carry `LiftableRaw` as a field: `transEqInhabited`, `repOf`, `shareOf` with
refl/symm/trans, `stepOf`, `transMatOf`, `transOf` (arrival-pruned), `LiftableRaw`,
`SpliceClosedRaw`, plus `liftable_of_full`, `liftable_of_spliceClosed` and
`liftable_of_constant_below`.

Each raw definition is chosen so the post-Phase-3 projection is definitional: `K.rep` will be
`repOf K.n K.repBack K.repMid K.repFwd`, and likewise for `share`, `Step` and `trans`.

`liftable_of_constant_below` is the constant-path corollary for the gate families: below a cut
every class is a singleton so a `Step`-path cannot move, above it every two indices share, so
the constant path at the path's value just below the cut tracks it everywhere.

`liftable_of_spliceClosed` runs the two-splice extension (one splice to reach the new time, one
to graft it onto the index already tracking the interior) on both ends of `[-N, N]`, then
pigeonholes over `Fin n` via the private `exists_cofinal_value`.

## Verification

`lake build` green (2771 jobs). Diff is 244 added lines, 0 deletions, so no existing statement
changed. Axioms: `liftable_of_full` `[propext, Classical.choice]`, `liftable_of_spliceClosed`
`[propext, Classical.choice, Quot.sound]`, `liftable_of_constant_below` `[propext, Quot.sound]`
— all subsets of the pinned set, no `sorryAx`.

## Deviations

None. The Scope Hypothesis was confirmed rather than repaired: the gluing step is about raw
paths, not `Thread`.
