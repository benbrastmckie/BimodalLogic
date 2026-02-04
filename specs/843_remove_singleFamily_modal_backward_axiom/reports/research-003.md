# Research Report: Task #843 - EvalBMCS Full Modal Coherence Analysis

**Task**: Remove singleFamily_modal_backward_axiom using EvalCoherentBundle
**Date**: 2026-02-04
**Focus**: Strengthening EvalBMCS for full modal coherence, alignment with task 857

## Summary

This research investigates the blocking issue in task 843: EvalBMCS only provides modal coherence at eval_family, not at all families as required for the box case of the truth lemma. We analyze three potential paths forward: (1) strengthening EvalCoherent to BoxEquivalent, (2) completeness-only approach using forward direction, and (3) alignment with task 857's temporal saturation pattern.

## Problem Statement

### Current Limitation

The implementation summary from 2026-02-04 identifies the blocking issue:

**EvalBMCS Structure**:
```
modal_forward_eval : Box phi in eval_family -> phi in ALL families
modal_backward_eval : phi in ALL families -> Box phi in eval_family
```

**BMCS Structure (required for truth lemma)**:
```
modal_forward : Box phi in ANY family -> phi in ALL families
modal_backward : phi in ALL families -> Box phi in ANY family
```

### Why This Matters for Truth Lemma

The box case of the truth lemma requires membership <-> truth at ALL families:

```lean
-- Forward (Box ψ ∈ fam.mcs t → truth of Box ψ at fam):
1. Box ψ ∈ fam.mcs t
2. By modal_forward: ψ ∈ fam'.mcs t for all fam' ∈ families
3. By IH: truth ψ at fam' for all fam'  -- REQUIRES IFF AT ALL fam'
4. By definition: truth (Box ψ) at fam

-- Backward (truth of Box ψ at fam → Box ψ ∈ fam.mcs t):
1. truth (Box ψ) at fam = ∀ fam' ∈ families, truth ψ at fam'
2. By IH: ∀ fam' ∈ families, ψ ∈ fam'.mcs t  -- REQUIRES IFF AT ALL fam'
3. By modal_backward: Box ψ ∈ fam.mcs t
```

The IH gives membership <-> truth only at the family being evaluated. For the box case at non-eval families, we need the IFF to work at those families too.

## Finding 1: EvalCoherent is Fundamentally Insufficient

### Analysis

EvalCoherent (from task 856) requires:
```lean
def EvalCoherent (families) (eval_fam) :=
  ∀ fam ∈ families, ∀ chi ∈ BoxContent eval_fam, ∀ t, chi ∈ fam.mcs t
```

This only guarantees that chi (the content of Box formulas in eval_fam) is in all families. It does NOT guarantee:
1. Box chi is in all families (only chi is)
2. Box formulas appearing in non-eval families propagate to all families

### Evidence from Code

The `eval_bmcs_truth_lemma` in TruthLemma.lean has explicit sorries documenting this:

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
      sorry  -- EvalBMCS limitation
    · -- Backward: similar issue
      sorry
```

## Finding 2: BoxEquivalent Would Be Sufficient But Impossible to Maintain

### Definition

From CoherentConstruction.lean, `BoxEquivalent` provides full modal coherence:

```lean
def BoxEquivalent (families) : Prop :=
  ∀ chi, (∃ fam ∈ families, ∃ t, Box chi ∈ fam.mcs t) →
         (∀ fam' ∈ families, ∀ t', Box chi ∈ fam'.mcs t')
