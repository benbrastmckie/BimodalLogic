# Separation — Separation Theorem

Separation theorem for TM bimodal logic completeness.

This directory proves the key separation theorem: for any two N-inequivalent pointed
models, there exists a TM formula that distinguishes them. This theorem is fundamental
to the expressive completeness proof, establishing that TM logic captures all
bisimulation-invariant properties expressible in the language.

## Modules

| File | Lines | Description |
|------|-------|-------------|
| `Defs.lean` | 553 | Core definitions for the separation argument: N-types, separating formulas |
| `Distributivity.lean` | 188 | Distributivity lemmas for temporal connectives in separation arguments |
| `DualEliminations.lean` | 101 | Dual elimination lemmas: eliminating Until/Since via duality |
| `Duality.lean` | 342 | Temporal duality (G/H, F/P, U/S) in the separation context |
| `Eliminations.lean` | 902 | Elimination lemmas: reducing complex formulas in separation arguments |
| `FormulaOps.lean` | 235 | Formula operations used in separation: substitution, normalization |
| `IntHelpers.lean` | 131 | Integer arithmetic helpers for time-point calculations |
| `NegationEquiv.lean` | 159 | Negation equivalence lemmas |
| `NormalForm.lean` | 554 | Normal form reduction specific to the separation theorem |
| `SeparationThm.lean` | 369 | Main separation theorem: N-inequivalent => formula separator exists |
| `TemporalClosure.lean` | 674 | Temporal closure properties used in the separation argument |
| `DedekindZ/` | — | Dedekind-complete integer order constructions (2 files) |
| `Hierarchy/` | — | Expressive hierarchy completion (3 files) |

## Key Results

- `separation_theorem`: N-inequivalent pointed models are separated by a TM formula
- `normal_form`: Every TM formula equivalent to one in a specific normal form
- `elimination_lemma`: Complex temporal formulas reduce via elimination

## Dependencies

- **Imports from**: `Bimodal.Metalogic.WeakCanonical.EFGames`, `Bimodal.Metalogic.WeakCanonical.IntegerModel`
- **Imported by**: `Bimodal.Metalogic.WeakCanonical.ExpressiveCompleteness`

## Related Documentation

- [WeakCanonical README](../README.md)
- [DedekindZ README](DedekindZ/README.md)
- [Hierarchy README](Hierarchy/README.md)
- [EFGames README](../EFGames/README.md)

---

*Last verified: 2026-05-29*

> **Note**: This README was last verified before task 131 (module reorg) -- verify
> file list is still current after that task completes.
