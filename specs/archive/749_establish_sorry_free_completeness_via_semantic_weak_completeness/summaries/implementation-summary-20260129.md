# Implementation Summary: Task #749

**Task**: Establish sorry-free completeness via semantic_weak_completeness
**Updated**: 2026-01-29
**Status**: BLOCKED - architectural limitations in FMP construction
**Session**: sess_1769708707_3aa4c6 (v002 implementation attempt)

## Overview

This task attempted to prove `truth_at_implies_semantic_truth` (the forward truth lemma) to enable sorry-free weak completeness via structural induction. After detailed architectural analysis, the approach was found to be fundamentally blocked by limitations in the `IsLocallyConsistent` definition.

## Key Findings

### The Fundamental Gap

The `semantic_weak_completeness` theorem is fully proven (no sorries) and works via contrapositive:
- If phi is NOT provable, then {phi.neg} is consistent
- Extend to MCS, build SemanticWorldState where phi is false
- Contrapositive gives: (all SemanticWorldStates have phi true) -> provable phi

To use this for `valid phi -> provable phi`, we need the **forward truth lemma**:
- `truth_at M tau 0 phi -> semantic_truth_at_v2 phi (tau.states 0 ht) t phi`

### Architectural Analysis (v002 Findings)

**Root Cause**: The `IsLocallyConsistent` definition (FiniteWorldState.lean:88-104) only captures SOUNDNESS properties, not COMPLETENESS properties.

**Available Properties**:
1. Bot is false: `∀ h : ⊥ ∈ closure φ, v ⟨⊥, h⟩ = false` ✓
2. Modus ponens: `v (ψ → χ) = true → v ψ = true → v χ = true` ✓
3. T-axiom for box: `v (□ψ) = true → v ψ = true` ✓

**Missing Properties for Biconditional Truth Correspondence**:
- Negation completeness: `v ψ = true ∨ v (¬ψ) = true` ✗
- Implication converse: `(v ψ = false ∨ v χ = true) → v (ψ → χ) = true` ✗
- Temporal T-axioms: `v (Gψ) = true → v ψ = true` ✗

**Why Mutual Induction Fails**: The forward implication case requires the backward IH (to handle the "antecedent false" case), but the backward direction requires negation completeness, which is only available for MCS-derived states.

### Blocking Analysis by Constructor

| Constructor | Status | Reason |
|-------------|--------|--------|
| atom | ✓ PROVEN | `semantic_valuation` directly uses `models` |
| bot | ✓ PROVEN | Bot is always false in both notions |
| imp | BLOCKED | Requires negation completeness for mutual induction |
| box | BLOCKED | Box quantifies over ALL histories (architectural) |
| all_past | BLOCKED | Requires temporal coherence (MCS family property) |
| all_future | BLOCKED | Requires temporal coherence (MCS family property) |

## v002 Implementation Attempt

### Analysis Performed
1. Reviewed `IsLocallyConsistent` definition in FiniteWorldState.lean
2. Analyzed mutual induction approach from Representation/TruthLemma.lean
3. Identified why the same issues apply to FMP architecture
4. Updated docstring for `truth_at_implies_semantic_truth` with detailed explanation

### Docstring Update (SemanticCanonicalModel.lean:609-653)
Added comprehensive architectural analysis explaining:
- Why base cases (atom, bot) work
- Why compound cases (imp, box, temporal) are blocked
- Comparison with Representation/TruthLemma.lean sorries
- Resolution options for future work

### Plan Update (implementation-002.md)
Updated all 6 phases with:
- BLOCKED status where applicable
- Detailed reasoning for each blocking issue
- References to parallel issues in TruthLemma.lean

## Phase Status

| Phase | Status | Description |
|-------|--------|-------------|
| 1 | BLOCKED | IsLocallyConsistent lacks negation completeness |
| 2 | BLOCKED | Imp case requires mutual induction |
| 3 | BLOCKED | Box collapse claim is incorrect |
| 4 | BLOCKED | Temporal requires MCS family coherence |
| 5 | BLOCKED | Depends on phases 1-4 |
| 6 | IN PROGRESS | Documentation updates |

## The Sorry

```lean
theorem truth_at_implies_semantic_truth (phi : Formula)
    (tau : WorldHistory (SemanticCanonicalFrame phi)) (ht : tau.domain 0)
    (h_truth : truth_at (SemanticCanonicalModel phi) tau 0 phi) :
    semantic_truth_at_v2 phi (tau.states 0 ht) ... phi := by
  -- ARCHITECTURAL GAP: IsLocallyConsistent is insufficient
  -- See docstring for detailed analysis
  sorry
```

### Parallel Sorries (Same Root Cause)
- TruthLemma.lean:366 (box forward) - box quantifies over all histories
- TruthLemma.lean:389 (box backward) - same issue
- TruthLemma.lean:416 (H backward) - omega-rule limitation
- TruthLemma.lean:438 (G backward) - omega-rule limitation

## Verification

```bash
lake build Bimodal.Metalogic.FMP.SemanticCanonicalModel  # Succeeds with warnings
```

Warnings about sorries:
- Line 219: compositionality (known limitation, unrelated)
- Line 629: truth_at_implies_semantic_truth (this task's gap)

## Recommendations

### Option A: Accept Current State (Recommended)
The `semantic_weak_completeness` IS sorry-free and provides the main completeness result:
```lean
(∀ w : SemanticWorldState φ, semantic_truth_at_v2 φ w t φ) → ⊢ φ
```
Document this as the primary completeness theorem. The gap is ONLY in connecting universal validity to semantic model truth.

### Option B: MCS-Restricted Proof
Restrict the FMP architecture to only use MCS-derived world states:
- Pros: Would enable full truth correspondence via existing MCS properties
- Cons: Requires significant refactoring of SemanticWorldState and related types

### Option C: Strengthen IsLocallyConsistent
Add negation completeness and full propositional closure to `IsLocallyConsistent`:
- Pros: Would enable the inductive proof
- Cons: Changes the semantics of FiniteWorldState, may invalidate other constructions

### Option D: Fix Box Architecture
Modify box semantics to use modal accessibility relations (Kripke-style) instead of quantifying over all histories:
- Pros: Would make box cases tractable
- Cons: Major semantic change, affects entire codebase

## Conclusion

Task 749 is BLOCKED. The v002 plan proposed structural induction over the subformula closure to prove forward truth correspondence. Detailed analysis revealed this approach has the same architectural limitations as the Representation/TruthLemma.lean:

1. **IsLocallyConsistent is weaker than MCS**: It lacks negation completeness needed for mutual induction
2. **Box quantifies over all histories**: An architectural choice that makes box correspondence impossible
3. **Temporal operators need coherence**: Only MCS families provide the needed forward_G/backward_H properties

The sorry in `truth_at_implies_semantic_truth` represents a fundamental architectural gap in the FMP construction, not a missing proof. Removing it would require structural changes to the model theory.

## Files Modified

- `Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean`
  - Updated docstring for `truth_at_implies_semantic_truth` (lines 609-653)
  - Added comprehensive architectural analysis

- `specs/749_.../plans/implementation-002.md`
  - Updated all phases with BLOCKED status
  - Added detailed analysis for each blocking issue

- `specs/749_.../summaries/implementation-summary-20260129.md`
  - This file - updated with v002 findings

## Verification

```bash
$ lake build Bimodal.Metalogic.FMP.SemanticCanonicalModel
# Build succeeds with expected sorries:
# - Line 219: compositionality (documented limitation)
# - Line 653: truth_at_implies_semantic_truth (forward truth lemma gap)
```
