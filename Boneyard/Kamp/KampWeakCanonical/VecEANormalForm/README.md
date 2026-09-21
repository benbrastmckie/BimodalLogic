# Boneyard / Kamp / KampWeakCanonical / VecEANormalForm

Superseded **vectorized-EA and normal-form infrastructure**.

## What the approach was

The vectorized existential-universal (V-EA) layer that an earlier Kamp route was built on.
`VecEA_m.lean` (663 lines) is the arity-`m` core; `ArityReduction.lean` and
`VecEAArityFirewall.lean` control arity; `FOToVEA.lean` translates first-order formulas in;
`NfComposition.lean` (650 lines), `NfExistTL.lean` and `WitnessCount.lean` handle normal-form
composition, existential temporal-logic translation and witness counting;
`EAVecNegationClosure.lean`, `NegationIndep.lean` and `EndpointNegation.lean` cover negation.

## Why it died

The live tree keeps its V-EA layer at `Metalogic/WeakCanonical/Kamp/` (`VecEAFormula`,
`VecEAClosure`, `VecEACombinators`, `VecEATranslation`, `VecEADecomp`, `NfToVecEA`), which is the
continuation of this code under a design that keeps arity at 1 wherever possible. The arity-`m`
generality here was the thing that made the surrounding proofs large, and dropping it is what
made the zeta route tractable.

## What revival would require

A genuine need for arity `m > 1`, which the landed zeta route was specifically designed to avoid.
`VecEAArityFirewall.lean` is worth reading first: it documents the boundary the live design
chose not to cross.

## Files

| File | Lines | Path before consolidation | Live origin before archival |
|------|------:|---------------------------|--------------|
| `ArityReduction.lean` | 114 | `FormalSystem/Metalogic/WeakCanonical/Kamp/Boneyard/ArityReduction.lean` | `FormalSystem/Metalogic/WeakCanonical/Kamp/ArityReduction.lean` |
| `EAVecNegationClosure.lean` | 300 | `FormalSystem/Metalogic/WeakCanonical/Kamp/Boneyard/EAVecNegationClosure.lean` | `FormalSystem/Metalogic/WeakCanonical/Kamp/EAVecNegationClosure.lean` |
| `EndpointNegation.lean` | 166 | `FormalSystem/Metalogic/WeakCanonical/Kamp/Boneyard/EndpointNegation.lean` | `FormalSystem/Metalogic/WeakCanonical/Kamp/EndpointNegation.lean` |
| `FOToVEA.lean` | 153 | `FormalSystem/Metalogic/WeakCanonical/Kamp/Boneyard/FOToVEA.lean` | `FormalSystem/Metalogic/WeakCanonical/Kamp/FOToVEA.lean` |
| `NegationIndep.lean` | 388 | `FormalSystem/Metalogic/WeakCanonical/Kamp/Boneyard/NegationIndep.lean` | `FormalSystem/Metalogic/WeakCanonical/Kamp/NegationIndep.lean` |
| `NfComposition.lean` | 650 | `FormalSystem/Metalogic/WeakCanonical/Kamp/Boneyard/NfComposition.lean` | `FormalSystem/Metalogic/WeakCanonical/Kamp/NfComposition.lean` |
| `NfExistTL.lean` | 325 | `FormalSystem/Metalogic/WeakCanonical/Kamp/Boneyard/NfExistTL.lean` | `FormalSystem/Metalogic/WeakCanonical/Kamp/NfExistTL.lean` |
| `VecEAArityFirewall.lean` | 146 | `FormalSystem/Metalogic/WeakCanonical/Kamp/Boneyard/VecEAArityFirewall.lean` | `FormalSystem/Metalogic/WeakCanonical/Kamp/VecEAArityFirewall.lean` |
| `VecEA_m.lean` | 663 | `FormalSystem/Metalogic/WeakCanonical/Kamp/Boneyard/VecEA_m.lean` | `FormalSystem/Metalogic/WeakCanonical/Kamp/VecEA_m.lean` |
| `WitnessCount.lean` | 151 | `FormalSystem/Metalogic/WeakCanonical/Kamp/Boneyard/WitnessCount.lean` | `FormalSystem/Metalogic/WeakCanonical/Kamp/WitnessCount.lean` |

Every file here sat flat at the `KampWeakCanonical/` root until this directory was created;
the "path before consolidation" column gives where each one lived before the archives were
merged, which is also where it sat before the regroup.

Nothing in this directory is compiled. It is outside the `lakefile.lean` import closure
and no live module imports it. Its imports are still checked -- C11 in
`scripts/check-module-invariants.sh` requires every one to resolve to a file on disk or be
waived in `scripts/boneyard-import-waivers.txt`.

Last verified: 2026-08-24
