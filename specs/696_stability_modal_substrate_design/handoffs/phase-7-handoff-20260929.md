# Phase 7 Handoff — Re-quantify (C1') over `trans`, Formula side

- **Task**: 696
- **Phase**: 7 [COMPLETED]
- **Timestamp**: 2026-09-29
- **Session**: sess_1790680388_3d4c26 (dispatch 7)

## Immediate next action

Start Phase 8: the same re-quantification on the PlusFormula side, then empty the defect record.
The Formula-side edits are a line-for-line template; the Plus twins are

- `PlusWitnessFamily/Predicates.lean` — the `untl`/`snce` clauses of `PlusLocalCoherentShare`
- `PlusWitnessFamily/Decide.lean` — `shareClauseAt`, `CoherentShareAt`, `coherentShareAt_congr`,
  `exists_window_repr`, and `localCoherentShare_iff_at`
- `PlusWitnessFamily/Fulfil.lean` and `PlusWitnessFamily/Agreement.lean` — the propagation and
  along-thread lemmas

Phase 8's Scope Hypothesis says to build BEFORE removing anything from `Incompleteness.lean`:
the compiler's error list on that module is the authoritative set of five declarations expected
to become unprovable. If one of the five still elaborates, stop and report it.

## State at phase end

`lake build` green over all 2771 jobs, zero sorries, axiom count 14 (unchanged),
`scripts/check-module-invariants.sh` reporting ALL CHECKS PASSED.

## Key decisions

- The `snce` clause is stated as `∀ k, S.trans (t - 1) k i → …`, with the predecessor as the
  SOURCE of the succession. `Int` makes `t - 1 + 1` non-definitional, so `trans_pred_iff` in
  `Sharing/Basic.lean` bridges to the arrival share stated at `t` itself. The Plus side will need
  its own copy of that bridge.
- `shareClauseAt` carries two extra arguments, `tt tm : Fin n → Fin n → Bool` (the succession
  matrices at `t` and `t - 1`), and spells each side condition out as the pair `trans` is, so the
  decidability instance closes with no unfolding.
- `data_congr_back`/`data_congr_fwd` were NOT extended. `exists_window_repr` instead consumes the
  `transRaw_congr_NB`/`transRaw_congr_NF` lemmas from Phase 6 as two further `first` alternatives.
- `thread_share_pred` survives (the `predF` filter still has a `share` row). The clause's side
  condition is the new `thread_trans_pred`.

## Residual agreement, recorded

`Sharing/Agreement.lean` now carries `untl_succ_congr` and `snce_pred_congr` with a section
header stating what the clauses still force, why it is semantically forced (a position is a
history type), and why it is not the repaired defect (a common successor is strictly finer than
a shared state).

## Scope Hypothesis verdict

Held. `threadFulfilling_of_window`'s far-left and far-right cases needed no new hypothesis, and
the `Decidable (S.Certifies t)` example in `Sharing/Agreement.lean` still elaborates.

## Note for Phases 9-10

Every landed producer supplies `transFull` (the all-true matrix) for its succession datum, so on
every family that exists today `trans u i j ↔ share (u+1) i j` and this re-quantification is
content-preserving. The repair only bites once a producer supplies a proper sub-matrix, which is
exactly what Families A and B must do.
