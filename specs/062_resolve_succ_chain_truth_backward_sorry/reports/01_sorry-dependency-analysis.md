# Sorry Dependency Analysis: succ_chain_truth_lemma

**Task**: 62 - Resolve backward Box sorry in succ_chain_truth_lemma
**Session**: sess_1774414248_6d7f52
**Date**: 2026-03-24

## Executive Summary

The documentation claiming `succ_chain_truth_forward` is sorry-free is **incorrect**. The forward direction structurally depends on the backward direction through the Imp case, and both theorems inherit `sorryAx` from the Box backward case.

## Key Findings

### 1. lean_verify Discrepancy (Bug)

The `lean_verify` MCP tool returns incorrect results:

```
lean_verify(succ_chain_truth_lemma) -> axioms: []
lean_verify(succ_chain_truth_forward) -> axioms: []
```

But `#print axioms` shows both depend on `sorryAx`:

```lean
'Bimodal.Metalogic.Bundle.succ_chain_truth_lemma' depends on axioms: [propext,
 sorryAx, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound]

'Bimodal.Metalogic.Bundle.succ_chain_truth_forward' depends on axioms: [propext,
 sorryAx, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound]
```

**Root cause**: The `lean_verify` tool may not properly trace axiom dependencies through fully qualified names or namespace resolution.

### 2. Structural Dependency Analysis

**Forward Imp case (lines 189-197)**:
```lean
intro h_imp h_psi_true
have h_psi_mcs : psi ∈ succ_chain_fam M0 t := (ih_psi t).mpr h_psi_true  -- BACKWARD IH!
have h_chi_mcs := SetMaximalConsistent.implication_property h_mcs h_imp h_psi_mcs
exact (ih_chi t).mp h_chi_mcs
```

The forward direction of Imp **requires** the backward direction of its sub-formulas to:
1. Convert `truth(psi)` to `psi in MCS` via backward IH
2. Apply modus ponens to get `chi in MCS`
3. Convert to `truth(chi)` via forward IH

This is **not** a proof deficiency but a **structural necessity** of the biconditional induction approach.

### 3. Why Forward-Only Induction Fails

Attempted alternative: Use MCS maximality `psi in MCS or psi.neg in MCS` instead of backward IH.

**Problem**: `psi.neg = psi.imp bot` is NOT a subformula of `psi.imp chi`, so forward IH on `psi.neg` is not available in structural induction.

A forward-only proof would require:
- Well-founded induction on `closureWithNeg(phi)`
- Or proving forward for an expanded closure including negations

### 4. Sorry Sources in Truth Lemma

| Location | Case | Status | Impact |
|----------|------|--------|--------|
| Line 254 | Box backward | `sorry` | Direct sorry |
| Lines 266-270 | G backward | Uses `SuccChainTemporalCoherent` | Inherited sorry |
| Lines 282-286 | H backward | Uses `SuccChainTemporalCoherent` | Inherited sorry |

**SuccChainTemporalCoherent dependencies** (also have sorryAx):
- `succ_chain_forward_F` - sorry from `f_nesting_is_bounded`
- `succ_chain_backward_P` - sorry from `p_nesting_is_bounded`

### 5. Box Backward Is Unprovable

The Box backward case requires proving:
```
psi in MCS t -> Box(psi) in MCS t
```

**This is mathematically impossible** for S5 modal logic:
- The T-axiom gives `Box(psi) -> psi` (forward direction)
- There is NO axiom giving `psi -> Box(psi)` (that would collapse modality)
- The sorry is a correct placeholder for an unprovable goal

### 6. Completeness Impact

**Completeness uses** `succ_chain_truth_forward` at line 154 of SuccChainCompleteness.lean:
```lean
have h_neg_true := succ_chain_truth_forward M0 phi.neg 0 h_neg_in_fam
```

For formulas `phi` containing Box, `phi.neg = phi.imp bot` triggers:
1. Forward Imp case
2. Which calls backward IH on `phi`
3. Which encounters Box backward sorry

**Result**: The completeness theorem also depends on `sorryAx`.

### 7. Misleading Documentation (Lines 293-305)

The documentation claims:
> This theorem is **sorry-free**: `#print axioms succ_chain_truth_forward` shows no `sorryAx`

This is **factually incorrect** and must be corrected.

## Recommendations

### Option A: Correct Documentation (Minimal)

1. Remove the false claim that `succ_chain_truth_forward` is sorry-free
2. Document that forward structurally depends on backward
3. Document that the sorry chain affects completeness

### Option B: Prove Forward Independently (Major Refactor)

1. Define well-founded measure on `closureWithNeg(phi)`
2. Prove forward for all formulas in closure simultaneously
3. Use MCS maximality to handle Imp case without backward IH
4. Avoid Box backward entirely by proving only forward

**Estimated complexity**: High - requires restructuring the entire truth lemma proof

### Option C: Restrict to Box-Free Fragments (Alternative)

1. Define `BoxFree : Formula -> Prop`
2. Prove `succ_chain_truth_lemma_box_free` for box-free formulas (sorry-free)
3. Document that full completeness requires the sorry

## Files to Modify

| File | Change |
|------|--------|
| `SuccChainTruth.lean:293-305` | Remove incorrect "sorry-free" claim |
| `SuccChainTruth.lean:31-35` | Update design documentation |
| `SuccChainCompleteness.lean:33-34` | Correct axiom dependency documentation |

## Conclusion

The backward direction cannot be eliminated from the current proof structure. The sorry is:
1. **Mathematically necessary** for Box backward (unprovable goal)
2. **Structurally entangled** with forward through Imp case
3. **Propagating to completeness** via the truth lemma

The documentation falsely claiming sorry-free status must be corrected. A sorry-free forward proof would require significant restructuring using well-founded induction on an expanded closure.
