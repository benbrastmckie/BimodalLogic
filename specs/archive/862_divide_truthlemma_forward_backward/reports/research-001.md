# Research Report: TruthLemma Forward/Backward Separation

**Task**: 862 - divide_truthlemma_forward_backward
**Session**: sess_1770235839_05082b
**Date**: 2026-02-04
**Focus**: Investigate separating bmcs_truth_lemma into forward and backward components to achieve sorry-free forward direction

## Executive Summary

**CRITICAL FINDING: The imp case creates a fundamental cross-dependency that prevents simple separation.**

The forward direction of the implication case (`(psi -> chi) in MCS -> (truth psi -> truth chi)`) requires the **backward** IH on psi (line 323: `ih_psi.mpr`). This means a standalone forward lemma cannot be proven by simple structural induction without the backward direction.

**However, there are viable paths forward**:
1. **Mutual recursion** - Define forward and backward together as separate theorems
2. **Strong induction** - Use formula size/structure to access both directions of subformulas
3. **Stratified approach** - Prove backward first for imp-free formulas, then extend

## Current Truth Lemma Analysis

### Statement (TruthLemma.lean:298-300)
```lean
theorem bmcs_truth_lemma (B : BMCS D) (fam : IndexedMCSFamily D) (hfam : fam ∈ B.families)
    (t : D) (phi : Formula) :
    phi in fam.mcs t <-> bmcs_truth_at B fam t phi
```

### Cross-Dependency Analysis by Case

| Case | Forward (.mp) Direction | Backward (.mpr) Direction | Cross-Dependency |
|------|-------------------------|---------------------------|------------------|
| atom | trivial by definition | trivial by definition | NONE |
| bot | MCS consistency | ex falso | NONE |
| **imp** | **Uses ih_psi.mpr** | Uses ih_psi.mp, ih_chi.mpr | **PROBLEMATIC** |
| box | Uses ih.mp | Uses ih.mpr | Clean separation |
| G (all_future) | Uses ih.mp | sorry (temporal saturation) | Clean separation |
| H (all_past) | Uses ih.mp | sorry (temporal saturation) | Clean separation |

### The Imp Case Problem

From TruthLemma.lean lines 321-325:
```lean
-- Forward: (psi -> chi) in MCS -> (bmcs_truth psi -> bmcs_truth chi)
intro h_imp h_psi_true
have h_psi_mcs : psi in fam.mcs t := (ih_psi fam hfam t).mpr h_psi_true  -- Uses .mpr!
have h_chi_mcs : chi in fam.mcs t := set_mcs_implication_property h_mcs h_imp h_psi_mcs
exact (ih_chi fam hfam t).mp h_chi_mcs
```

**Why this happens**: To apply modus ponens (`set_mcs_implication_property`), we need `psi in MCS`. We're given `bmcs_truth psi` via `h_psi_true`. To convert truth to membership, we need `.mpr` (backward direction) on the subformula psi.

## Proposed Solutions

### Option 1: Mutual Recursion (RECOMMENDED)

Define both forward and backward as separate theorems, but prove them simultaneously using mutual recursion:

```lean
mutual
  theorem bmcs_truth_lemma_forward (B : BMCS D) (fam : IndexedMCSFamily D) (hfam : fam in B.families)
      (t : D) (phi : Formula) :
      phi in fam.mcs t -> bmcs_truth_at B fam t phi := by
    induction phi generalizing fam t with
    | imp psi chi ih_fwd_psi ih_fwd_chi =>
        intro h_imp h_truth_psi
        -- Use bmcs_truth_lemma_backward on psi
        have h_psi_mcs := bmcs_truth_lemma_backward B fam hfam t psi h_truth_psi
        have h_chi_mcs := set_mcs_implication_property h_mcs h_imp h_psi_mcs
        exact ih_fwd_chi fam hfam t h_chi_mcs
    ...

  theorem bmcs_truth_lemma_backward (B : BMCS D) (fam : IndexedMCSFamily D) (hfam : fam in B.families)
      (t : D) (phi : Formula) :
      bmcs_truth_at B fam t phi -> phi in fam.mcs t := by
    induction phi generalizing fam t with
    ...
end
```

**Advantage**: Explicit separation - each theorem has its own statement and can be referenced independently.

**Challenge**: Lean 4's mutual recursion for theorems requires careful termination checking.

### Option 2: Strong Induction on Formula Size

Use strong induction where the IH gives you BOTH directions for ALL smaller formulas:

```lean
theorem bmcs_truth_lemma_forward (B : BMCS D) (fam : IndexedMCSFamily D) (hfam : fam in B.families)
    (t : D) (phi : Formula) :
    phi in fam.mcs t -> bmcs_truth_at B fam t phi := by
  induction phi using Formula.strongInduction with
  | _ phi ih =>
    -- ih gives: for all psi < phi, psi in MCS <-> bmcs_truth psi
    match phi with
    | imp psi chi =>
        intro h_imp h_truth_psi
        -- ih on psi (which is smaller than imp psi chi) gives full IFF
        have h_psi_iff := ih psi (subformula_lt_imp_left psi chi)
        have h_psi_mcs := h_psi_iff.mpr h_truth_psi
        ...
```

