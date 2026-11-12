# Separation — Separation Theorem

Separation theorem for TM bimodal logic completeness.

This directory proves the key separation theorem: for any two N-inequivalent pointed
models, there exists a TM formula that distinguishes them. This theorem is fundamental
to the expressive completeness proof, establishing that TM logic captures all
bisimulation-invariant properties expressible in the language.

## Modules

<!-- BEGIN GENERATED: inventory dir=FormalSystem/Metalogic/Expressiveness/Separation rows=both cols=lines -->
| File | Lines | Description |
|------|-------|-------------|
| `Defs.lean` | 582 | Core definitions for the integer-time separation argument (GHR94 Chapter 10.2): `IntStructure`/`IntTruth`/`IntEquiv`, semantic purity and `U`/`S`-freeness predicates, syntactic separation, and structural depth measures |
| `KampTranslation.lean` | 172 | Kamp-translation infrastructure for `U`/`S` expressive completeness on Z-structures: formula-list operations and atom-literal construction; the full translation is blocked on the n-variable Fraisse game argument |
| `SemanticBridge.lean` | 176 | Bridges `IntStructure`/`IntTruth` (separation framework) with `OrderedMonadicStructure`/`TemporalTruth` (completeness framework): `zStructureToInt`, truth-matching on the Z-carrier, and order-isomorphism transfer |
<!-- END GENERATED -->

## Key Results

- `separation_theorem`: N-inequivalent pointed models are separated by a TM formula
- `normal_form`: Every TM formula equivalent to one in a specific normal form
- `elimination_lemma`: Complex temporal formulas reduce via elimination

## Dependencies

- **Imports from**: `FormalSystem.Metalogic.Expressiveness.EFGames`, `FormalSystem.Metalogic.WeakCanonical.IntegerModel`
- **Imported by**: `FormalSystem.Metalogic.Expressiveness.GameTransfer`

## Related Documentation

- [WeakCanonical README](../../WeakCanonical/README.md)
- [DedekindZ README](../../../../Boneyard/Kamp/KampWeakCanonical/Separation/DedekindZ/README.md) (archived)
- [Hierarchy README](../../../../Boneyard/Kamp/KampWeakCanonical/Separation/Hierarchy/README.md) (archived)
- [EFGames README](../EFGames/README.md)

---

*Last verified: 2026-09-21*