```

### Why It Would Work

`BoxEquivalent` implies full BMCS modal coherence:
- `modal_forward`: Trivially follows (if Box chi in fam, then Box chi in all fam', then by T-axiom chi in all fam')
- `modal_backward`: If chi in all fam', then... **still requires an argument**

### Why It Breaks Under Witness Construction

The problem is that constructing witnesses via Lindenbaum extension can add NEW Box formulas that weren't in the original bundle. These new boxes would need to propagate to ALL existing families, which is impossible because those families are already fixed.

From the CoherentConstruction.lean documentation:
```
**Technical Gap**: The full proof requires showing that for multi-family bundles,
`{psi} ∪ UnionBoxContent` is consistent when Diamond psi is in some family.
This is documented in the research report and requires additional lemmas about
the relationship between BoxContent in different families.
```

## Finding 3: Completeness-Only Approach is Valid

### Key Insight

The completeness theorems in Completeness.lean only use the **forward direction** (`.mp`) of the truth lemma:

```lean
theorem bmcs_representation (φ : Formula) (h_cons : ContextConsistent [φ]) :
    ∃ (B : BMCS Int), bmcs_truth_at B B.eval_family 0 φ := by
  ...
  have h_in_mcs : φ ∈ B.eval_family.mcs 0 := ...
  -- Uses ONLY .mp direction
  exact (bmcs_truth_lemma B B.eval_family B.eval_family_mem 0 φ).mp h_in_mcs
```

### Why Forward Direction Works for EvalBMCS

For the forward direction at eval_family:
1. phi ∈ eval_family.mcs t
2. By IH: truth phi at eval_family

This doesn't require the IFF at other families because we're only going membership -> truth at eval_family.

### Limitation

This approach cannot prove the full bidirectional truth lemma, only the forward direction. The backward direction (truth -> membership) remains incomplete. However, for completeness purposes, this may be acceptable.

## Finding 4: Alignment with Task 857

### Task 857's Approach

Task 857 implementation-002.md describes a similar pattern for temporal operators:

```
The key finding is that the **EvalCoherentBundle pattern from Task 856** can be
directly adapted for temporal operators.
```

For temporal saturation:
- F(phi) at time t requires a witness at some s > t
- Similar to Diamond(phi) requiring a witness family

### Key Parallel

| Modal (Task 843) | Temporal (Task 857) |
|------------------|---------------------|
| Diamond(phi) requires witness family | F(phi) requires witness time |
| EvalCoherent: BoxContent(eval) in all fam | TemporalEvalCoherent: GContent(base) at all times |
| Witness contains BoxContent(eval) | Witness at s contains GContent(base) |

### Shared Constraint

Both tasks face the same fundamental issue: the saturation construction adds witnesses that may contain new Box/G formulas, and these cannot be retroactively added to existing families/times.

## Finding 5: Alternative Path via FMP Completeness

### Existing Sorry-Free Path

The file `FMP/SemanticCanonicalModel.lean` contains `semantic_weak_completeness` which is already sorry-free and doesn't use BMCS at all.

### Implication

The `singleFamily_modal_backward_axiom` is only needed for the BMCS-based completeness proof. An alternative path exists. However, this doesn't help if the goal is to clean up the BMCS approach specifically.

## Recommendations

### Recommendation 1: Accept EvalBMCS Forward-Only Truth Lemma

**Rationale**: The completeness theorems only need the forward direction. Document that `eval_bmcs_truth_lemma` provides only forward direction and is sufficient for completeness.

**Impact**: Removes the need to prove the full bidirectional truth lemma. Sorries in backward direction become documented limitations rather than blockers.

### Recommendation 2: Maintain `saturated_extension_exists` Axiom

**Rationale**: The full CoherentBundle saturation via Zorn's lemma requires proving multi-family `{psi} ∪ UnionBoxContent` consistency, which is non-trivial. The axiom captures a metatheoretic truth that can be documented and accepted as proof debt.

**Alternative**: Pursue a constructive saturation that avoids adding new Box formulas to witnesses (very constrained).

### Recommendation 3: Align with Task 857 on Eval-Only Strategy

**Rationale**: Both modal and temporal completeness can use the "eval-only" pattern where coherence/saturation is only guaranteed at the designated evaluation point.

**Implementation**:
1. Task 857 proceeds with temporal saturation at eval_family only
2. Task 843 accepts EvalBMCS with eval-only modal coherence
3. Both document that full bidirectional truth lemmas require stronger (possibly unprovable) coherence

### Recommendation 4: Characterize `singleFamily_modal_backward_axiom` as Technical Debt

**Rationale**: Per the proof-debt-policy.md, this axiom captures a metatheoretic fact about canonical models that is mathematically sound but not yet formalized. It should be classified as recoverable technical debt.

**Classification**:
```
Type: axiom (structural assumption)
Recoverable: Yes (via proving saturated_extension_exists or alternative construction)
Blocking: No (completeness theorem chain is otherwise sound)
Priority: Medium (has alternative path via FMP)
```

## Alternative Analysis: Strengthening EvalCoherent

### Would Strengthening to EvalBoxCoherent Work?

Define:
```lean
def EvalBoxCoherent (families) (eval_fam) :=
  ∀ fam ∈ families, ∀ chi, Box chi ∈ eval_fam.mcs t →
    (Box chi ∈ fam.mcs t ∧ chi ∈ fam.mcs t)
