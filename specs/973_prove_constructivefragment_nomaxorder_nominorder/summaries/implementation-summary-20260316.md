# Implementation Summary: Task 973

**Task**: Prove NoMaxOrder/NoMinOrder on ConstructiveQuotient
**Status**: BLOCKED
**Date**: 2026-03-16
**Session**: sess_1773682669_6061b2

## Blocker Description

The implementation is blocked by an import conflict. Importing `Bimodal.Metalogic.Canonical.CanonicalIrreflexivityAxiom` (or the underlying `Bimodal.Metalogic.Bundle.CanonicalIrreflexivity`) causes elaboration failures in unrelated earlier proofs in `ConstructiveFragment.lean`.

### Specific Errors

When the import is added, the following proofs break:
- Line 201: `ih h_reach2 h_prefix` - Application type mismatch
- Line 215: Same issue in backward_witness case
- Line 230: `Subtype.ext` argument type mismatch
- Line 240: `subst` fails on equality proof

These are in the `ConstructiveReachable.encode_determines` theorem and the `Countable` instance, which worked before the import was added.

### Root Cause Analysis

The issue appears to be an elaboration order or instance resolution conflict introduced by the transitive imports:
- `CanonicalIrreflexivityAxiom` imports `Bundle.CanonicalIrreflexivity`
- `CanonicalIrreflexivity` imports `Bundle.WitnessSeed`, `Core.MCSProperties`, etc.
- Something in this import chain affects how Lean elaborates the induction hypothesis in `encode_determines`

The lean-lsp MCP server shows the proofs working correctly, but `lake build` fails. This suggests a cache-dependent elaboration issue.

### Attempted Solutions

1. Moving import position (beginning, middle, end of import list) - No effect
2. Cleaning `.lake/build/lib/Bimodal/Metalogic/Canonical/` cache - Temporarily works, then breaks again
3. Importing `Bundle.CanonicalIrreflexivity` directly instead of the Axiom wrapper - Same issue
4. Importing individual transitive dependencies (WitnessSeed, MCSProperties, Propositional) - All cause same issue

### Required Resolution

The proofs require `canonicalR_irreflexive` and `canonicalR_strict` from `CanonicalIrreflexivityAxiom`. Options:

1. **Fix the import conflict** (recommended): Investigate why importing CanonicalIrreflexivity affects the elaboration of unrelated proofs. This may require:
   - Adding explicit type annotations to `encode_determines`
   - Adjusting the proof structure to be more robust to elaboration changes
   - Understanding what instance or definition in the import chain causes the conflict

2. **Restructure ConstructiveFragment**: Move the `NoMaxOrder`/`NoMinOrder` instances to a separate file that can safely import CanonicalIrreflexivityAxiom

3. **Copy/inline the theorem**: Inline `canonicalR_irreflexive` in ConstructiveFragment (not ideal - would duplicate the 1200+ line proof)

## Proof Sketches (Ready to Use Once Import Fixed)

### NoMaxOrder
```lean
instance : NoMaxOrder (ConstructiveQuotient M0 h_mcs0) where
  exists_gt := by
    intro a
    induction a using Antisymmetrization.ind with
    | _ w =>
      have h_F := SetMaximalConsistent.contains_seriality_future w.val w.is_mcs
      let N := executeForwardStep w.val w.is_mcs (Formula.neg Formula.bot) h_F
      have h_N_mcs := executeForwardStep_mcs (h_mcs := w.is_mcs) (h_F := h_F)
      have h_R := executeForwardStep_canonicalR (h_mcs := w.is_mcs) (h_F := h_F)
      have h_strict : -CanonicalR N w.val := canonicalR_strict w.val N w.is_mcs h_N_mcs h_R
      obtain <h_reach> := w.property
      have h_N_reach : Nonempty (ConstructiveReachable M0 h_mcs0 N) :=
        <ConstructiveReachable.forward_witness w.val (Formula.neg Formula.bot) h_reach w.is_mcs h_F>
      let w' : ConstructiveFragment M0 h_mcs0 := <N, h_N_reach>
      use toAntisymmetrization (. <= .) w'
      rw [toAntisymmetrization_lt_toAntisymmetrization_iff]
      constructor
      . exact Or.inr h_R
      . intro h_le_back
        cases h_le_back with
        | inl h_eq => exact canonicalR_irreflexive w.val w.is_mcs (Eq.subst h_eq h_R)
        | inr h_R_back => exact h_strict h_R_back
```

### NoMinOrder
Similar structure using `executeBackwardStep` and `contains_seriality_past`.

## Files Modified

None (changes reverted due to blocker)

## Recommendation

This task requires user investigation of the import conflict before it can proceed. The proof logic is correct and verified via lean-lsp, but the import dependency creates an unresolvable build failure.
