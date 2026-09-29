# Phase 9 Handoff — Family A in the tree, the `snce`-side certificate

- **Task**: 696
- **Phase**: 9 [COMPLETED]
- **Timestamp**: 2026-09-29
- **Session**: sess_1790680388_3d4c26 (dispatch 7)

## What this phase establishes

The non-vacuity gate, by construction. `plusCertifies_stabSnce_example` is a six-condition
L⁺ certificate for `Pp → ⊡Pp` at NON-TRIVIAL sharing: indices 0 and 1 name one world state from
the origin on, and `famA_separates_snce` exhibits them disagreeing on `Pp` at the origin. Before
the redesign no such family existed, and the retired `not_plusCertifies_stabSnce` proved none
could.

`not_snce_share_congr` closes the second half of the gate: the retired congruence is REFUTED, not
merely unproved. A redesign that reproduced the defect in a differently-spelled clause would
break the old proof term while still entailing the old statement; this theorem rules that out.

## Immediate next action

Start Phase 10: Family B, the `untl`-side twin, from the same probe file at
`specs/696_stability_modal_substrate_design/probes/03_trans_redesign_gate_probe.lean` lines
569-892. Family B shares on `(0, ∞)` and is discrete on `(-∞, 0]`, so its `lift` discharges
through `liftable_of_constant_below` with the cut at `1` rather than `0`, and its representative
segments are `[id], [id], [c]` rather than Family A's `[id], [c], [c]`.

Rename as for Family A to avoid collisions: the probe's `Fp`/`Np`/`RB`/`UB`/`d0` need new names
(`untlP`, and so on). The target theorems are `plusCertifies_stabUntl_example` and
`not_untl_shift_share_congr`.

## State at phase end

`lake build` green over all 2771 jobs, zero sorries, axiom count 14 (unchanged),
`scripts/check-module-invariants.sh` reporting ALL CHECKS PASSED with C2 at sixteen rows.

## New substrate API, in `Sharing/Skeleton.lean`

- `transId` / `transIdOf` / `transIdOf_length` / `transIdOf_refl` / `transMatOf_id` /
  `transId_eq` — the **no-hopping bundle**: one identity succession matrix per representative
  map, decoding to the identity at every time (the out-of-range default is already that matrix).
  This is what lets a family share states without letting a thread cross between them.
- `unrollOf_singletons` / `repOf_singletons` — three singleton segments decoded. Needed because
  `lift` is discharged inside a producer's own structure literal, before any family-level
  decoding lemma is available.

Family B will use both, so neither needs re-deriving.

## Import change

`Examples.lean` now imports `Agreement.lean` (for `PlusCertifies`) instead of `Decide.lean`, and
`Incompleteness.lean` imports `Examples.lean` instead of `Agreement.lean`. Neither is imported by
`Agreement.lean`, so there is no cycle.

## Naming

The probe's short names collide with `Incompleteness.lean`'s. Family A's are `snceP`,
`stabSnceP`, `targetA`, `closA`, `a0b`/`a0m`/`a1b`/`a1m`, `lassoA0`/`lassoA1`, `famA`, `cA`.