```

This would give:
- Box chi in eval_fam -> Box chi in ALL fam (stronger)
- By T-axiom: chi in ALL fam

### Problem: Witnesses Don't Satisfy This

Witnesses constructed via `constructCoherentWitness` only guarantee:
```lean
contains_boxcontent : ∀ chi ∈ BoxContent base, ∀ t, chi ∈ witness.mcs t
```

NOT:
```lean
contains_box : ∀ chi ∈ BoxContent base, ∀ t, Box chi ∈ witness.mcs t  -- False!
```

Lindenbaum extension gives an MCS containing chi, not necessarily Box chi.

### Fundamental Barrier

To have Box chi in witness, we'd need to include Box formulas in the witness seed. But then the consistency proof (`diamond_boxcontent_consistent_constant`) would need to show that `{psi} ∪ {Box chi | chi ∈ BoxContent(base)}` is consistent, which requires proving that the Box formulas are compatible with the witnessed formula psi.

## Next Steps

1. **Task 843**: Mark as blocked pending decision on approach
   - Option A: Accept EvalBMCS forward-only truth lemma as sufficient
   - Option B: Characterize axiom as acceptable proof debt
   - Option C: Pursue alternative construction (high effort, uncertain success)

2. **Task 857**: Proceed with temporal saturation using EvalCoherent pattern
   - Temporal forward direction is proven
   - Temporal backward has same structural limitations

3. **Documentation**: Update proof-debt-policy.md with `singleFamily_modal_backward_axiom` characterization

## References

- CoherentConstruction.lean - EvalBMCS, BoxEquivalent definitions
- TruthLemma.lean - Truth lemma with documented sorries
- Completeness.lean - Uses only forward direction
- specs/857_add_temporal_backward_properties/plans/implementation-002.md - Task 857 approach
- specs/843_remove_singleFamily_modal_backward_axiom/summaries/implementation-summary-20260204.md - Blocking details
- .claude/context/project/lean4/standards/proof-debt-policy.md - Debt classification

## Appendix: Technical Sketch for BoxEquivalent Saturation

For completeness, here is a sketch of what would be needed for full BoxEquivalent saturation:

1. **Modified Witness Seed**:
   ```
   WitnessSeed_Strong(psi, families) =
     {psi} ∪ BoxContent(eval) ∪ {Box chi | Box chi ∈ UnionBoxContent(families)}
   ```

2. **Consistency Proof**:
   Need to show that if Diamond(psi) ∈ eval.mcs, then WitnessSeed_Strong is consistent.
   This requires showing that psi is compatible with ALL Box formulas appearing anywhere in the bundle.

3. **Barrier**: The K-distribution argument used in `diamond_boxcontent_consistent_constant` works because we only add chi (contents of boxes), not Box chi itself. Adding Box chi to the seed requires proving that Diamond(psi) is compatible with arbitrarily many Box formulas, which is not generally true.

4. **Potential Path**: If we restrict to S5 (where Box chi -> Box Box chi), then Box chi in any family implies Box Box chi, and by T-axiom, Box chi. This circularity might allow proving that all families have the same Box formulas. However, this requires additional S5-specific axioms that may not be in the current proof system.
