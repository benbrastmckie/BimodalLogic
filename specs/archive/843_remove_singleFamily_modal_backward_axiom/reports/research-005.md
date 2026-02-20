# Research Report: Full BMCS Approach and Viable Strategies for Sorry/Axiom-Free Completeness

**Task**: 843 - remove_singleFamily_modal_backward_axiom
**Session**: sess_1770237154_e9464c
**Date**: 2026-02-04
**Focus**: Confirm Eval-Only limitations, analyze full BMCS approach, identify viable strategies for sorry/axiom-free codebase

## Executive Summary

**CRITICAL FINDING: The Eval-Only approach (EvalBMCS from Task 856) does NOT work for a sorry-free truth lemma due to a fundamental structural limitation.**

The `eval_bmcs_truth_lemma` has sorries in the box case (lines 577-600 of TruthLemma.lean) because:
1. The forward direction needs `membership -> truth` at non-eval families
2. EvalBMCS only has `modal_forward_eval` (coherence from eval to all), not full coherence
3. The IH only gives the IFF at the family being evaluated, not at other families

**The full BMCS approach remains the cleanest path** but faces its own challenge: the imp case cross-dependency prevents simple separation of forward and backward directions.

**Viable Strategies**:
1. **Mutual Recursion** (RECOMMENDED) - Prove forward and backward simultaneously with explicit mutual calls
2. **Strong Induction on Formula Size** - Access full IFF for all smaller subformulas
3. **Fully Saturated Multi-Family BMCS** - Eliminate `singleFamily_modal_backward_axiom` via proper saturation

## Analysis 1: Confirming Eval-Only Does NOT Work

### The Structural Limitation

EvalBMCS provides:
```lean
modal_forward_eval : Box phi in eval -> phi in ALL families
modal_backward_eval : phi in ALL families -> Box phi in eval
```

Full BMCS provides:
```lean
modal_forward : Box phi in ANY family -> phi in ALL families
modal_backward : phi in ALL families -> Box phi in ANY family
```

### Why the Box Case Fails for EvalBMCS Truth Lemma

From TruthLemma.lean lines 577-600:

```lean
| box ψ ih =>
    -- BOX CASE: EvalBMCS only has modal coherence at eval_family.
    simp only [eval_bmcs_truth_at]
    constructor
    · -- Forward: □ψ ∈ eval.mcs t → ∀ fam' ∈ families, truth ψ at fam'
      intro h_box fam' h_fam'
      have h_ψ_mcs : ψ ∈ fam'.mcs t := B.modal_forward_eval ψ t h_box fam' h_fam'
      -- Need: ψ ∈ fam'.mcs t → truth ψ at fam'
      -- This requires membership→truth at fam', which needs the full truth lemma at fam'.
      -- For non-eval families, we don't have this.
      sorry  -- EvalBMCS limitation
```

**The Problem**: The inductive hypothesis `ih` gives us:
```
ih : ∀ t, ψ ∈ eval_family.mcs t ↔ truth ψ at eval_family at t
```

But we need the IFF at ALL families, not just eval_family. For the forward direction:
1. We have `Box ψ ∈ eval_family.mcs t`
2. By `modal_forward_eval`: `ψ ∈ fam'.mcs t` for all families fam'
3. We need: `ψ ∈ fam'.mcs t → truth ψ at fam'` for non-eval families
4. The IH only gives this for eval_family, NOT for other families

**Conclusion**: EvalBMCS is fundamentally insufficient for a bidirectional truth lemma. The sorry is structural, not fixable without strengthening EvalBMCS to full BMCS.

## Analysis 2: The Imp Case Cross-Dependency

From research-001.md (Task 862), the imp case creates a fundamental cross-dependency:

