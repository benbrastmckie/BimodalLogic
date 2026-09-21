# Boneyard / Kamp / KampWeakCanonical / Separation

The archived **GHR separation-theorem** development -- Kamp's original route to expressive
completeness, via separating a temporal formula into pure past, present and future parts.

## What the approach was

A full separation development: `NormalForm.lean` and `FormulaOps.lean` set up the syntax,
`Eliminations.lean` (919 lines) and `DualEliminations.lean` carry the elimination rules,
`Duality.lean` and `NegationEquiv.lean` the dual and negation transformations,
`Distributivity.lean` and `TemporalClosure.lean` the closure properties, `IntHelpers.lean` the
integer arithmetic, and `SeparationThm.lean` assembles the separation theorem itself. Two
subdirectories continue it: [`DedekindZ/`](DedekindZ/README.md) and
[`Hierarchy/`](Hierarchy/README.md), each with its own README.

## Why it died

Bit rot. The cluster was archived together with the `ExpressiveCompleteness/` subtree when it
stopped typechecking against the live `Metalogic/WeakCanonical/Separation/` development, which had
moved on. The live tree keeps a separation development at
`FormalSystem/Metalogic/WeakCanonical/Separation/`; this is the earlier one it descends from.

## What revival would require

Reconciling against the live `Metalogic/WeakCanonical/Separation/` files of the same names -- they
are the continuation of this code, not independent work, so a revival is really a merge. Check
what the live version dropped and whether it was dropped on purpose before restoring it.

## Files

| File | Lines | Path before consolidation | Live origin before archival |
|------|------:|---------------------------|--------------|
| `Distributivity.lean` | 207 | `FormalSystem/Metalogic/WeakCanonical/Kamp/Boneyard/Separation/Distributivity.lean` | `FormalSystem/Metalogic/WeakCanonical/Separation/Distributivity.lean` |
| `DualEliminations.lean` | 120 | `FormalSystem/Metalogic/WeakCanonical/Kamp/Boneyard/Separation/DualEliminations.lean` | `FormalSystem/Metalogic/WeakCanonical/Separation/DualEliminations.lean` |
| `Duality.lean` | 361 | `FormalSystem/Metalogic/WeakCanonical/Kamp/Boneyard/Separation/Duality.lean` | `FormalSystem/Metalogic/WeakCanonical/Separation/Duality.lean` |
| `Eliminations.lean` | 919 | `FormalSystem/Metalogic/WeakCanonical/Kamp/Boneyard/Separation/Eliminations.lean` | `FormalSystem/Metalogic/WeakCanonical/Separation/Eliminations.lean` |
| `FormulaOps.lean` | 254 | `FormalSystem/Metalogic/WeakCanonical/Kamp/Boneyard/Separation/FormulaOps.lean` | `FormalSystem/Metalogic/WeakCanonical/Separation/FormulaOps.lean` |
| `IntHelpers.lean` | 150 | `FormalSystem/Metalogic/WeakCanonical/Kamp/Boneyard/Separation/IntHelpers.lean` | `FormalSystem/Metalogic/WeakCanonical/Separation/IntHelpers.lean` |
| `NegationEquiv.lean` | 178 | `FormalSystem/Metalogic/WeakCanonical/Kamp/Boneyard/Separation/NegationEquiv.lean` | `FormalSystem/Metalogic/WeakCanonical/Separation/NegationEquiv.lean` |
| `NormalForm.lean` | 573 | `FormalSystem/Metalogic/WeakCanonical/Kamp/Boneyard/Separation/NormalForm.lean` | `FormalSystem/Metalogic/WeakCanonical/Separation/NormalForm.lean` |
| `SeparationThm.lean` | 373 | `FormalSystem/Metalogic/WeakCanonical/Kamp/Boneyard/Separation/SeparationThm.lean` | `FormalSystem/Metalogic/WeakCanonical/Separation/SeparationThm.lean` |
| `TemporalClosure.lean` | 693 | `FormalSystem/Metalogic/WeakCanonical/Kamp/Boneyard/Separation/TemporalClosure.lean` | `FormalSystem/Metalogic/WeakCanonical/Separation/TemporalClosure.lean` |

Plus two documented subdirectories: `DedekindZ/` (2 files) and `Hierarchy/` (4 files).

Nothing in this directory is compiled. It is outside the `lakefile.lean` import closure
and no live module imports it. Its imports are still checked -- C11 in
`scripts/check-module-invariants.sh` requires every one to resolve to a file on disk or be
waived in `scripts/boneyard-import-waivers.txt`.

Last verified: 2026-08-24
