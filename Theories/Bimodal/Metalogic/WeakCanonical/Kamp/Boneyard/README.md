# Kamp Boneyard -- Archived Kamp-Pipeline Dead Code

Archived Lean files from the Kamp/Rabinovich expressive-completeness pipeline
(`Theories/Bimodal/Metalogic/WeakCanonical/Kamp/`). Files here are probes,
retired escalation paths, and superseded infrastructure that are no longer on
any live proof path.

## Build Policy: Never Compiled

Boneyard code is never compiled. There is no lakefile target covering this
directory; liveness equals reachability: a module is live if and only if it is
reachable from `Theories/Bimodal.lean` or another lakefile root. Nothing under
a `Boneyard/` directory is reachable from any root.

The only build invariant is that the default target stays green after any
Boneyard change:

```bash
# Must stay green after any Boneyard change
lake build
```

Import lines inside archived files are historical text, not build edges. They
are kept coherent with file locations where cheap (imports among co-archived
files are rewritten to their `Kamp.Boneyard.*` paths), but stale imports in
never-built code are cosmetic and need not be repaired.

## Inventory

### ZetaProbes/ (5 files) -- superseded by the landed zeta wire

Probe files exploring alternatives for the zeta atom-map/rendering step of the
Kamp translation. All were superseded when the zeta wire landed in the live
pipeline (`Kamp/` proper); none has a live importer.

| File | Lines | What it probed |
|------|------:|----------------|
| `HCaptureDischarge.lean` | 117 | H-capture discharge alternative |
| `InfAlphabetProbe.lean` | 135 | Infinite-alphabet handling probe |
| `OptionBLocalityProbe.lean` | 102 | Option-B locality probe |
| `PerFormulaRenderProbe.lean` | 568 | Per-formula rendering probe |
| `ZetaAtomMapReconcile.lean` | 182 | Zeta atom-map reconciliation probe |

### NfMultiAnchorBridgeRetired/ (4 files) -- retired k>=2 per-depth escalation path

The surviving files of the former `Kamp/NfMultiAnchorBridge/` directory: the
per-depth (k >= 2) escalation route for the normal-form multi-anchor bridge,
retired once the faithful single-route bridge was settled. Imports among these
files were rewritten to their archived module paths.

| File | Lines |
|------|------:|
| `ExteriorDeepExclSupplyK.lean` | 131 |
| `ExteriorDeepSliceSupplyK.lean` | 185 |
| `Lemma32Reduction.lean` | 549 |
| `NavigatedEndChar.lean` | 292 |

### Prop43.lean (192 lines) -- Rabinovich Proposition 4.3, off the live path

Rabinovich (2014) Proposition 4.3: every monadic first-order formula is V-EA
equivalent. Built on top of already-archived `VecEA_m.lean` and
`EAVecNegationClosure.lean` (its `Kamp.Boneyard.*` imports were already
correct at archival time). Distinct from `Prop43DepthCharInfra.lean` below and
from the live `Prop43Translate` module in `Kamp/` proper.

### Pre-existing archived contents

Everything else in this directory predates the orphan-triage pass and was
archived by earlier Kamp cleanup passes:

- `Prop43DepthCharInfra.lean` (196 lines): depth-(k+1) NF characterization
  infrastructure. Renamed from its original `Prop43.lean` filename to free the
  path for the Rabinovich Proposition 4.3 file above; the two are unrelated
  developments that happened to share a name.
- `NavigatedEndCharSinglePoint.lean` (308 lines): single-point navigated
  end-characterization; its import of the retired bridge was rewritten to
  `NfMultiAnchorBridgeRetired/`.
- Exterior/interior probe files (`Exterior*ProbeK.lean` family,
  `InteriorHrealSupplyK.lean`, `NfZone*Probe.lean`,
  `SeamPairRefutationProbe.lean`, `ZoneSeamCrossContextProbe.lean`): probe
  iterations for the exterior-fiber / pinned / zone-seam supply steps.
- V-EA and normal-form infrastructure (`VecEA_m.lean`,
  `EAVecNegationClosure.lean`, `VecEAArityFirewall.lean`,
  `ArityReduction.lean`, `FOToVEA.lean`, `NfComposition.lean`,
  `NfExistTL.lean`, `NegationIndep.lean`, `EndpointNegation.lean`,
  `WitnessCount.lean`): superseded vectorized-EA developments.
- Kamp/translation-era files (`KampComposition.lean`,
  `RabinovichTranslation.lean`, `RefutationF2.lean`, `ZoneBridge.lean`,
  `SeparationBridge.lean`, `Separation.lean`): earlier translation and bridge
  iterations.
- `ExpressiveCompleteness/` and `Separation/` subdirectories: archived
  expressive-completeness and separation-theorem developments (see their own
  contents; `ExpressiveCompleteness/README.md` documents that subtree).

## Relationship to the Top-Level Boneyard

The maintenance standard (archival steps, retrieval via `git log --follow`,
archival-reason taxonomy) is documented in `Theories/Bimodal/Boneyard/README.md`.
This directory follows the same never-built policy; it is nested here rather
than under the top-level Boneyard to keep the Kamp pipeline's history next to
the live `Kamp/` code it descended from.