**Advantage**: Can use both directions of IH on subformulas while proving only forward.

**Challenge**: Requires defining `Formula.strongInduction` and proving subformula orderings.

### Option 3: Archive Backward Direction Only for Temporal

Since the only sorries are in temporal backward (G, H), and the imp backward is proven, we could:

1. Keep the full IFF lemma (needed for imp case)
2. Archive the temporal backward parts to Boneyard/
3. Document that completeness only uses forward

**Current Status**: This is essentially already the case - the sorries are isolated to temporal backward, and completeness only uses `.mp`.

## Impact on Completeness

### How Completeness Uses Truth Lemma

From Completeness.lean:105-108:
```lean
theorem bmcs_representation (phi : Formula) (h_cons : ContextConsistent [phi]) :
    exists (B : BMCS Int), bmcs_truth_at B B.eval_family 0 phi := by
  ...
  exact (bmcs_truth_lemma B B.eval_family B.eval_family_mem 0 phi).mp h_in_mcs
```

**All uses are `.mp` (forward direction)**. The completeness proof never needs backward.

### Changes If Separated

If we create separate `bmcs_truth_lemma_forward` and `bmcs_truth_lemma_backward`:
- Completeness.lean changes: `.mp` -> direct call to forward lemma
- No functional change - just clearer intent
- The backward lemma can be archived or kept as technical infrastructure

## EvalBMCS Consideration

The EvalBMCS structure in CoherentConstruction.lean provides an alternative path:

```lean
theorem eval_bmcs_truth_lemma (B : EvalBMCS D) (t : D) (phi : Formula) :
    phi in B.eval_family.mcs t <-> eval_bmcs_truth_at B.families B.eval_family t phi
```

This has **additional sorries** in the box case because EvalBMCS only guarantees modal coherence at the eval_family. The full BMCS approach remains the cleanest.

## Theorem Signatures for Separated Lemmas

### Forward Lemma (Primary - Used by Completeness)
```lean
theorem bmcs_truth_lemma_forward (B : BMCS D) (fam : IndexedMCSFamily D)
    (hfam : fam in B.families) (t : D) (phi : Formula) :
    phi in fam.mcs t -> bmcs_truth_at B fam t phi
```

### Backward Lemma (Secondary - Technical Infrastructure)
```lean
theorem bmcs_truth_lemma_backward (B : BMCS D) (fam : IndexedMCSFamily D)
    (hfam : fam in B.families) (t : D) (phi : Formula) :
    bmcs_truth_at B fam t phi -> phi in fam.mcs t
```

The backward lemma would have sorries for temporal operators (G, H) and could be archived to `Boneyard/TruthLemmaBackward.lean`.

## Files Requiring Modification

| File | Change |
|------|--------|
| `TruthLemma.lean` | Split into forward/backward or use mutual recursion |
| `Completeness.lean` | Update `.mp` calls to use forward lemma directly |
| `Boneyard/` | Archive backward lemma with temporal sorries |

## Recommendation

**Implement Option 1 (Mutual Recursion)** with the following steps:

1. **Create `TruthLemmaForward.lean`** with forward-only theorem using mutual recursion
2. **Create `TruthLemmaBackward.lean`** with backward theorem (same mutual recursion)
3. **Archive temporal backward to Boneyard/** (the parts with sorries)
4. **Update Completeness.lean** to use the forward-only theorem
5. **Keep original `bmcs_truth_lemma`** as derived lemma (combines forward and backward)

This achieves:
- Sorry-free forward direction (the goal)
- Clear separation of concerns
- Backward direction preserved for potential future use
- Minimal changes to existing completeness proof

## Risks and Mitigations

| Risk | Mitigation |
|------|------------|
| Lean 4 mutual recursion complexity | Use `mutual` blocks with explicit termination proofs |
| Breaking existing proofs | Keep `bmcs_truth_lemma` as wrapper combining both |
| Temporal backward as tech debt | Document explicitly, track in proof-debt-policy.md |

## Conclusion

**The separation IS achievable** through mutual recursion, but requires acknowledging that forward and backward directions are not independently provable by simple induction due to the imp case cross-dependency. The mutual recursion approach makes the separation explicit while preserving the proof structure.

The key insight is that the current completeness theorems are already **functionally sorry-free** because they only use `.mp`. The separation would make this architectural property explicit and allow the temporal backward sorries to be cleanly archived.

## References

- `specs/843_remove_singleFamily_modal_backward_axiom/reports/research-004.md` - Prior analysis of forward/backward directions
- `Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean` - Current implementation
- `Theories/Bimodal/Metalogic/Bundle/Completeness.lean` - Usage patterns
- `.claude/context/project/lean4/standards/proof-debt-policy.md` - Proof debt tracking
