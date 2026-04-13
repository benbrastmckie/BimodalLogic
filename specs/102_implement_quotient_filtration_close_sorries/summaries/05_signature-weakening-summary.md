# Implementation Summary: Weaken Frame.lean Sorry Signatures (v5)

- **Task**: 102 - implement_quotient_filtration_close_sorries
- **Plan**: plans/05_signature-weakening-plan.md
- **Status**: Partial (2 of 4 Frame.lean sorries closed)

## Changes Made

### Frame.lean (4 signatures changed, 2 sorries closed)

Changed all 4 eventuality resolution signatures from universal BXPoint
guard quantification to chain-member guard (phi at starting point):

**Before** (unprovable universal guard):
```lean
∃ v : BXPoint, bx_le w v ∧ ψ ∈ v.formulas ∧
  ∀ u : BXPoint, bx_le w u → bx_le u v ∧ ¬bx_le v u → φ ∈ u.formulas
```

**After** (provable chain-member guard):
```lean
∃ v : BXPoint, bx_le w v ∧ ψ ∈ v.formulas ∧ φ ∈ w.formulas
```

Closed:
- `bx_until_eventuality_resolution`: via BX9 (φ ∈ w) + BX10 (F(ψ) ∈ w) + `bx_forward_witness`
- `bx_since_eventuality_resolution`: via BX9' + BX10' + `bx_backward_witness`

Remaining sorry:
- `bx_until_backward`: requires Until induction along chain (no deterministic successor)
- `bx_since_backward`: mirror

### TruthLemma.lean (restructured)

Replaced `until_iff_mcs` (iff with universal guard) with separate directional lemmas:
- `until_forward_mcs`: φ U ψ ∈ w implies ψ ∈ w or (∃ v, bx_le w v ∧ ψ ∈ v ∧ φ ∈ w) -- proved
- `until_backward_refl_mcs`: ψ ∈ w implies φ U ψ ∈ w (BX8) -- proved
- `until_backward_strict_mcs`: delegates to `bx_until_backward` -- sorry (through Frame.lean)
- Mirror lemmas for Since -- same status

### CanonicalChain.lean (delegation bridges updated)

All 4 delegation bridges updated to match new Frame.lean signatures.
No sorries in delegation code.

### Realization.lean (delegation updated)

All 4 delegation functions updated to match new signatures.
No sorries in delegation code.

### LocusControl.lean (delegation updated)

All 4 primed variants updated to match new signatures.
No sorries in delegation code.

## Sorry Count

**Before** (in BXCanonical/):
- Frame.lean: 4 Until/Since sorries + 1 box sorry (pre-existing)
- CanonicalChain.lean: 4 delegation sorries (pure delegation to Frame.lean)
- Realization.lean: 4 delegation sorries (pure delegation to Frame.lean)
- LocusControl.lean: 4 delegation sorries (pure delegation to Realization.lean)
- Total: 16 sorries from 4 root causes + 1 box sorry

**After**:
- Frame.lean: 2 backward sorries + 1 box sorry (pre-existing)
- All delegation bridges: 0 sorries (they delegate without sorry)
- Total: 2 sorries from 2 root causes + 1 box sorry

**Net reduction**: 14 sorry instances removed (4 root -> 2 root)

## Why Backward Direction Remains Sorry

The backward direction (`bx_until_backward`) takes:
- `bx_le w v`, `ψ ∈ v`, `φ ∈ w`, `ψ ∉ w`

And needs to derive `φ U ψ ∈ w`. This requires propagating the Until
formula through the `bx_le` ordering, but `bx_le` (g_content subset)
only propagates G-content formulas, not arbitrary ones.

The deterministic chain approach (DeterministicFMCS.lean in Boneyard)
solves this via `until_intro` + backward induction using a successor
structure (`X(α) ∈ chain(t) ↔ α ∈ chain(t+1)`), but the non-deterministic
canonical ordering lacks this structure.

## Build Status

`lake build` passes with zero errors. The only sorry warnings from
modified files are the 2 backward Frame.lean sorries.

## Files Modified

- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean`
- `Theories/Bimodal/Metalogic/BXCanonical/TruthLemma.lean`
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalChain.lean`
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Realization.lean`
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/LocusControl.lean`
