# Research Report: Task #750 (Options Analysis)

**Task**: Refactor forward Truth Lemma - Remove sorries
**Date**: 2026-01-29
**Focus**: Comprehensive analysis of viable approaches, with special attention to syntactic completeness

## Summary

This report evaluates all viable approaches for achieving sorry-free completeness, focusing on the request to analyze syntactic completeness. After examining the codebase architecture, sorry distribution, and mathematical constraints, I identify **five distinct approaches** with varying trade-offs. The **syntactic completeness approach** is theoretically elegant but faces fundamental obstacles in this proof system. The **most viable path** is completing the existing FMP infrastructure via `semantic_weak_completeness`.

## Current Sorry Inventory

### TruthLemma.lean (4 sorries)
| Line | Case | Direction | Issue |
|------|------|-----------|-------|
| 366 | box | forward | Quantifies over ALL histories - architectural |
| 389 | box | backward | Same architectural issue |
| 416 | all_past | backward | Omega-rule: cannot derive H phi from infinitely many phi |
| 438 | all_future | backward | Omega-rule: cannot derive G phi from infinitely many phi |

### CoherentConstruction.lean (11 sorries)
| Lines | Category | Notes |
|-------|----------|-------|
| 403, 416 | Seed consistency | Provable with inductive infrastructure |
| 654-744 | Cross-origin cases | 8 sorries marked "NOT REQUIRED FOR COMPLETENESS" |

### IndexedMCSFamily.lean (4 sorries)
All in `construct_indexed_family` (lines 620-638) - bridge to CoherentConstruction

### TaskRelation.lean (5 sorries)
Compositionality proofs (lines 151-177) - not on critical path

**Critical Path Analysis**: The representation theorem uses `truth_lemma_forward` which only depends on the FORWARD directions. The backward sorries (omega-rule) are explicitly marked as "NOT REQUIRED FOR COMPLETENESS."

## Approach Evaluation

### Option 1: Syntactic Completeness (Pure Proof-Theoretic)

**Concept**: Prove completeness without constructing semantic models at all. Instead, show that if phi is not provable, then a syntactic contradiction arises.

**Mathematical Foundation**: In classical logic, this would use:
1. Cut-elimination to show derivations have normal forms
2. Consistency of the empty theory (cannot derive bot from [])
3. Craig interpolation or similar syntactic techniques

**Analysis for TM Bimodal Logic**:

The TM logic proof system includes axioms for:
- Propositional logic (prop_s, prop_k, modus ponens)
- Modal box (box_k, necessitation, temp_t_box)
- Temporal G/H (temp_k_future, temp_k_past, temp_t_future, temp_t_past)
- Mixed temporal-modal (temp_4_future, temp_4_past, temp_gb, temp_hb)

**Obstacles**:
1. **No existing cut-elimination**: The codebase has no proof of cut-elimination for this system
2. **Modal necessitation complicates sequent calculus**: Standard cut-free systems for modal logic require labeled sequents or hypersequents
3. **Temporal operators add complexity**: G and H operators with mixed axioms create intricate proof search
4. **Effort estimate**: 4-8 weeks minimum to develop sequent calculus and cut-elimination

**Viability**: LOW - Would require building substantial new proof-theoretic infrastructure from scratch.

### Option 2: Algebraic-Semantic Bridge

**Concept**: Leverage the sorry-free `algebraic_representation_theorem` (AlgebraicRepresentation.lean) which proves:
```lean
AlgSatisfiable phi iff AlgConsistent phi
```

**What Exists**:
- Lindenbaum algebra with boolean structure (BooleanStructure.lean)
- Interior operators G_quot, H_quot, box_quot (InteriorOperators.lean)
- MCS to Ultrafilter bijection (UltrafilterMCS.lean)
- Partial bridge attempt (AlgebraicSemanticBridge.lean) - has 10 sorries

**Obstacles** (from research-006.md):
1. **No explicit time domain**: Ultrafilters are over formulas, not time-indexed
2. **Box operator gap**: algebraic box is an interior operator, semantic box quantifies over histories
3. **The bridge requires constructing TaskModel from ultrafilter**: This is essentially building a second representation theorem

