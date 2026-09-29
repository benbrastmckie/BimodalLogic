# Phase 10 Handoff — Family B in the tree, the `untl`-side certificate

- **Task**: 696
- **Phase**: 10 [COMPLETED]
- **Timestamp**: 2026-09-29
- **Session**: sess_1790680388_3d4c26 (dispatch 7)

## What this phase establishes

The non-vacuity gate is now closed on BOTH temporal sides. `plusCertifies_stabUntl_example` is a
six-condition L⁺ certificate for `Fp → (¬p → ⊡Fp)` at non-trivial sharing, and
`not_untl_shift_share_congr` refutes the retired shifted congruence rather than merely leaving it
unproved. Together with Phase 9's pair, the four positive results replace the five retired
negative ones, and `targetA_eq` / `targetB_eq` record that each family's target is the schema
instance `Incompleteness.lean` names, on the nose.

## Immediate next action

Start Phase 11: preserve the closure-necessity obstruction as a wired evidence probe. The probe
source is `specs/696_stability_modal_substrate_design/probes/03_trans_redesign_gate_probe.lean`
section 3 (lines 529-568), `stabFamily_not_liftable`: the landed (C5) witness `stabFamily`,
which shares at `u = 0` only, is NOT liftable at index-identity succession. That is what shows
the `lift` field is a genuine obligation rather than an artefact of the argument — a producer
cannot simply assert it.

## State at phase end

`lake build` green over all 2771 jobs, zero sorries, axiom count 14 (unchanged),
`scripts/check-module-invariants.sh` reporting ALL CHECKS PASSED with C2 at eighteen rows.

## New substrate API this phase added

`liftable_of_constant_above` in `Sharing/Skeleton.lean`: the mirror of
`liftable_of_constant_below`, for a family that shares early and separates late. Family B needed
it because it is total on `(-∞, 0]` and discrete on `[1, ∞)`, the opposite of Family A. Phase 11's
`stabFamily` shares at one time only, so it will need neither.

## Elaboration cost, against the Scope Hypothesis

Family B ported at the same cost as Family A: both families elaborate inside the single
`Examples.lean` build with no heartbeat pressure, and the whole module builds in a couple of
seconds. The `untl` clause's `t + 1` quantification needed no different decoding split; what it
did need was the two-lemma `famB_L_raw`/`famB_L` split, because the family's natural statement is
a two-way `0 < u` test while `unrollOf_singletons` closes the three-way one.