### Forward Direction of Imp (lines 321-325)
```lean
-- Forward: (ψ → χ) ∈ MCS → (bmcs_truth ψ → bmcs_truth χ)
intro h_imp h_ψ_true
have h_ψ_mcs : ψ ∈ fam.mcs t := (ih_ψ fam hfam t).mpr h_ψ_true  -- Uses .mpr!
have h_χ_mcs : χ ∈ fam.mcs t := set_mcs_implication_property h_mcs h_imp h_ψ_mcs
exact (ih_χ fam hfam t).mp h_χ_mcs
```

**Key Observation**: The forward direction of `(ψ → χ)` uses `.mpr` (backward) on subformula ψ.

This means:
- You cannot prove forward-only by simple structural induction
- Forward and backward are mutually dependent at the imp case

### Summary of Cross-Dependencies

| Case | Forward needs | Backward needs |
|------|--------------|----------------|
| atom | nothing | nothing |
| bot | nothing | nothing |
| **imp** | **IH.mpr on ψ** | IH.mp on ψ, IH.mpr on χ |
| box | IH.mp only | IH.mpr only |
| G/H | IH.mp only | IH.mpr only |

## Analysis 3: Strategies That Can Work All The Way

### Strategy A: Mutual Recursion (RECOMMENDED)

**Approach**: Define forward and backward as mutually recursive theorems.

```lean
mutual
  theorem bmcs_truth_lemma_forward (B : BMCS D) (fam : IndexedMCSFamily D)
      (hfam : fam ∈ B.families) (t : D) (phi : Formula) :
      phi ∈ fam.mcs t → bmcs_truth_at B fam t phi := by
    induction phi generalizing fam t with
    | imp ψ χ ih_fwd_ψ ih_fwd_χ =>
        intro h_imp h_truth_ψ
        -- Explicitly call backward theorem on ψ
        have h_ψ_mcs := bmcs_truth_lemma_backward B fam hfam t ψ h_truth_ψ
        have h_χ_mcs := set_mcs_implication_property h_mcs h_imp h_ψ_mcs
        exact ih_fwd_χ fam hfam t h_χ_mcs
    | box ψ ih_fwd =>
        intro h_box fam' hfam'
        have h_ψ_mcs := B.modal_forward fam hfam ψ t h_box fam' hfam'
        exact ih_fwd fam' hfam' t h_ψ_mcs
    ...

  theorem bmcs_truth_lemma_backward (B : BMCS D) (fam : IndexedMCSFamily D)
      (hfam : fam ∈ B.families) (t : D) (phi : Formula) :
      bmcs_truth_at B fam t phi → phi ∈ fam.mcs t := by
    induction phi generalizing fam t with
    | imp ψ χ ih_bwd_ψ ih_bwd_χ =>
        intro h_truth_imp
        -- Use forward on ψ, backward on χ
        ...
    ...
end
```

**Advantages**:
1. Makes the dependency explicit
2. Each theorem has its own statement
3. Standard Lean 4 pattern for mutually dependent proofs

**Challenges**:
1. Lean 4 mutual recursion requires termination proof
2. Formula induction provides automatic termination via decreasing structure

**Mathematical Justification**: The mutual recursion terminates because both theorems are defined by structural induction on the formula, and mutual calls are always on strict subformulas.

### Strategy B: Strong Induction on Formula Size

**Approach**: Use strong induction where the IH provides BOTH directions for ALL smaller formulas.

```lean
theorem bmcs_truth_lemma (B : BMCS D) (fam : IndexedMCSFamily D) (hfam : fam ∈ B.families)
    (t : D) (phi : Formula) :
    phi ∈ fam.mcs t ↔ bmcs_truth_at B fam t phi := by
  -- Strong induction: IH gives full IFF for all strictly smaller formulas
  induction phi using Formula.strongInduction with
  | _ phi ih =>
    -- ih : ∀ ψ, ψ < phi → (ψ ∈ mcs t ↔ truth ψ)
    match phi with
    | imp ψ χ =>
        constructor
        · -- Forward
          intro h_imp h_truth_ψ
          -- ψ < (ψ → χ), so ih gives full IFF for ψ
          have h_ψ_iff := ih ψ (subformula_lt_imp_left ψ χ) fam hfam t
          have h_ψ_mcs := h_ψ_iff.mpr h_truth_ψ  -- Use .mpr on ψ
          ...
        · -- Backward uses ih similarly
          ...
```

