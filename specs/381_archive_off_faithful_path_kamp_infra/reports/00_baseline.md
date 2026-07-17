# Phase 0 Baseline Capture

## Build baseline
- `lake build` EXIT 0
- Job count: **1766 jobs** ("Build completed successfully (1766 jobs).")

## Reference axiom set: `Bimodal.Metalogic.BXCanonical.completeness_discrete`

Captured via `lean_verify` (fully qualified name):

```
axioms: ["propext","sorryAx","Classical.choice","Lean.ofReduceBool","Lean.trustCompiler","Quot.sound"]
warnings: []
```

`sorryAx` present = the single permitted `_k+2` sorry. This exact set is the comparison
reference for every later batch: no new axiom name may appear, and `sorryAx` must remain
(nothing lost). A silently-dropped live proof-term dependency would change this set.

## Live completeness_discrete location
`Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean:275`
(namespace `Bimodal.Metalogic.BXCanonical`)

Note: a second, unrelated `completeness_discrete` exists in the pre-existing
`Theories/Bimodal/Boneyard/StrictSemanticsLegacy/DiscreteCompleteness.lean` — NOT the live one.

## Pre-existing Kamp/Boneyard contents (must never be emptied)
ArityReduction, EAVecNegationClosure, EndpointNegation, FOToVEA, KampComposition,
NavigatedEndCharSinglePoint, NegationIndep, NfComposition, NfExistTL, NfZoneDepthK1Probe,
NfZoneNavProbe, Prop43, RabinovichTranslation, SeparationBridge, VecEAArityFirewall, VecEA_m,
WitnessCount, ZoneBridge (18 files).
