# Task 55: Axiom Dependency Trace Report

**Date**: 2026-03-24
**Session**: sess_1774407108_74b56a
**Focus**: Trace completeness export path and check if SuccChain sorry chain is inert

## Executive Summary

The SuccChain sorry chain is **NOT inert**. The `succ_chain_completeness` theorem depends on `sorryAx` through `succ_chain_truth_forward`, which depends on `SuccChainTemporalCoherent`, which in turn depends on the mathematically false `f_nesting_is_bounded`.

The `parametric_algebraic_representation_conditional` theorem is **dead code** - it has no callers and is not on any export path.

## Key Findings

### 1. Sorry Chain is Active on Completeness Path

The axiom dependency trace shows:

| Theorem | Has sorryAx? | Notes |
|---------|--------------|-------|
| `f_nesting_is_bounded` | YES | Root sorry (mathematically false) |
| `f_nesting_boundary` | YES | Depends on f_nesting_is_bounded |
| `succ_chain_forward_F` | YES | Depends on f_nesting_boundary |
| `SuccChainTemporalCoherent` | YES | Uses succ_chain_forward_F |
| `succ_chain_truth_lemma` | YES | Uses SuccChainTemporalCoherent for G/H backward |
| `succ_chain_truth_forward` | YES | Extracted from succ_chain_truth_lemma |
| `succ_chain_completeness` | YES | Uses succ_chain_truth_forward |

**Verification command**:
```bash
echo 'import Bimodal.Metalogic.Bundle.SuccChainTruth
#print axioms Bimodal.Metalogic.Bundle.succ_chain_truth_forward' > /tmp/check.lean
lake env lean /tmp/check.lean
```

**Output**:
```
'Bimodal.Metalogic.Bundle.succ_chain_truth_forward' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Lean.ofReduceBool,
 Lean.trustCompiler,
 Quot.sound]
```

### 2. Why succ_chain_truth_forward Has sorryAx

The `succ_chain_truth_lemma` is defined as a biconditional (iff) and has TWO sources of sorry:

1. **Box backward case** (line 254 in SuccChainTruth.lean):
   ```lean
   sorry -- Box backward not needed for completeness; requires modal coherence (BFMCS)
   ```

2. **G/H backward cases** (lines 266, 282):
   ```lean
   let tcf : TemporalCoherentFamily Int := SuccChainTemporalCoherent M0
   ```
   `SuccChainTemporalCoherent` depends on the sorry chain through `succ_chain_forward_F`.

Since `succ_chain_truth_forward` is defined as `.mp` of the biconditional:
```lean
theorem succ_chain_truth_forward (M0 : SerialMCS) (phi : Formula) (t : Int) :
    phi ∈ succ_chain_fam M0 t →
    truth_at succ_chain_model (succ_chain_omega M0) (succ_chain_history M0) t phi :=
  (succ_chain_truth_lemma M0 phi t).mp
```

It inherits the sorryAx dependency even though it only uses the forward direction. Lean's axiom tracking is whole-theorem based, not direction-based.

### 3. parametric_algebraic_representation_conditional is Dead Code

Search results show `parametric_algebraic_representation_conditional` appears in only 2 files:
- `ParametricRepresentation.lean` - where it is defined
- `UltrafilterChain.lean` - mentioned in comments only (as an alternative approach)

**No actual callers exist**. The theorem is dead code.

The axiom check shows it is sorry-free:
```
'Bimodal.Metalogic.Algebraic.ParametricRepresentation.parametric_algebraic_representation_conditional'
depends on axioms: [propext,Classical.choice,Lean.ofReduceBool,Lean.trustCompiler,Quot.sound]
```

This confirms it could be useful if wired, but currently it is not connected to any export path.

### 4. Other Completeness Theorems Status

| Theorem | Location | Status |
|---------|----------|--------|
| `dense_completeness_fc` | FrameConditions/Completeness.lean | Direct sorry (stub) |
| `discrete_completeness_fc` | FrameConditions/Completeness.lean | Direct sorry (stub) |
| `completeness_over_Int` | FrameConditions/Completeness.lean | Direct sorry (stub) |
| `succ_chain_completeness` | Completeness/SuccChainCompleteness.lean | Indirect sorryAx |
| `succ_chain_completeness_standard` | Completeness/SuccChainCompleteness.lean | Indirect sorryAx |

Note: SuccChainCompleteness.lean is not imported by the top-level Metalogic.lean, so it is somewhat isolated. But it still represents the "best" completeness attempt.

## Sorry-Free Components

The following components are sorry-free and usable:

1. **Soundness theorem** (`Bimodal.Metalogic.soundness`) - Complete
2. **Truth lemmas for BFMCS** (`canonical_truth_lemma`, `shifted_truth_lemma`) - Sorry-free
3. **RestrictedMCS infrastructure** (`f_nesting_is_bounded_restricted`) - Sorry-free for restricted MCS
4. **Decidability** (`decide`) - Complete

## Recommendations

### Option A: Fix succ_chain_truth_forward (Recommended)

The forward direction of the truth lemma should NOT depend on the backward direction. Refactor:

1. Define `succ_chain_truth_forward` directly (not as `.mp` of biconditional)
2. Prove only the forward cases by induction on Formula
3. This avoids the sorry chain entirely

The forward direction only needs:
- Forward_G: `G psi in MCS -> psi in MCS_s for s >= t` (uses `succ_chain_forward_G_le`)
- Forward_H: Similar pattern
- These do NOT need `SuccChainTemporalCoherent`

### Option B: Use parametric_algebraic_representation_conditional

Wire `parametric_algebraic_representation_conditional` to an actual completeness theorem:
1. Provide a concrete `construct_bfmcs` function that produces temporally coherent BFMCS
2. This would require fixing the temporal coherence construction

### Option C: Switch to RestrictedMCS Architecture

Use `f_nesting_is_bounded_restricted` instead of `f_nesting_is_bounded`:
1. RestrictedMCS are bounded by closure(phi) where phi is the target formula
2. This avoids the "unbounded F-nesting" counterexample
3. Requires restructuring the completeness proof to use RestrictedMCS

## Conclusion

The sorry chain `f_nesting_is_bounded -> f_nesting_boundary -> succ_chain_forward_F -> SuccChainTemporalCoherent` is **NOT inert**. It flows through to `succ_chain_completeness` via `succ_chain_truth_forward`.

The cleanest fix is Option A: refactor `succ_chain_truth_forward` to be defined directly rather than extracted from the biconditional. This would isolate the sorry to the backward direction (which is not needed for completeness).

## Files Analyzed

- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Completeness/SuccChainCompleteness.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/SuccChainTruth.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Algebraic/ParametricRepresentation.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/FrameConditions/Completeness.lean`