**Requirements**:
1. Define `Formula.strongInduction` (well-founded recursion on formula size)
2. Prove subformula ordering lemmas: `subformula_lt_imp_left`, etc.
3. Ensure `<` is well-founded on formulas

**Advantages**:
1. Single theorem with IFF statement
2. Both directions available in IH
3. Clean mathematical structure

**Challenges**:
1. Requires defining formula size/complexity measure
2. Requires proving well-foundedness
3. More infrastructure than mutual recursion

### Strategy C: Fully Saturated Multi-Family BMCS (Eliminates Axiom)

**Approach**: Construct a true multi-family BMCS where `modal_backward` is PROVEN, not assumed via axiom.

The current `singleFamily_modal_backward_axiom` exists because:
1. Single-family BMCS cannot satisfy `modal_backward` (phi in MCS does not imply Box phi in MCS)
2. Multi-family requires Diamond witnesses that are box-coherent with each other

**Path to Saturation**:

1. **CoherentBundle structure** (already exists): Maintains mutual coherence via `UnionBoxContent`
2. **Saturation property**: Every neg(Box phi) has a witness family with neg(phi)
3. **The gap**: Proving `saturated_extension_exists` without axiom

**The Blocking Issue** (from research-003.md):

For multi-family bundles, adding a witness via Lindenbaum may introduce NEW Box formulas. These new boxes:
- Add to `UnionBoxContent`
- Would need to be in ALL existing families
- But existing families are already fixed

**Potential Resolution**: **BoxEquivalent** (from CoherentConstruction.lean):

```lean
def BoxEquivalent (families) : Prop :=
  ∀ chi, (∃ fam ∈ families, ∃ t, Box chi ∈ fam.mcs t) →
         (∀ fam' ∈ families, ∀ t', Box chi ∈ fam'.mcs t')
```

If all families share the SAME Box formulas, then new witnesses don't break coherence. This requires:
1. All families built from the same seed (same Box content)
2. Witnesses constructed to preserve Box equivalence

**Mathematical Foundation**: In S5, if Box chi is true anywhere, it's true everywhere (Euclidean property). A fully S5-saturated canonical model has this property by construction.

## Analysis 4: Temporal Backward Cases

The `all_future` and `all_past` backward cases have sorries for the same reason as modal backward:

```lean
| all_future ψ ih =>
    ...
    · -- Backward: (∀ s ≥ t, truth ψ at s) → G ψ ∈ MCS
      -- Requires temporal saturation: F(neg ψ) has a witness time
      intro _h_all
      sorry
```

**Would They Be Resolved by the Same Approach?**

**Yes, for Strategy A and B**: Mutual recursion or strong induction handles temporal cases identically to modal cases. The forward direction is already proven; backward only needs the IH backward direction.

**For Strategy C**: Temporal saturation is a separate concern from modal saturation:
- Modal saturation: Diamond witnesses (families with neg phi)
- Temporal saturation: F-witnesses (times with neg phi)

Task 857 addresses temporal saturation via `TemporalCoherentConstruction.lean`. The pattern parallels modal saturation:
- neg(G phi) → F(neg phi) via `G_dne_theorem` (temporal analog of `box_dne_theorem`)
- F-saturation provides witness times
- Temporal backward follows by contraposition

## Analysis 5: Impact on Completeness

**Current State**: The completeness theorems in Completeness.lean are SORRY-FREE because:
1. They only use `.mp` (forward direction) of `bmcs_truth_lemma`
2. Forward direction is fully proven for all cases
3. The backward sorries don't propagate to completeness

