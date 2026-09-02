# BXCanonical — Burgess-Xu Canonical Model

Canonical model construction for TM completeness at all four frame classes — Base, Dense, Discrete, and Dedekind (Burgess 1982 chronicle approach). This is the **wired completeness entry point** for the repository.

This directory implements weak completeness for all four TM logic variants using a
chronicle-based canonical model. A chronicle is a sequence of maximal consistent sets
satisfying coherence conditions that correspond to the temporal and modal structure of TM frames.
It imports `Algebraic.FlowFrame` for the generic flow-frame countermodel engine.

## Modules

| File | Lines | Description |
|------|-------|-------------|
| `../BXCanonical.lean` | 43 | Re-export module for the BXCanonical package. **Sibling aggregator**, at `FormalSystem/Metalogic/BXCanonical.lean` — not a file inside this directory |
| `CanonicalChain.lean` | 119 | Chronicle chain construction and its linear order |
| `CanonicalModel.lean` | 855 | Canonical model assembly from chronicles; frame/model structure |
| `Completeness.lean` | 432 | Completeness theorem wiring for the Base, Dense, and Discrete variants |
| `CompletenessDedekind.lean` | 607 | Completeness wiring for the Dedekind (real flow) variant |
| `DiscreteCarrierProbe.lean` | 94 | Discrete-carrier probe over the flow-frame engine |
| `Frame.lean` | 728 | Canonical frame properties: task relation, temporal accessibility |
| `OrderedSeedConsistency.lean` | 261 | Seed consistency for the ordered chronicle construction |
| `TruthLemma.lean` | 312 | MCS-membership characterizations feeding the canonical model |
| `Chronicle/` | — | Dense chronicle construction (14 files) |
| `Filtration/` | — | Filtration-based model construction (1 file) |
| `Quasimodel/` | — | Quasimodel intermediate construction (5 files) |

## Key Results

- `completeness` (`Completeness.lean`): every Base-valid formula is derivable in TM Base. This is
  the theorem that closed last, and the reason the tree carries no structural sorry.
- `completeness_dense` (`Completeness.lean`): every validly dense formula is derivable in TM Dense
- `completeness_discrete`: every validly discrete formula is derivable in TM Discrete
- The Dedekind route (`CompletenessDedekind.lean`, 607 lines): the real-flow construction behind
  `completeness_dedekind`, stated against `ValidDedekind`
- `TruthLemma.lean` supplies the MCS-membership characterizations the model assembly consumes:
  `bot_not_in_mcs`, `imp_iff_mcs`, `G_iff_mcs`, `H_iff_mcs`, `box_iff_mcs`, `F_from_witness`,
  `P_from_witness`, `until_forward_mcs`, `since_forward_mcs`

All of the above are `SORRY-FREE (sorryAx-free; axioms: exactly propext, Classical.choice,
Quot.sound)`.

## Architecture

```
Completeness.lean / CompletenessDedekind.lean
       |
       +-- TruthLemma.lean
       |        |
       +-- CanonicalModel.lean
       |        |
       +-- Frame.lean
       |        |
       +-- CanonicalChain.lean
       |        |
       +-- Chronicle/          (chronicle construction)
       +-- Quasimodel/         (quasimodel intermediate)
       +-- Filtration/         (filtration for FMP)
```

## Dependencies

- **Imports from**: `FormalSystem.Metalogic.Core`, `FormalSystem.Syntax.SubformulaClosure`,
  `FormalSystem.Metalogic.Algebraic.FlowFrame`
- **Imported by**: `FormalSystem.Metalogic.BXCanonical` (the sibling aggregator)

## Related Documentation

- [Metalogic README](../README.md)
- [Chronicle README](Chronicle/README.md)
- [Quasimodel README](Quasimodel/README.md)
- [Filtration README](Filtration/README.md)

---

*Last verified: 2026-05-29*
