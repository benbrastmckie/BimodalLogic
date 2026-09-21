# Boneyard / Kamp / KampWeakCanonical / ZetaProbes

Exploratory probes written **while** the zeta route was being designed, superseded by the zeta
wire that actually landed.

## What the approach was

Five one-off experiments, each testing a design question rather than proving a theorem on the
critical path: `HCaptureDischarge.lean` on discharging the H-capture obligation,
`InfAlphabetProbe.lean` on an infinite-alphabet variant, `OptionBLocalityProbe.lean` on whether
Option B's locality assumption survives, `PerFormulaRenderProbe.lean` on per-formula rendering,
and `ZetaAtomMapReconcile.lean` on reconciling two atom maps.

## Why it died

The questions they were written to answer were settled by the landed zeta wire, which took a
different shape from any of the probes. A probe whose question has been answered is not a
half-finished proof; it is a record of the search.

## What revival would require

Nothing, in the usual sense -- these are not incomplete work. They are worth reading if a future
change reopens one of the five questions above, in which case the probe records what was already
tried and what it cost.

## Files

| File | Lines | Path before consolidation | Live origin before archival |
|------|------:|---------------------------|--------------|
| `HCaptureDischarge.lean` | 121 | `FormalSystem/Metalogic/WeakCanonical/Kamp/Boneyard/ZetaProbes/HCaptureDischarge.lean` | `FormalSystem/Metalogic/WeakCanonical/Kamp/HCaptureDischarge.lean` |
| `InfAlphabetProbe.lean` | 139 | `FormalSystem/Metalogic/WeakCanonical/Kamp/Boneyard/ZetaProbes/InfAlphabetProbe.lean` | `FormalSystem/Metalogic/WeakCanonical/Kamp/InfAlphabetProbe.lean` |
| `OptionBLocalityProbe.lean` | 106 | `FormalSystem/Metalogic/WeakCanonical/Kamp/Boneyard/ZetaProbes/OptionBLocalityProbe.lean` | `FormalSystem/Metalogic/WeakCanonical/Kamp/OptionBLocalityProbe.lean` |
| `PerFormulaRenderProbe.lean` | 572 | `FormalSystem/Metalogic/WeakCanonical/Kamp/Boneyard/ZetaProbes/PerFormulaRenderProbe.lean` | `FormalSystem/Metalogic/WeakCanonical/Kamp/PerFormulaRenderProbe.lean` |
| `ZetaAtomMapReconcile.lean` | 186 | `FormalSystem/Metalogic/WeakCanonical/Kamp/Boneyard/ZetaProbes/ZetaAtomMapReconcile.lean` | `FormalSystem/Metalogic/WeakCanonical/Kamp/ZetaAtomMapReconcile.lean` |

Nothing in this directory is compiled. It is outside the `lakefile.lean` import closure
and no live module imports it. Its imports are still checked -- C11 in
`scripts/check-module-invariants.sh` requires every one to resolve to a file on disk or be
waived in `scripts/boneyard-import-waivers.txt`.

Last verified: 2026-08-24
