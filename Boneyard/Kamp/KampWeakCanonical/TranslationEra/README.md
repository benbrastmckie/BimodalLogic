# Boneyard / Kamp / KampWeakCanonical / TranslationEra

Earlier **translation and bridge iterations** -- the era before the zeta wire, when the route to
Kamp's theorem ran through an explicit formula translation.

## What the approach was

`RabinovichTranslation.lean` is the translation itself; `KampComposition.lean` composes
translated pieces; `ZoneBridge.lean` (517 lines) bridges zone reasoning into temporal formulas;
`SeparationBridge.lean` connects the translation to the separation development;
`RefutationF2.lean` (986 lines) is a refutation argument for the `F2` case; `Separation.lean` is a
57-line stub left behind when the GHR separation cluster was archived.

## Why it died

Superseded by the zeta route. This directory is the shared dependency floor of two other
abandoned approaches -- `Kamp/KampBypassArchive/` imports `ZoneBridge` and `KampComposition`, and
`Kamp/RabinovichPath/` imports `RabinovichTranslation` and `SeparationBridge` -- so it did not die
on its own; it died when both of its consumers did.

## What revival would require

Reviving a consumer first. On its own this directory proves nothing anyone currently wants;
`ZoneBridge.lean` is the piece most likely to be independently useful, since zone reasoning
survives in the live tree in a different form.

## Files

| File | Lines | Path before consolidation | Live origin before archival |
|------|------:|---------------------------|--------------|
| `KampComposition.lean` | 217 | `FormalSystem/Metalogic/WeakCanonical/Kamp/Boneyard/KampComposition.lean` | `FormalSystem/Metalogic/WeakCanonical/Kamp/KampComposition.lean` |
| `RabinovichTranslation.lean` | 306 | `FormalSystem/Metalogic/WeakCanonical/Kamp/Boneyard/RabinovichTranslation.lean` | `FormalSystem/Metalogic/WeakCanonical/Kamp/RabinovichTranslation.lean` |
| `RefutationF2.lean` | 986 | `FormalSystem/Metalogic/WeakCanonical/Kamp/Boneyard/RefutationF2.lean` | `FormalSystem/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/RefutationF2.lean` |
| `Separation.lean` | 57 | `FormalSystem/Metalogic/WeakCanonical/Kamp/Boneyard/Separation.lean` | created in the archive (`b8ff094b0`) |
| `SeparationBridge.lean` | 203 | `FormalSystem/Metalogic/WeakCanonical/Kamp/Boneyard/SeparationBridge.lean` | `FormalSystem/Metalogic/WeakCanonical/Kamp/SeparationBridge.lean` |
| `ZoneBridge.lean` | 517 | `FormalSystem/Metalogic/WeakCanonical/Kamp/Boneyard/ZoneBridge.lean` | `FormalSystem/Metalogic/WeakCanonical/Kamp/ZoneBridge.lean` |

Every file here sat flat at the `KampWeakCanonical/` root until this directory was created;
the "path before consolidation" column gives where each one lived before the archives were
merged, which is also where it sat before the regroup.

Nothing in this directory is compiled. It is outside the `lakefile.lean` import closure
and no live module imports it. Its imports are still checked -- C11 in
`scripts/check-module-invariants.sh` requires every one to resolve to a file on disk or be
waived in `scripts/boneyard-import-waivers.txt`.

Last verified: 2026-08-24
