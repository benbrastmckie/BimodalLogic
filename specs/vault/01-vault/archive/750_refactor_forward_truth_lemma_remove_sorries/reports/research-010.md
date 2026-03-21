# Research Report: Task #750 - Sorry Feasibility and Cleanup Strategy

**Task**: Refactor forward Truth Lemma - Remove sorries
**Date**: 2026-01-29
**Focus**: Assessing the 1 sorry in `valid_implies_semantic_truth`, evaluating fixability, and recommending cleanup of supporting code

## Executive Summary

The single sorry in `valid_implies_semantic_truth` (SemanticCanonicalModel.lean, line 684) is **fundamentally blocked** by architectural constraints, not by missing lemmas. The sorry represents a known gap between:

1. **Universal validity** (`valid phi`): truth in ALL models, evaluated recursively
2. **Assignment-based truth** (`semantic_truth_at_v2`): checking boolean values in a FiniteWorldState

For this bridge to work, arbitrary `FiniteWorldState` assignments would need to match recursive truth evaluation - but `IsLocallyConsistent` only enforces modus ponens direction, not full propositional closure. MCS-derived states have this property; arbitrary states do not.

**Recommendation**: Accept that the sorry cannot be fixed with reasonable effort. Instead:
1. Keep `semantic_weak_completeness` as the primary sorry-free completeness result
2. Archive/remove dead-end attempts (AlgebraicSemanticBridge.lean, HybridCompleteness.lean)
3. Document the gap clearly for future reference

## The Sorry Analysis

### Location and Context

```lean
-- File: Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean
-- Line: 684

theorem truth_at_implies_semantic_truth (phi : Formula)
    (tau : WorldHistory (SemanticCanonicalFrame phi)) (ht : tau.domain 0)
    (h_truth : truth_at (SemanticCanonicalModel phi) tau 0 phi) :
    semantic_truth_at_v2 phi (tau.states 0 ht)
      (BoundedTime.origin (temporalBound phi)) phi := by
  sorry
```

### What the Sorry Needs to Prove

Given:
- `tau`: A world history in the SemanticCanonicalFrame
- `h_truth`: The formula `phi` is recursively true via `truth_at` at position 0

Prove:
- `semantic_truth_at_v2 phi (tau.states 0 ht) origin phi`
- Which reduces to: the FiniteWorldState's boolean assignment at `phi` equals `true`

### Why It Cannot Be Fixed

The fundamental gap is in the definition of `IsLocallyConsistent`:

```lean
-- IsLocallyConsistent only enforces these properties:
def IsLocallyConsistent (phi : Formula) (v : FiniteTruthAssignment phi) : Prop :=
  -- 1. Bot is false
  (forall h : Formula.bot in closure phi, v bot h = false) and
  -- 2. Modus ponens: imp=true AND psi=true -> chi=true
  (forall psi chi : Formula, imp in closure -> psi in closure -> chi in closure ->
    v imp = true -> v psi = true -> v chi = true) and
  -- 3. T-axiom: box=true -> psi=true
  (forall psi : Formula, box psi in closure -> psi in closure ->
    v (box psi) = true -> v psi = true)
```

**Critical observation**: For implication, local consistency only gives:
- IF `psi -> chi = true` AND `psi = true`, THEN `chi = true`

But proving `truth_at_implies_semantic_truth` requires the CONVERSE:
- IF `(truth_at psi -> truth_at chi)`, THEN `assignment(psi -> chi) = true`

This converse does NOT hold for arbitrary locally consistent assignments. An assignment could have:
- `psi = false`, `chi = false`, `psi -> chi = false`

This is locally consistent (modus ponens condition is vacuously satisfied when premises are false), but doesn't match recursive truth evaluation where `psi -> chi` would be true whenever `psi` is false.

### MCS-Derived States Are Different

For states built from ClosureMaximalConsistent sets, we have `closure_mcs_imp_iff`:
```lean
(psi -> chi) in S <-> (psi in S -> chi in S)
```

This gives BOTH directions. But `SemanticWorldState` can wrap ANY `FiniteWorldState`, not just MCS-derived ones.

