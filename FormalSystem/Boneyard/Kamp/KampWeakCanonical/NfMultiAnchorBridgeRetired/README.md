# Boneyard / Kamp / KampWeakCanonical / NfMultiAnchorBridgeRetired

The retired **k >= 2 per-depth escalation path** through the multi-anchor bridge.

## What the approach was

An escalation strategy for the multi-anchor bridge that handled each NF depth `k >= 2`
separately: `Lemma32Reduction.lean` (553 lines) is the reduction step,
`ExteriorDeepExclSupplyK.lean` and `ExteriorDeepSliceSupplyK.lean` supply the deep exterior cases,
`NavigatedEndChar.lean` gives the navigated end characterization, and
`EndIntervalSkeleton.lean` is the `CarrierK1V` end-interval skeleton it was built on.

## Why it died

The per-depth escalation was replaced by a uniform treatment in the live
`Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/`. Escalating per depth meant the proof surface
grew with `k`; the uniform version does not.

## What revival would require

A reason to prefer per-depth handling over the uniform bridge -- for instance a case where the
uniform argument's hypotheses are too strong. The retired files import live
`NfMultiAnchorBridge` modules whose signatures have moved since retirement, so any revival starts
with re-typechecking against the current bridge, not with the mathematics.

## Files

| File | Lines | Path before consolidation | Live origin before archival |
|------|------:|---------------------------|--------------|
| `EndIntervalSkeleton.lean` | 126 | `FormalSystem/Metalogic/WeakCanonical/Kamp/Boneyard/NfMultiAnchorBridgeRetired/EndIntervalSkeleton.lean` | created in the archive (`cafd4849a`) |
| `ExteriorDeepExclSupplyK.lean` | 136 | `FormalSystem/Metalogic/WeakCanonical/Kamp/Boneyard/NfMultiAnchorBridgeRetired/ExteriorDeepExclSupplyK.lean` | `FormalSystem/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorDeepExclSupplyK.lean` |
| `ExteriorDeepSliceSupplyK.lean` | 190 | `FormalSystem/Metalogic/WeakCanonical/Kamp/Boneyard/NfMultiAnchorBridgeRetired/ExteriorDeepSliceSupplyK.lean` | `FormalSystem/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorDeepSliceSupplyK.lean` |
| `Lemma32Reduction.lean` | 553 | `FormalSystem/Metalogic/WeakCanonical/Kamp/Boneyard/NfMultiAnchorBridgeRetired/Lemma32Reduction.lean` | `FormalSystem/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/Lemma32Reduction.lean` |
| `NavigatedEndChar.lean` | 296 | `FormalSystem/Metalogic/WeakCanonical/Kamp/Boneyard/NfMultiAnchorBridgeRetired/NavigatedEndChar.lean` | `FormalSystem/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/NavigatedEndChar.lean` |

Nothing in this directory is compiled. It is outside the `lakefile.lean` import closure
and no live module imports it. Its imports are still checked -- C11 in
`scripts/check-module-invariants.sh` requires every one to resolve to a file on disk or be
waived in `scripts/boneyard-import-waivers.txt`.

Last verified: 2026-08-24
