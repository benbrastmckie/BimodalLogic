# Boneyard / Kamp / KampWeakCanonical / ProbeIterations

Fourteen **probe iterations** on the exterior-fiber, pinned and zone-seam supply steps -- the
search that preceded the supply lemmas the live bridge actually uses.

## What the approach was

Successive attempts at the same obligation, each narrowing the previous one's failure. The
`Exterior*ProbeK` family (nine files) works the exterior fiber and pinned cases: ambient vs fiber
deep-anchor, consistency (and an alternate consistency formulation), the `M1` and `Tail`
variants, and an anchor-specific pinned probe. `InteriorHrealSupplyK.lean` is the interior
counterpart. `NfZoneDepthK1Probe.lean` and `NfZoneNavProbe.lean` probe the zone-depth and
zone-navigation steps; `SeamPairRefutationProbe.lean` and `ZoneSeamCrossContextProbe.lean` probe
the seam.

Several names still carry a numeric suffix in their pre-archival path (`...Probe358K`,
`...Probe364K`, `...Probe367K`) -- those digits were iteration markers and were dropped when the
files were archived.

## Why it died

Probes are written to be discarded. Each answered its question -- usually negatively -- and the
answer went into the design of the supply lemmas in the live
`Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/`. `SeamPairRefutationProbe.lean` is explicitly
a refutation: it records that a seam-pair approach does not work.

## What revival would require

Nothing here should be revived as-is. The value is negative evidence: before attempting an
exterior-fiber or zone-seam supply argument, read these to see which shapes were already tried
and where each broke.

## Files

| File | Lines | Path before consolidation | Live origin before archival |
|------|------:|---------------------------|--------------|
| `ExteriorAmbientDeepAnchorProbeK.lean` | 982 | `FormalSystem/Metalogic/WeakCanonical/Kamp/Boneyard/ExteriorAmbientDeepAnchorProbeK.lean` | `FormalSystem/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorAmbientDeepAnchorProbe358K.lean` |
| `ExteriorFiberConsistencyProbeAltK.lean` | 500 | `FormalSystem/Metalogic/WeakCanonical/Kamp/Boneyard/ExteriorFiberConsistencyProbeAltK.lean` | `FormalSystem/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorFiberConsistencyProbe364K.lean` |
| `ExteriorFiberConsistencyProbeK.lean` | 368 | `FormalSystem/Metalogic/WeakCanonical/Kamp/Boneyard/ExteriorFiberConsistencyProbeK.lean` | `FormalSystem/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorFiberConsistencyProbeK.lean` |
| `ExteriorFiberDeepAnchorProbeK.lean` | 374 | `FormalSystem/Metalogic/WeakCanonical/Kamp/Boneyard/ExteriorFiberDeepAnchorProbeK.lean` | `FormalSystem/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorFiberDeepAnchorProbe367K.lean` |
| `ExteriorFiberProbeK.lean` | 362 | `FormalSystem/Metalogic/WeakCanonical/Kamp/Boneyard/ExteriorFiberProbeK.lean` | `FormalSystem/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorFiberProbeK.lean` |
| `ExteriorPinnedProbeAnchorK.lean` | 182 | `FormalSystem/Metalogic/WeakCanonical/Kamp/Boneyard/ExteriorPinnedProbeAnchorK.lean` | `FormalSystem/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorPinnedProbe358K.lean` |
| `ExteriorPinnedProbeK.lean` | 761 | `FormalSystem/Metalogic/WeakCanonical/Kamp/Boneyard/ExteriorPinnedProbeK.lean` | `FormalSystem/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorPinnedProbeK.lean` |
| `ExteriorPinnedProbeM1K.lean` | 913 | `FormalSystem/Metalogic/WeakCanonical/Kamp/Boneyard/ExteriorPinnedProbeM1K.lean` | `FormalSystem/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorPinnedProbeM1K.lean` |
| `ExteriorPinnedProbeTailK.lean` | 350 | `FormalSystem/Metalogic/WeakCanonical/Kamp/Boneyard/ExteriorPinnedProbeTailK.lean` | `FormalSystem/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorPinnedProbe358TailK.lean` |
| `InteriorHrealSupplyK.lean` | 212 | `FormalSystem/Metalogic/WeakCanonical/Kamp/Boneyard/InteriorHrealSupplyK.lean` | `FormalSystem/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/InteriorHrealSupplyK.lean` |
| `NfZoneDepthK1Probe.lean` | 155 | `FormalSystem/Metalogic/WeakCanonical/Kamp/Boneyard/NfZoneDepthK1Probe.lean` | `FormalSystem/Metalogic/WeakCanonical/Kamp/NfZoneDepthK1Probe.lean` |
| `NfZoneNavProbe.lean` | 189 | `FormalSystem/Metalogic/WeakCanonical/Kamp/Boneyard/NfZoneNavProbe.lean` | `FormalSystem/Metalogic/WeakCanonical/Kamp/NfZoneNavProbe.lean` |
| `SeamPairRefutationProbe.lean` | 177 | `FormalSystem/Metalogic/WeakCanonical/Kamp/Boneyard/SeamPairRefutationProbe.lean` | `FormalSystem/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SeamPairRefutationProbe.lean` |
| `ZoneSeamCrossContextProbe.lean` | 293 | `FormalSystem/Metalogic/WeakCanonical/Kamp/Boneyard/ZoneSeamCrossContextProbe.lean` | `FormalSystem/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ZoneSeamCrossContextProbe.lean` |

Every file here sat flat at the `KampWeakCanonical/` root until this directory was created;
the "path before consolidation" column gives where each one lived before the archives were
merged, which is also where it sat before the regroup.

Nothing in this directory is compiled. It is outside the `lakefile.lean` import closure
and no live module imports it. Its imports are still checked -- C11 in
`scripts/check-module-invariants.sh` requires every one to resolve to a file on disk or be
waived in `scripts/boneyard-import-waivers.txt`.

Last verified: 2026-08-24