**Status of AlgebraicSemanticBridge.lean**:
- Sorries in imp backward (2): Classical propositional lemmas
- Sorries in box (2): Architectural mismatch
- Sorries in temporal (6): Time-independence issues

**Viability**: MEDIUM-LOW - The bridge sorries reflect fundamental semantic gaps, not simple missing lemmas.

### Option 3: FMP Path via semantic_weak_completeness

**Concept**: The FMP module (SemanticCanonicalModel.lean) has a sorry-free `semantic_weak_completeness`:
```lean
def semantic_weak_completeness (phi : Formula) :
    (forall (w : SemanticWorldState phi), semantic_truth_at_v2 phi w t phi) ->
    deriv phi
```

**What's Needed**: Bridge `valid phi` to `forall w, semantic_truth_at_v2 phi w t phi`

**Current Status** (sorry_free_weak_completeness at line 801):
```lean
noncomputable def sorry_free_weak_completeness (phi : Formula) :
    valid phi -> deriv phi := by
  intro h_valid
  apply semantic_weak_completeness phi
  exact valid_implies_semantic_truth phi h_valid  -- has sorry
```

The sorry is in `truth_at_implies_semantic_truth` (line 629-699).

**Gap Analysis**:
The gap is between:
- `truth_at` (recursive evaluation in SemanticCanonicalModel)
- `semantic_truth_at_v2` (assignment check in FiniteWorldState)

For MCS-derived world states, these coincide. For arbitrary world states, they may differ.

**Potential Solution**:
Restrict the universal quantifier to MCS-derived world states only:
```lean
theorem valid_implies_semantic_truth_for_mcs_derived (phi : Formula) :
    valid phi ->
    forall (w : SemanticWorldState phi),
      (exists S h_mcs, w = worldStateFromClosureMCS phi S h_mcs) ->
      semantic_truth_at_v2 phi w t phi
```

This is sufficient because `semantic_weak_completeness` constructs its countermodel from an MCS.

**Viability**: HIGH - This is the closest path to sorry-free completion. Estimated effort: 1-2 weeks.

### Option 4: Fix Representation Path Sorries

**Concept**: Complete the existing canonical model path by fixing sorries in CoherentConstruction and TruthLemma.

**What's Provable**:
- Forward G/H directions (already proven)
- Propositional cases (already proven)
- Seed consistency sorries (CoherentConstruction.lean lines 403, 416)

**What's NOT Provable** (fundamental limitations):
- Backward G/H directions (omega-rule)
- Box case (architectural - quantifies over ALL histories)
- Cross-origin cases (complex, but marked NOT REQUIRED)

**Key Insight**: The backward direction sorries (lines 416, 438 in TruthLemma.lean) are marked "NOT REQUIRED FOR COMPLETENESS" because the representation theorem only uses `truth_lemma_forward`.

