# WeakCanonical — Weak Canonical Model Construction

Weak canonical model construction for Base TM completeness (Henkin-style approach).

This directory implements completeness for the Base TM logic variant via a reflexive
canonical model. The approach generalizes the classical Henkin construction to the
bimodal setting with temporal operators, using bisimulation equivalence games to
characterize expressive power and establishing completeness via normal-form reduction.

## Modules

| File | Lines | Description |
|------|-------|-------------|
| `BackAndForth.lean` | 265 | Back-and-forth systems for the bisimulation layer |
| `ChronicleExtraction.lean` | 215 | Extracting chronicles from the weak canonical model |
| `ColourOrders.lean` | 328 | Coloured orders used by the separation development |
| `EFGameTactics.lean` | 331 | EF game automation tactics for expressive completeness proofs |
| `FrameProperties.lean` | 67 | Frame property verification for the weak canonical model |
| `MixedSum.lean` | 558 | Mixed-sum order construction |
| `MonadicFO.lean` | 822 | Monadic first-order logic translation for expressiveness results |
| `NEquivalence.lean` | 1,315 | N-equivalence relation and its properties for bisimulation games |
| `NormalForm.lean` | 873 | Normal form for TM formulas used in the completeness proof |
| `OrderedSum.lean` | 57 | Ordered sum construction for building new models |
| `PriorDefs.lean` | 47 | Shared definitions for the Prior expressiveness development |
| `PriorDefsDense.lean` | 408 | Prior definitions specialized to the dense setting |
| `PriorExpressiveness.lean` | 372 | Prior's theorem on temporal expressiveness |
| `PriorExpressivenessDense.lean` | 412 | Prior expressiveness in the dense setting |
| `ReflexiveCanonical.lean` | 780 | Main reflexive canonical model construction |
| `StaviConnectives.lean` | 583 | Stavi connectives (Until, Since extensions) and their properties |
| `Table.lean` | 296 | Tabular representation for N-equivalence classes |
| `Transfer.lean` | 1,054 | Transfer lemma (`truth_transfer`) and the signature/atom-map layer |
| `TruthLemma.lean` | 206 | MCS-membership characterizations for the weak canonical model |
| `DenseModelSurgery/` | 7,568 | Dense model surgery — part of the Dedekind/real route (9 files) |
| `EFGames/` | 11,872 | Ehrenfeucht-Fraisse bisimulation game engine (8 files) |
| `Expressiveness/` | 9,503 | Expressiveness separation results (5 files) |
| `GroupModel/` | 3,357 | Non-Archimedean `ℚ ×ₗ ℤ` companion chain and `countermodel_discrete` (6 files) |
| `IntegerModel/` | 5,700 | Integer model construction (6 files) |
| `Kamp/` | 77,619 | Kamp/Reynolds separation machinery (116 files) -- by far the largest subtree in the repository, and the reason `WeakCanonical` is the riskiest thing in the tree to relocate. |
| `RealModel/` | 6,643 | Real-line model construction — part of the Dedekind/real route (7 files) |
| `Separation/` | 926 | Separation theorem and supporting lemmas (3 files) |

Measured live contents: **19 loose modules and 8 subdirectories**.
The aggregator for this directory is the sibling `Metalogic/WeakCanonical.lean`, not a self-named
file inside it. Counts above are measured and exclude the archive. `Kamp/` used to carry its own
local `Boneyard/`, which meant a filter naming only the top-level archive counted it as live;
the two archives are now consolidated at [`FormalSystem/Boneyard/`](../../Boneyard/README.md) and
B0 asserts the directory count is exactly 1. Run `scripts/check-module-invariants.sh` rather than
an ad-hoc `find` to re-derive live counts.

## Key Results

- `countermodel_discrete` (`GroupModel/CountermodelBase.lean:142`): the discrete countermodel at
  the non-Archimedean carrier `ℚ ×ₗ ℤ`, off `companionChronicle`. It is the Base-frame discrete
  branch of the flagship `completeness`.
- `truth_transfer` (`Transfer.lean:359`): truth transfers across the signature/atom-map layer,
  the terminus of the transfer development.
- `TruthLemma.lean` supplies the MCS-membership characterizations the construction consumes:
  `bot_not_in_mcs`, `G_forward_mcs`, `G_backward_mcs`, `H_forward_mcs`, `H_backward_mcs`.

Both flagship results above are `SORRY-FREE (sorryAx-free; axioms: exactly propext,
Classical.choice, Quot.sound)`.

## Architecture

```
ReflexiveCanonical.lean
       |
       +-- TruthLemma.lean
       |        |
       +-- NEquivalence.lean
       |        |
       +-- EFGames/             (bisimulation games)
       +-- Expressiveness/
       +-- Separation/          (separation theorem)
       +-- IntegerModel/        (integer witness model)
       +-- GroupModel/          (non-Archimedean discrete countermodel)
       +-- DenseModelSurgery/   (dense/real route)
       +-- RealModel/           (dense/real route)
```

`ExpressiveCompleteness/` was consolidated into
[`FormalSystem/Boneyard/Kamp/KampWeakCanonical/ExpressiveCompleteness`](../../Boneyard/Kamp/KampWeakCanonical/ExpressiveCompleteness/README.md)
and is no longer part of the live architecture.

## Dependencies

- **Imports from**: `FormalSystem.Metalogic.Core`, `FormalSystem.Syntax`
- **Imported by**: `FormalSystem.Metalogic.WeakCanonical` (the sibling aggregator)

## Related Documentation

- [Metalogic README](../README.md)
- [EFGames README](EFGames/README.md)
- [Separation README](Separation/README.md)
- [BXCanonical README](../BXCanonical/README.md)

---

*Last verified: 2026-05-29*