**With Fully Proven Truth Lemma**: Both directions proven → completeness remains sorry-free → additional benefits:
- Can prove additional semantic properties
- Full bidirectional truth correspondence
- Mathematically cleaner

**Axiom Status**: `singleFamily_modal_backward_axiom` is used in `singleFamilyBMCS` (Construction.lean line 264). Eliminating it requires either:
1. Not using `singleFamilyBMCS` (use `CoherentBundle.toBMCS` instead)
2. Proving `saturated_extension_exists` (removing that axiom)

## Recommendations

### Primary Recommendation: Mutual Recursion (Strategy A)

**Implementation Plan**:
1. Create `TruthLemmaForward.lean` and `TruthLemmaBackward.lean` with mutual block
2. Use structural induction with explicit calls to the other lemma
3. Temporal cases: forward is proven; backward uses the IH backward
4. Update `Completeness.lean` to use forward theorem directly
5. Keep original IFF theorem as derived from forward + backward

**Why Mutual Recursion Over Strong Induction**:
- Less infrastructure (no formula size ordering needed)
- More explicit about the dependency structure
- Standard Lean 4 pattern

### Secondary Recommendation: Resolve `saturated_extension_exists`

**Long-term Path**:
1. Define `BoxEquivalent` bundle property (already in CoherentConstruction.lean)
2. Construct witnesses that preserve BoxEquivalent
3. Use Zorn's lemma on BoxEquivalent bundles
4. Prove maximality implies saturation

This would eliminate:
- `saturated_extension_exists` axiom
- `singleFamily_modal_backward_axiom` (no longer needed with proper BMCS)

### Alternative Path: Accept FMP Completeness as Primary

The `fmp_weak_completeness` theorem in `SemanticCanonicalModel.lean` is **sorry-free** and provides an alternative completeness proof. If eliminating axioms in the BMCS path proves difficult, this provides a clean fallback.

## Summary of Viable Strategies

| Strategy | Sorry-Free? | Axiom-Free? | Effort | Mathematical Elegance |
|----------|-------------|-------------|--------|----------------------|
| **Mutual Recursion** | Yes (both dirs) | No (uses BMCS) | Medium | High |
| **Strong Induction** | Yes (both dirs) | No (uses BMCS) | Medium-High | High |
| **Full Saturation** | Yes | Yes | High | Highest |
| **FMP Path** | Yes | N/A (different structure) | Already done | Good (different approach) |

## Conclusion

1. **Eval-Only does NOT work** - confirmed. The structural limitation is fundamental.

2. **Full BMCS approach is cleanest** - requires handling the imp case cross-dependency via mutual recursion or strong induction.

3. **Both directions provable** - the cross-dependency is not a logical impossibility, just requires the right proof structure.

4. **Temporal backward** - follows the same pattern; no additional obstacles beyond modal backward.

5. **Axiom elimination** - possible via full saturation construction but requires significant infrastructure.

**Recommended Path**: Implement mutual recursion (Strategy A) for immediate sorry reduction, then pursue full saturation (Strategy C) for axiom elimination as a separate task.

## References

- `TruthLemma.lean` - Current truth lemma with sorries in temporal backward
- `CoherentConstruction.lean` - EvalBMCS, BoxEquivalent definitions, eval_saturated_bundle_exists theorem
- `Construction.lean` - singleFamily_modal_backward_axiom
- `BMCS.lean` - BMCS structure with modal_forward and modal_backward fields
- `Completeness.lean` - Uses only .mp of truth lemma (already sorry-free)
- `SemanticCanonicalModel.lean` - Alternative sorry-free completeness path
- `specs/862_divide_truthlemma_forward_backward/reports/research-001.md` - Cross-dependency analysis
- `.claude/context/project/lean4/standards/proof-debt-policy.md` - Proof debt characterization
