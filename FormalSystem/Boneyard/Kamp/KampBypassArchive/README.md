# Boneyard / Kamp / KampBypassArchive

The **enriched bypass formula** route to Kamp's theorem: 13 files, the largest single abandoned
approach in the archive.

## What the approach was

A direct construction of a temporal characteristic formula for every arity-1 depth-`k` normal
form, bypassing the separation theorem entirely. `KampBypassCore.lean` defines the enriched
bypass formula; `KampBypassUntil.lean` and `KampBypassSince.lean` prove the two directional
cases; `KampBypassEqCase.lean` handles the degenerate `x = t` case where the NF asserts no strict
order; `KampBypassBridge.lean` connects the zone-bridge lemmas to the temporal encoding;
`KampMutualInduction.lean` closes the loop with a mutual induction on NF depth establishing
`CharPart(k) /\ ExistPart(k)`. `KampForward.lean` and `NfCharFormula.lean` are the outward-facing
assembly; `GeneralExistPart.lean`, `KampBypassK1.lean`, `PriorComposition.lean` and
`PriorComposition_old.lean` are supporting transfer machinery.

## Why it died

The zeta route landed first and keeps `charF` at arity 1 end to end, which is what the live
`kampPriorExpressiveCompleteness` development is built on. The bypass route reached the same
target through a much larger surface -- roughly 9,400 lines against the zeta route's -- and was
never wired. Its dependency on `PriorComposition` cross-structure transfer, and on
`ZoneBridge`/`KampComposition` in the sibling `KampWeakCanonical/TranslationEra/`, ties it to a
translation-era design the live tree has moved past.

## What revival would require

Re-establishing the live-side lemmas it imports from `Metalogic/WeakCanonical/Kamp/`
(`NfToVecEA`, `VecEADecomp`, `ExistsForallNF`, `PriorINF`, `Translation`, `VecEATranslation`) at
their current signatures -- these have drifted since excision -- then deciding which of
`PriorComposition.lean` (slim) or `PriorComposition_old.lean` (full) is the intended base, since
the slim file was written to carry only the symbols `KampBypass.lean` needed. Nothing here is a
missing piece of a live proof; it is the losing alternative to a wire that already landed.

## Files

| File | Lines | Path before consolidation | Live origin before archival |
|------|------:|---------------------------|--------------|
| `GeneralExistPart.lean` | 106 | `FormalSystem/Boneyard/KampBypassArchive/GeneralExistPart.lean` | `FormalSystem/Metalogic/WeakCanonical/Kamp/GeneralExistPart.lean` |
| `KampBypass.lean` | 893 | `FormalSystem/Boneyard/KampBypassArchive/KampBypass.lean` | `FormalSystem/Metalogic/WeakCanonical/Kamp/KampBypass.lean` |
| `KampBypassBridge.lean` | 549 | `FormalSystem/Boneyard/KampBypassArchive/KampBypassBridge.lean` | `FormalSystem/Metalogic/WeakCanonical/Kamp/KampBypassBridge.lean` |
| `KampBypassCore.lean` | 685 | `FormalSystem/Boneyard/KampBypassArchive/KampBypassCore.lean` | `FormalSystem/Metalogic/WeakCanonical/Kamp/KampBypassCore.lean` |
| `KampBypassEqCase.lean` | 895 | `FormalSystem/Boneyard/KampBypassArchive/KampBypassEqCase.lean` | `FormalSystem/Metalogic/WeakCanonical/Kamp/KampBypassEqCase.lean` |
| `KampBypassK1.lean` | 405 | `FormalSystem/Boneyard/KampBypassArchive/KampBypassK1.lean` | `FormalSystem/Metalogic/WeakCanonical/Kamp/KampBypassK1.lean` |
| `KampBypassSince.lean` | 1,311 | `FormalSystem/Boneyard/KampBypassArchive/KampBypassSince.lean` | `FormalSystem/Metalogic/WeakCanonical/Kamp/KampBypassSince.lean` |
| `KampBypassUntil.lean` | 983 | `FormalSystem/Boneyard/KampBypassArchive/KampBypassUntil.lean` | `FormalSystem/Metalogic/WeakCanonical/Kamp/KampBypassUntil.lean` |
| `KampForward.lean` | 679 | `FormalSystem/Boneyard/KampBypassArchive/KampForward.lean` | `FormalSystem/Metalogic/WeakCanonical/Kamp/KampForward.lean` |
| `KampMutualInduction.lean` | 450 | `FormalSystem/Boneyard/KampBypassArchive/KampMutualInduction.lean` | created in the archive (git's rename heuristic pairs it with `RabinovichGeneralized.lean`; treat that as unverified) |
| `NfCharFormula.lean` | 759 | `FormalSystem/Boneyard/KampBypassArchive/NfCharFormula.lean` | `FormalSystem/Metalogic/WeakCanonical/Kamp/NfCharFormula.lean` |
| `PriorComposition.lean` | 404 | `FormalSystem/Boneyard/KampBypassArchive/PriorComposition.lean` | `FormalSystem/Metalogic/WeakCanonical/Kamp/PriorComposition.lean` |
| `PriorComposition_old.lean` | 1,264 | `FormalSystem/Boneyard/KampBypassArchive/PriorComposition_old.lean` | `FormalSystem/Metalogic/WeakCanonical/Kamp/PriorComposition.lean` — the full original, superseded in place by the slim `PriorComposition.lean` beside it |

Nothing in this directory is compiled. It is outside the `lakefile.lean` import closure
and no live module imports it. Its imports are still checked -- C11 in
`scripts/check-module-invariants.sh` requires every one to resolve to a file on disk or be
waived in `scripts/boneyard-import-waivers.txt`.

Last verified: 2026-08-24
