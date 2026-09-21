# EFGames — Ehrenfeucht-Fraisse Bisimulation Games

Bisimulation game engine for TM bimodal logic expressiveness proofs.

This directory implements the Ehrenfeucht-Fraisse (EF) game framework used to prove
expressiveness and separation results for TM logic. EF games characterize when two
structures are indistinguishable by formulas of bounded modal depth, providing the
combinatorial core of the expressive completeness proof.

## Modules

| File | Lines | Description |
|------|-------|-------------|
| `CharacteristicFormula.lean` | 685 | Characteristic formulas for EF game positions |
| `Composition.lean` | 641 | Game composition: combining games for complex structures |
| `CustomGame.lean` | 1726 | Custom game configurations for bimodal logic structures |
| `Decomposition.lean` | 322 | Game decomposition lemmas for structured models |
| `Defs.lean` | 559 | Core game definitions: positions, moves, strategies, winning conditions |
| `GapDetection.lean` | 369 | Gap detection formulas of GHR93 Definition 8.5 (`leftFormula`, `rightFormula` and their base cases) with their rank bounds |
| `GapDetectionLeft.lean` | 2130 | GHR93 Lemma 9, left direction: `left_formula_gap_detection` and its gap-uniqueness and `U'` helpers |
| `GapDetectionRight.lean` | 2239 | GHR93 Lemma 9, right direction: `right_formula_gap_detection` and its gap-uniqueness and `S'` helpers |
| `MuRelativizedTruth.lean` | 434 | Mu-relativized truth agrees with ordinary truth at actual points (`stavi_truth_mu_at_point`) |
| `StaviCompleteness.lean` | 1665 | Stavi-completeness: EF games characterize Until/Since expressiveness |
| `TypeFormulas.lean` | 1116 | Type formula construction from game positions |

`NFGameBridge.lean` is archived at `Boneyard/StaviDiscretePath/NFGameBridge.lean`.

The four gap-detection modules are one development split along its import seams.
`MuRelativizedTruth.lean` does not use the gap detection formulas and is the only one of the four
that the rest of the library imports (`CustomGame.lean` and, through it, `GameTransfer/`).
`GapDetectionLeft.lean` and `GapDetectionRight.lean` each import `GapDetection.lean` and
`MuRelativizedTruth.lean` and do not depend on each other.

## Key Results

- `ef_game_defs`: Core EF game structure and winning strategy conditions
- `characteristic_formula`: Game position -> distinguishing formula (inverse direction)
- `stavi_completeness`: Stavi connectives are expressively complete for bisimulation invariance
- `left_formula_gap_detection` (`GapDetectionLeft.lean`), `right_formula_gap_detection`
  (`GapDetectionRight.lean`): GHR93 Lemma 9, the two directions of gap detection correctness
- `stavi_truth_mu_at_point` (`MuRelativizedTruth.lean`): mu-relativized truth at an actual point
  is truth in the base structure

## Dependencies

- **Imports from**: `FormalSystem.Syntax`, `FormalSystem.Semantics`, `FormalSystem.Metalogic.WeakCanonical.NEquivalence`
- **Imported by**: `FormalSystem.Metalogic.Expressiveness.GameTransfer`, `FormalSystem.Metalogic.Expressiveness.Separation`

## Related Documentation

- [WeakCanonical README](../../WeakCanonical/README.md)
- [ExpressiveCompleteness README](../../../../Boneyard/Kamp/KampWeakCanonical/ExpressiveCompleteness/README.md) (archived)

---

*Last verified: 2026-09-21*