### The Box Problem (Even Worse)

For `box psi`:
- `truth_at` quantifies over ALL world histories in the frame
- The FiniteWorldState assignment for `box psi` is just a boolean value

There's no general way to prove that an arbitrary boolean assignment reflects truth under universal quantification over histories.

## Difficulty Assessment

| Approach | Difficulty | Feasibility |
|----------|------------|-------------|
| Fix with additional lemmas | Very Hard | Not feasible - architectural mismatch |
| Strengthen IsLocallyConsistent | Hard | Would require redefining FiniteWorldState |
| Restrict to MCS-derived states | Medium | Would change theorem statement significantly |
| Alternative proof structure | Very Hard | Would need different completeness strategy |

**Verdict**: The sorry is architecturally blocked. Fixing it would require either:
1. Changing the definition of `FiniteWorldState` (breaking change)
2. Changing the theorem to only apply to MCS-derived states (different theorem)
3. Finding a completely different proof strategy (significant research)

## Code Audit: What Should Be Kept vs Removed

### Essential Sorry-Free Results (KEEP)

| File | Component | Status | Why Keep |
|------|-----------|--------|----------|
| `AlgebraicRepresentation.lean` | `algebraic_representation_theorem` | Sorry-free | Core algebraic result |
| `UltrafilterMCS.lean` | All definitions + `ultrafilterToSet_mcs` | Sorry-free | MCS-ultrafilter bijection |
| `SemanticCanonicalModel.lean` | `semantic_weak_completeness` | Sorry-free | Primary completeness result |
| `FMP/Closure.lean` | All | Sorry-free | Closure infrastructure |
| `FMP/FiniteWorldState.lean` | All | Sorry-free | Core FMP types |

### Supporting Infrastructure with Sorries (EVALUATE)

| File | Component | Sorries | Recommendation |
|------|-----------|---------|----------------|
| `SemanticCanonicalModel.lean` | `truth_at_implies_semantic_truth` | 1 | Keep with clear docstring explaining the gap |
| `SemanticCanonicalModel.lean` | `sorry_free_weak_completeness` | Uses above | Keep as aspirational API |
| `SemanticCanonicalModel.lean` | `compositionality` sorry | 1 | Keep with docstring - known FMP limitation |
| `HybridCompleteness.lean` | `hybrid_weak_completeness` | Uses `valid_implies_semantic_truth` | See below |

### Dead-End Artifacts (RECOMMEND REMOVAL)

| File | Component | Sorries | Why Remove |
|------|-----------|---------|------------|
| `AlgebraicSemanticBridge.lean` | Full file | ~10 (box/temporal cases) | v003 approach failed; propositional fragment only |
| `HybridCompleteness.lean` | Full file | 1 (inherited) | v004 approach didn't eliminate the core sorry |

## Detailed Recommendations

### 1. AlgebraicSemanticBridge.lean: MOVE TO BONEYARD

**Rationale**: This was the v003 attempt to prove `algTrueAt U phi <-> truth_at algModel phi`. It has ~10 sorries in modal and temporal cases. The approach is fundamentally blocked because:
- Box semantics quantify over ALL histories
- A single ultrafilter cannot witness universal truth
- Temporal cases require time structure that ultrafilters don't have

**Action**: Move to `Theories/Bimodal/Boneyard/Algebraic/AlgebraicSemanticBridge.lean` with header comment explaining why it was abandoned.

### 2. HybridCompleteness.lean: MOVE TO BONEYARD

**Rationale**: The v004 "hybrid approach" was designed to bypass the AlgebraicSemanticBridge problem by going ultrafilter -> MCS -> FMP. However, the approach still requires `valid_implies_semantic_truth` at the final step, which has the same architectural gap.

The theorems `alg_consistent_to_mcs` and `not_provable_to_mcs_neg` ARE sorry-free and could be useful, but they don't lead to a sorry-free `valid phi -> derives phi`.

**Action**: Move to `Theories/Bimodal/Boneyard/Algebraic/HybridCompleteness.lean`. Extract the useful lemmas (`alg_consistent_to_mcs`, `not_provable_to_mcs_neg`) to a smaller utility file if needed.

