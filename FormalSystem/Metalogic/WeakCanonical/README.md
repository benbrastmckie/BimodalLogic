# WeakCanonical — Weak Canonical Model Construction

Weak canonical model construction for Base TM completeness (Henkin-style approach).

This directory implements completeness for the Base TM logic variant via a reflexive
canonical model. The approach generalizes the classical Henkin construction to the
bimodal setting with temporal operators, reaching a discrete countermodel through the
Reynolds/Doets integer and non-Archimedean group models.

The expressive-completeness development that used to live here — the monadic first-order
framework, the Ehrenfeucht-Fraisse games, the normal-form theory, the Gabbay separation route
and the Kamp/Stavi theorems — is a separate development about expressive power rather than
about canonical models, and now lives in the sibling
[`Metalogic/Expressiveness/`](../Expressiveness/README.md). Nothing in that directory imports
anything from this one, which is what makes the split a partition rather than a renaming.

## Modules

<!-- BEGIN GENERATED: inventory dir=FormalSystem/Metalogic/WeakCanonical cols=files-lines -->
| Module | Files | Lines | Description |
|------|------:|------:|-------------|
| `BackAndForth.lean` | 1 | 267 | Back-and-forth systems for the bisimulation layer |
| `ChronicleExtraction.lean` | 1 | 194 | Extracting chronicles from the weak canonical model |
| `ColourOrders.lean` | 1 | 332 | Coloured orders used by the model constructions |
| `FrameProperties.lean` | 1 | 53 | Frame property verification for the weak canonical model |
| `KTypeSummary.lean` | 1 | 42 | Aggregator for `KTypeSummary/` — Büchi's complementation chain in the monadic `k`-type idiom |
| `MixedSum.lean` | 1 | 562 | Mixed-sum order construction |
| `NEquivalence.lean` | 1 | 1,316 | N-equivalence relation and its properties for bisimulation games |
| `OrderedSum.lean` | 1 | 60 | Ordered sum construction for building new models |
| `ReflexiveCanonical.lean` | 1 | 764 | Main reflexive canonical model construction |
| `Transfer.lean` | 1 | 1,059 | Transfer lemma (`truth_transfer`) and the signature/atom-map layer |
| `TruthLemma.lean` | 1 | 196 | MCS-membership characterizations for the weak canonical model |
| `DenseModelSurgery/` | 9 | 7,935 | Dense model surgery — part of the Dedekind/real route |
| `GroupModel/` | 6 | 3,150 | Non-Archimedean `ℚ ×ₗ ℤ` companion chain and `countermodel_discrete` |
| `IntegerModel/` | 6 | 5,625 | Integer model construction |
| `KTypeSummary/` | 6 | 958 | `k`-type summaries over the `ℤ` time axis: the finite summary alphabet, with the segment carrier, Ramsey cover and saturation steps appended as they land |
| `RealModel/` | 7 | 6,790 | Real-line model construction — part of the Dedekind/real route |
<!-- END GENERATED -->

Measured live contents: **10 loose modules and 4 subdirectories**, 38 modules in total.
The aggregator for this directory is the sibling `Metalogic/WeakCanonical.lean`, not a self-named
file inside it. Counts above are measured and exclude the archive. `Kamp/` used to carry its own
local `Boneyard/`, which meant a filter naming only the top-level archive counted it as live;
the two archives are now consolidated at [`Boneyard/`](../../../Boneyard/README.md) and
B0 asserts the directory count is exactly 1. Run `scripts/check-module-invariants.sh` rather than
an ad-hoc `find` to re-derive live counts.

## Key Results

- `countermodel_discrete` (`GroupModel/CountermodelBase.lean`): the discrete countermodel at
  the non-Archimedean carrier `ℚ ×ₗ ℤ`, off `companionChronicle`. It is the Base-frame discrete
  branch of the flagship `completeness`.
- `truth_transfer` (`Transfer.lean`): truth transfers across the signature/atom-map layer,
  the terminus of the transfer development.
- `TruthLemma.lean` supplies the MCS-membership characterizations the construction consumes:
  `bot_not_in_mcs`, `G_forward_mcs`, `G_backward_mcs`, `H_forward_mcs`, `H_backward_mcs`.

Both flagship results above are `SORRY-FREE (sorryAx-free; axioms: exactly propext,
Classical.choice, Quot.sound)`.

`GroupModel/CountermodelBase.lean` stays in this directory and its path is unchanged by the
extraction of the expressiveness development. Citations of that path elsewhere in the
repository therefore do not drift, and no consumer of `countermodel_discrete` needs updating:
the declaration's fully-qualified name
`FormalSystem.Metalogic.WeakCanonical.countermodel_discrete` is likewise unchanged.

## Architecture

```
ReflexiveCanonical.lean
       |
       +-- TruthLemma.lean
       |        |
       +-- NEquivalence.lean
       |        |
       +-- IntegerModel/        (integer witness model)
       +-- GroupModel/          (non-Archimedean discrete countermodel)
       +-- DenseModelSurgery/   (dense/real route)
       +-- RealModel/           (dense/real route)
```

`ExpressiveCompleteness/` was consolidated into
[`Boneyard/Kamp/KampWeakCanonical/ExpressiveCompleteness`](../../../Boneyard/Kamp/KampWeakCanonical/ExpressiveCompleteness/README.md)
and is no longer part of the live architecture.

## Dependencies

- **Imports from**: `FormalSystem.Metalogic.Core`, `FormalSystem.Syntax`
- **Imported by**: `FormalSystem.Metalogic.WeakCanonical` (the sibling aggregator)

## Related Documentation

- [Metalogic README](../README.md)
- [Expressiveness README](../Expressiveness/README.md)
- [BXCanonical README](../BXCanonical/README.md)

---

*Last verified: 2026-11-12*
