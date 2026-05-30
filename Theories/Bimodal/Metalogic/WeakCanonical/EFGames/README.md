# EFGames — Ehrenfeucht-Fraisse Bisimulation Games

Bisimulation game engine for TM bimodal logic expressiveness proofs.

This directory implements the Ehrenfeucht-Fraisse (EF) game framework used to prove
expressiveness and separation results for TM logic. EF games characterize when two
structures are indistinguishable by formulas of bounded modal depth, providing the
combinatorial core of the expressive completeness proof.

## Modules

| File | Lines | Description |
|------|-------|-------------|
| `CharacteristicFormula.lean` | 666 | Characteristic formulas for EF game positions |
| `Composition.lean` | 626 | Game composition: combining games for complex structures |
| `CustomGame.lean` | 1703 | Custom game configurations for bimodal logic structures |
| `Decomposition.lean` | 315 | Game decomposition lemmas for structured models |
| `Defs.lean` | 559 | Core game definitions: positions, moves, strategies, winning conditions |
| `GapDetection.lean` | 5057 | Gap detection algorithm for identifying separating formulas |
| `NFGameBridge.lean` | 173 | Bridge between normal-form formulas and game positions |
| `StaviCompleteness.lean` | 3252 | Stavi-completeness: EF games characterize Until/Since expressiveness |
| `TypeFormulas.lean` | 1068 | Type formula construction from game positions |

## Key Results

- `ef_game_defs`: Core EF game structure and winning strategy conditions
- `characteristic_formula`: Game position -> distinguishing formula (inverse direction)
- `stavi_completeness`: Stavi connectives are expressively complete for bisimulation invariance
- `gap_detection`: Algorithm for finding formulas that separate two structures

## Dependencies

- **Imports from**: `Bimodal.Syntax`, `Bimodal.Semantics`, `Bimodal.Metalogic.WeakCanonical.NEquivalence`
- **Imported by**: `Bimodal.Metalogic.WeakCanonical.ExpressiveCompleteness`, `Bimodal.Metalogic.WeakCanonical.Separation`

## Related Documentation

- [WeakCanonical README](../README.md)
- [ExpressiveCompleteness README](../ExpressiveCompleteness/README.md)

---

*Last verified: 2026-05-29*

> **Note**: This README was last verified before task 131 (module reorg) -- verify
> file list is still current after that task completes.