### 3. SemanticCanonicalModel.lean: UPDATE DOCUMENTATION

**Keep**: The file contains the essential sorry-free `semantic_weak_completeness`. The sorry in `truth_at_implies_semantic_truth` should remain but with enhanced documentation.

**Add docstring at line 652**:
```lean
/-!
### KNOWN ARCHITECTURAL GAP

The `truth_at_implies_semantic_truth` theorem has a sorry that represents a fundamental
architectural limitation, NOT a missing lemma.

**The Problem**: `IsLocallyConsistent` only enforces modus ponens direction for implications,
but proving this theorem requires full propositional closure. MCS-derived states have this
property; arbitrary FiniteWorldStates do not.

**Implication**: `sorry_free_weak_completeness` (valid phi -> derives phi) cannot be proven
without architectural changes. Use `semantic_weak_completeness` instead - it provides
completeness for `finite_valid` (truth in all SemanticWorldStates), which is a checkable
property.

**Not Fixable By**: Adding more lemmas, completing other proofs, or filling dependencies.
Would require either:
1. Redefining FiniteWorldState to only allow MCS-derived states
2. Strengthening IsLocallyConsistent (breaking change)
3. Different proof architecture entirely
-/
```

### 4. Update Algebraic/Algebraic.lean Imports

Remove imports of AlgebraicSemanticBridge and HybridCompleteness after moving to Boneyard.

### 5. Update Algebraic/README.md

Document that the algebraic path provides:
- Sorry-free `algebraic_representation_theorem`
- Sorry-free MCS-ultrafilter correspondence
- BUT NOT a bridge to Kripke semantics validity

## Summary: Relating to Incomplete Work

The user asked: "how should I relate to the work that was otherwise implemented if the sorry cannot be fixed? I don't want to fill the codebase with proofs that support ambitions that didn't work out."

**Answer**:

1. **The core results ARE useful**:
   - `algebraic_representation_theorem`: algebraic consistency <-> algebraic satisfiability
   - `semantic_weak_completeness`: finite validity -> derivability
   - MCS-ultrafilter correspondence

2. **The failed bridges should be moved to Boneyard**:
   - AlgebraicSemanticBridge.lean (v003)
   - HybridCompleteness.lean (v004)

3. **The aspirational sorry should be documented**:
   - Keep `truth_at_implies_semantic_truth` and `sorry_free_weak_completeness` with clear documentation
   - They serve as signposts for what WOULD be needed for full `valid -> derivable`
   - Future work on alternative architectures could reference them

4. **Categorization**:

| Category | Files | Action |
|----------|-------|--------|
| Essential sorry-free | AlgebraicRepresentation, UltrafilterMCS, semantic_weak_completeness | KEEP |
| Failed approach | AlgebraicSemanticBridge, HybridCompleteness | MOVE TO BONEYARD |
| Documented gap | truth_at_implies_semantic_truth | KEEP WITH DOCS |
| Future work | sorry_free_weak_completeness | KEEP AS ASPIRATIONAL |

## Next Steps

1. Move AlgebraicSemanticBridge.lean to Boneyard
2. Move HybridCompleteness.lean to Boneyard
3. Update Algebraic/Algebraic.lean imports
4. Add architectural gap documentation to SemanticCanonicalModel.lean
5. Update Algebraic/README.md with honest assessment
6. Mark task 750 as PARTIAL or COMPLETED with this cleanup as the deliverable

## References

- `Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean` - Primary file with sorry
- `Theories/Bimodal/Metalogic/FMP/FiniteWorldState.lean` - IsLocallyConsistent definition
- `Theories/Bimodal/Metalogic/Algebraic/AlgebraicSemanticBridge.lean` - v003 failed approach
- `Theories/Bimodal/Metalogic/Algebraic/HybridCompleteness.lean` - v004 failed approach
- `specs/750_refactor_forward_truth_lemma_remove_sorries/plans/implementation-004.md` - v004 plan
- `specs/750_refactor_forward_truth_lemma_remove_sorries/reports/research-009.md` - Comparative analysis