**Action Items**:
1. Prove seed consistency (induction showing G-bot/H-bot doesn't appear)
2. Connect IndexedMCSFamily to CoherentConstruction.toIndexedMCSFamily
3. Verify the critical path avoids all fundamental sorries

**Viability**: MEDIUM-HIGH - Most infrastructure exists. Estimated effort: 2-3 weeks.

### Option 5: Hybrid Approach

**Concept**: Use the sorry-free algebraic representation theorem for consistency, then show consistency implies satisfiability via a simpler model construction.

**Sketch**:
1. From `AlgConsistent phi` (not provable), get `AlgSatisfiable phi` (ultrafilter exists)
2. Show any ultrafilter gives a consistent MCS (existing: ultrafilterToMCS)
3. Use the MCS to seed a finite model construction (existing: FMP machinery)
4. Show phi is true in the finite model

**This differs from Option 2** because it doesn't try to prove a semantic truth lemma for arbitrary ultrafilter states - it just uses the ultrafilter as a consistency witness to seed the FMP construction.

**Viability**: MEDIUM - Novel approach that might bypass architectural gaps.

## Syntactic Completeness: Deep Dive

Since the user specifically requested analysis of syntactic completeness, here is a more detailed examination.

### What "Syntactic Completeness" Means

In standard modal logic, syntactic completeness can be approached via:

1. **Henkin-style**: Build maximal consistent extensions syntactically (this IS what the MCS approach does)
2. **Gentzen-style**: Cut-free sequent calculus where unprovable formulas have countermodels extracted from failed proof search
3. **Tableau-based**: Systematic saturation that either proves or generates countermodel

### Why TM Logic Resists Pure Syntactic Approaches

**The Temporal Quantifiers**: G (always future) and H (always past) quantify over unbounded time. In a purely syntactic setting:
- You cannot derive `G phi` from finitely many instances `phi_at_t1, phi_at_t2, ...`
- This is the omega-rule limitation explicitly noted in the sorries

**The Modal Box**: The box operator `□phi` means "phi is necessary" which in TM semantics means "true in all histories." A purely syntactic treatment would need to:
- Either use labeled deduction (tracking worlds)
- Or use hypersequent calculus
- Neither exists in the current codebase

### Partial Syntactic Result That IS Achievable

The **propositional fragment** of completeness IS essentially syntactic:
- The backward imp case (lines 279-318 of TruthLemma.lean) uses only MCS properties
- No semantic model needed for the propositional cases
- The sorries there are just classical logic lemmas (`|- not(psi -> chi) -> psi`)

**These could be filled in** using the existing proof system:
```lean
-- Proof sketch for missing lemma
-- Need: [neg(psi -> chi)] derives psi
-- Equivalent to: assumes (psi -> chi) -> bot, derive psi
-- By cases: if psi, done. If not psi, then (psi -> chi) by vacuous implication,
--           then bot by modus ponens with assumption. So not not psi. By DNE, psi.
```

### Recommendation for Syntactic Work

If pursuing syntactic aspects:
1. **Fill in the classical propositional sorries** (AlgebraicSemanticBridge.lean lines 301, 307)
2. **Accept that modal/temporal backward directions are fundamentally non-syntactic** (omega-rule)
3. **Use MCS approach** which is the standard "Henkin-style syntactic" method for modal logic

## Recommendations (Prioritized)

### Priority 1: FMP Path (Option 3)
**Why**: Closest to completion, builds on sorry-free `semantic_weak_completeness`
**Action**: Prove `truth_at_implies_semantic_truth` for MCS-derived world states
**Effort**: 1-2 weeks

### Priority 2: Representation Path (Option 4)
**Why**: Fixes existing infrastructure, benefits future development
**Action**: Complete seed consistency proofs, verify critical path
**Effort**: 2-3 weeks

### Priority 3: Classical Propositional Lemmas
**Why**: Quick wins that reduce sorry count
**Action**: Prove the two classical logic lemmas in AlgebraicSemanticBridge
**Effort**: 1-2 days

### NOT Recommended: Full Syntactic Completeness
**Why**: Would require building sequent calculus + cut-elimination from scratch
**Effort**: 4-8 weeks minimum

## Conclusion

**Syntactic completeness** in the pure sense (no semantic models) is not viable for TM bimodal logic without substantial new proof-theoretic infrastructure. However, the existing **MCS-based approach IS the standard "syntactic" method** for modal logic completeness (Henkin construction).

The **most efficient path** to sorry-free completeness is **Option 3 (FMP Path)**, which requires proving that semantic truth_at coincides with assignment truth for MCS-derived world states. This is a focused goal that leverages existing sorry-free infrastructure.

## References

- AlgebraicSemanticBridge.lean: Lines 258-382 (truth lemma with sorries)
- TruthLemma.lean: Lines 233-466 (representation path truth lemma)
- SemanticCanonicalModel.lean: Lines 448-506 (semantic_weak_completeness)
- CoherentConstruction.lean: Lines 392-797 (coherent family construction)
- UltrafilterMCS.lean: MCS-ultrafilter bijection

## Next Steps

1. Assess which option the implementer prefers based on mathematical taste and time constraints
2. For Option 3: Start with `truth_at_implies_semantic_truth`, identify minimal assumptions needed
3. For Option 4: Audit which sorries are truly on the critical path for `representation_theorem`
