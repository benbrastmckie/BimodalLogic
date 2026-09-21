# GameTransfer

Transfer of Ehrenfeucht-Fraisse game equivalences across structures: the split-point
construction and the GHR93 case analysis built on it.

This directory holds the split-point machinery that lets a duplicator strategy on one structure
be transported to another, together with the continuation-set vocabulary and the case analysis
of the GHR93 inductive step. It was called `Expressiveness/` while it sat inside
`WeakCanonical/`; it is now `GameTransfer/` inside
[`Metalogic/Expressiveness/`](../README.md), where the old name would have collided with the
parent directory.

## Modules

| File | Lines | Description |
|------|-------|-------------|
| `CaseAnalysis.lean` | 2,178 | Cases I and II of the GHR93 inductive step (`ghr93_case_I`, `ghr93_case_II`) |
| `ContinuationSets.lean` | 1,654 | Continuation-set vocabulary (`ContHolds`, `ContHoldsCross`, `ContinuationSetCross`) and the base-case M/N equalities |
| `DConsistencyTransport.lean` | 755 | D-consistency transport and rank-down projection for the transfer argument |
| `SplitPoint.lean` | 4,906 | Split-point construction (`SplitPointProps`, `obtain_split_point_props`) |

## Key Results

- `obtain_split_point_props` (`SplitPoint.lean`): obtains a split point with the properties the
  transfer argument consumes.
- `ghr93_case_I`, `ghr93_case_II` (`CaseAnalysis.lean`): the two surviving cases of the GHR93
  inductive step.
- `d_consistency_left`, `d_consistency_right`, `ghr93_duplicator_wins_rank_down`
  (`DConsistencyTransport.lean`): D-consistency transports across the split, and the duplicator
  wins the rank-reduced game.
- `base_case_M_eq`, `base_case_N_eq` (`ContinuationSets.lean`): the base case of the transfer
  induction on each side.

## Archival Note

The forward-to-backward transfer chain (`ghr93_forward_to_backward_core`,
`ghr93_forward_to_backward`, `ghr93_forward_to_backward_rank_varying`), the gap cases III-IV,
the `ghr93_cases_II_III_IV` dispatcher and the `ghr93_inductive_step` assembly were archived to
`Boneyard/SorriedDeclExcisions/Ghr93ForwardToBackwardChain.lean`: a dead closure resting on
sorried gap-detection lemmas, with zero external call sites. The live
`ghr93_inductive_step_discrete` (`Metalogic/WeakCanonical/Transfer.lean`) is a distinct
declaration and does not depend on the archived chain. A declaration-free
`Theorem6.lean` shim survived that archival for a time, forwarding only an import of
`CaseAnalysis.lean`; it has been removed and its importers re-pointed at `CaseAnalysis.lean`
directly. `CaseAnalysis.lean`'s own module docstring carries the same record.

## Dependencies

- **Imports from**: `FormalSystem.Metalogic.Expressiveness.EFGames`, `FormalSystem.Metalogic.WeakCanonical.NEquivalence`
- **Imported by**: `FormalSystem.Metalogic.Expressiveness` (top level)

## Related Documentation

- [Expressiveness README](../README.md)
- [EFGames README](../EFGames/README.md)
- [WeakCanonical README](../../WeakCanonical/README.md)
- [ExpressiveCompleteness README](../../../Boneyard/Kamp/KampWeakCanonical/ExpressiveCompleteness/README.md) (archived)

---

*Last verified: 2026-09-21*
