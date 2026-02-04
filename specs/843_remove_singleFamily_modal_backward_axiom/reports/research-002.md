# Research Report: EvalCoherentBundle vs Constant Families and Converse T-Axiom Analysis

**Task**: 843 - remove_singleFamily_modal_backward_axiom
**Date**: 2026-02-04
**Focus**: Does EvalCoherentBundle avoid the converse T-axiom problem?

## Executive Summary

This report analyzes whether the EvalCoherentBundle approach from task 856 avoids the converse T-axiom problem (`phi -> Box phi`) that invalidates single-family constant constructions.

**Key Finding**: EvalCoherentBundle **does correctly avoid** the converse T-axiom problem through a fundamentally different proof structure. The multi-family approach proves `modal_backward_eval` via **contraposition using saturation**, NOT via the converse T-axiom.

**Conclusion**: Task 843 can proceed with the implementation outlined in research-001.md. The path is clear and mathematically sound.

## 1. Research Questions Answered

### Q1: Does EvalCoherentBundle use constant families internally?

**Answer**: Yes, but this is not problematic.

**Evidence** (CoherentConstruction.lean lines 1413-1414):
```lean
let base : IndexedMCSFamily D := constantIndexedMCSFamily M h_mcs
let h_const : IsConstantFamily base := constantIndexedMCSFamily_is_constant M h_mcs
```

The EvalCoherentBundle uses constant families for both:
1. The base family (from Lindenbaum extension)
2. All witness families (via `constructCoherentWitness` -> `constantWitnessFamily`)

**Why This Is Not Problematic**: The issue with constant families is NOT that they exist, but how they are used. The single-family BMCS tries to prove `phi -> Box phi` within ONE family. The multi-family approach never does this - it proves modal backward via contraposition across MULTIPLE families.

### Q2: Does multi-family saturation truly avoid the converse T-axiom issue?

**Answer**: Yes, absolutely. The proof structures are fundamentally different.

**The Converse T-Axiom Problem**:
- Single-family: Must show `phi in MCS => Box phi in MCS`
- This is the converse of the T-axiom (`Box phi -> phi`)
- NOT a valid modal logic principle
- Cannot be proven from first principles

**How EvalCoherentBundle Avoids This** (CoherentConstruction.lean lines 1131-1146):

```lean
modal_backward_eval := by
  intro phi t h_all
  -- Prove by contraposition using saturation
  by_contra h_not_box
  -- By MCS negation completeness, neg(Box phi) in eval_family.mcs t
  have h_mcs := B.eval_family.is_mcs t
  have h_neg_box : Formula.neg (Formula.box phi) in B.eval_family.mcs t := by
    rcases set_mcs_negation_complete h_mcs (Formula.box phi) with h_box | h_neg
    · exact absurd h_box h_not_box
    · exact h_neg
  -- By saturation, exists fam' with neg(phi) in fam'.mcs t
  rcases h_sat phi t h_neg_box with ⟨fam', h_fam', h_neg_phi⟩
  -- But h_all says phi in fam'.mcs t
  have h_phi := h_all fam' h_fam'
  -- Contradiction
  exact set_consistent_not_both (fam'.is_mcs t).1 phi h_phi h_neg_phi
```

**The Proof Structure**:
1. Assume `phi` is in ALL families but `Box phi` is NOT in eval_family
2. By MCS completeness: `neg(Box phi)` IS in eval_family
3. By saturation: there EXISTS a witness family with `neg(phi)`
4. But hypothesis says `phi` is in ALL families, including the witness
5. Contradiction: `phi` and `neg(phi)` both in witness family

**Critical Insight**: The proof NEVER asserts `phi -> Box phi`. Instead:
- It shows: `(phi in ALL families) -> (Box phi in eval_family)`
- Via contraposition: `NOT(Box phi in eval) -> NOT(phi in ALL families)`
- The saturation provides the witness family where `phi` fails

This is mathematically valid and does NOT require the converse T-axiom.

### Q3: What exactly does singleFamily_modal_backward_axiom assert?

**Answer**: It asserts the converse T-axiom directly.

**Axiom Statement** (Construction.lean lines 228-231):
```lean
axiom singleFamily_modal_backward_axiom (D : Type*) [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D] (fam : IndexedMCSFamily D) (phi : Formula) (t : D)
    (h_phi_in : phi in fam.mcs t) :
    Formula.box phi in fam.mcs t
```

**Plain English**: If `phi` is in the MCS at time `t`, then `Box phi` is also in the MCS at time `t`.

**Why It's Needed for Single-Family**: With only ONE family, the condition `phi in ALL families` degenerates to `phi in fam`. The modal_backward property then becomes `phi in fam -> Box phi in fam`, which is the converse T-axiom.

### Q4: Comparison: singleFamily_modal_backward_axiom vs modal_backward_eval

| Aspect | singleFamily_modal_backward_axiom | modal_backward_eval |
|--------|-----------------------------------|---------------------|
| **Form** | `phi in fam -> Box phi in fam` | `(forall fam, phi in fam) -> Box phi in eval` |
| **Mathematical Status** | Invalid in modal logic (converse T) | Valid via contraposition |
| **Proof Method** | Axiom (assumed) | Derived from saturation |
| **Scope** | Single family only | Multi-family |
| **Soundness** | Requires metatheoretic justification | Structurally sound |

**Key Difference**: The axiom asserts something about ONE family; `modal_backward_eval` reasons about MULTIPLE families. The universal quantification over families is what makes the saturation argument work.

### Q5: What remains to complete task 843?

**Answer**: The implementation path from research-001.md is validated. Required changes:

**Phase 1: EvalBMCS Truth Infrastructure** (2-3 hours)
- Create `eval_bmcs_truth_at` mirroring `bmcs_truth_at` but for EvalBMCS
- Create helper lemmas for negation, implication, etc.

**Phase 2: EvalBMCS Truth Lemma** (3-4 hours)
- Create `eval_bmcs_truth_lemma` using the same structure
- Box case uses `modal_forward_eval` and `modal_backward_eval`
- Temporal cases will still have sorries (independent issue)

**Phase 3: Completeness Rewiring** (2-3 hours)
- Update `bmcs_representation` to use `construct_eval_bmcs`
- Update `bmcs_context_representation`
- Update validity and consequence definitions for EvalBMCS
- Update weak and strong completeness theorems

**Phase 4: Axiom Removal** (0.5 hours)
- Comment out `singleFamily_modal_backward_axiom`
- Comment out `singleFamilyBMCS` (no longer needed)
- Run `lake build` to verify

**Total Estimated Effort**: 8-10 hours

## 2. Analysis: Constant Family Time Indexing

Research report research-004.md for task 857 discusses why constant families cannot prove temporal backward. This analysis is ORTHOGONAL to the modal backward case:

**Temporal Backward Issue**:
- Requires time-varying MCS to witness F formulas
- Constant family: `mcs t = mcs s` for all t, s
- Cannot distinguish "phi at time s" from "phi at time t"
- Saturation across TIME is impossible with constant families

**Modal Backward Resolution**:
- Requires family-varying MCS to witness Diamond formulas
- Constant families per-family: each family has `mcs t = M` internally
- CAN distinguish "phi in family A" from "phi in family B"
- Saturation across FAMILIES works perfectly

**Key Insight**: The dimensions are different:
| Property | Dimension | Constant Family Status |
|----------|-----------|------------------------|
| Modal Backward | Families | Solves it (multi-family saturation) |
| Temporal Backward | Time | Cannot solve (needs time-varying) |

The EvalCoherentBundle approach from task 856 addresses the family dimension. Task 857's temporal backward requires addressing the time dimension with a different construction.

## 3. Why the Approach Is Sound

### 3.1 Saturation Provides Witnesses

The saturation condition (CoherentConstruction.lean lines 1061-1065):
```lean
def EvalSaturated (families : Set (IndexedMCSFamily D)) (eval_fam : IndexedMCSFamily D)
    (h_eval_mem : eval_fam in families) : Prop :=
  forall phi : Formula, forall t : D,
    Formula.neg (Formula.box phi) in eval_fam.mcs t ->
    exists fam' in families, Formula.neg phi in fam'.mcs t
```

This is proven WITHOUT sorry in `eval_saturated_bundle_exists` (lines 1405-1558).

### 3.2 The Saturation Construction

The construction defines (lines 1452-1457):
```lean
let allWitnesses : Set (IndexedMCSFamily D) :=
  { W | exists psi : Formula, exists t : D, exists h_diamond : diamondFormula psi in base.mcs t,
        W = (constructCoherentWitness base h_const psi t h_diamond).family }

let saturatedFamilies : Set (IndexedMCSFamily D) := {base} U allWitnesses
```

For each Diamond formula `diamondFormula psi` (which equals `neg(Box(neg psi))`), a witness family containing `psi` is added.

The saturation proof (lines 1516-1558) shows that for any `neg(Box phi)` in the base:
1. Convert to `diamondFormula(neg phi)` via `neg_box_to_diamond_neg`
2. The witness for this Diamond contains `neg phi`
3. This witness is in `saturatedFamilies` by construction

### 3.3 No Circularity

The proof avoids circularity because:
1. **BoxContent is fixed**: `BoxContent(eval_family)` is determined at construction
2. **Witnesses don't add to UnionBoxContent**: EvalCoherent only requires families to contain `BoxContent(eval_family)`, not full UnionBoxContent
3. **No propagation of new boxes**: New Box formulas in witnesses don't create new coherence obligations

This differs from the failed multi-family CoherentBundle approach which required mutual coherence across ALL families.

## 4. Axiom Inventory Update

### Current State After Task 856

| Location | Axiom | Purpose | Removable? |
|----------|-------|---------|------------|
| Construction.lean:228 | `singleFamily_modal_backward_axiom` | Modal backward for single-family | YES (via EvalBMCS) |
| CoherentConstruction.lean:871 | `saturated_extension_exists` | Full BMCS saturation | N/A (bypassed by EvalBMCS) |

### After Task 843 Completion

| Location | Axiom | Purpose | Status |
|----------|-------|---------|--------|
| Construction.lean:228 | `singleFamily_modal_backward_axiom` | (commented out) | REMOVED |
| CoherentConstruction.lean:871 | `saturated_extension_exists` | (unused) | ORPHANED |

The `saturated_extension_exists` axiom was for full BMCS construction but is not needed for completeness - EvalBMCS suffices.

## 5. Verification Checklist

Before implementation, verify:

- [x] `eval_saturated_bundle_exists` is proven (no sorry) - CONFIRMED at line 1405
- [x] `EvalCoherentBundle.toEvalBMCS` is proven (no sorry) - CONFIRMED at line 1119
- [x] `construct_eval_bmcs` is defined - CONFIRMED at line 1565
- [x] `construct_eval_bmcs_contains_context` is proven - CONFIRMED at line 1575
- [x] Modal backward does NOT use converse T-axiom - CONFIRMED via proof structure analysis
- [ ] EvalBMCS truth infrastructure exists - NOT YET (Phase 1)
- [ ] EvalBMCS truth lemma exists - NOT YET (Phase 2)
- [ ] Completeness theorems use EvalBMCS - NOT YET (Phase 3)

## 6. Conclusion

**The EvalCoherentBundle approach from task 856 correctly avoids the converse T-axiom problem.**

The key insight is that multi-family saturation proves modal backward via **contraposition**, not via direct assertion. The proof shows that IF `Box phi` is NOT in the eval_family, THEN there EXISTS a witness family where `phi` is false - contradicting the assumption that `phi` is in ALL families.

This is fundamentally different from the single-family case which must assert `phi -> Box phi` directly.

**Task 843 can proceed** with the implementation plan from research-001.md. The estimated effort of 8-10 hours is accurate. The primary work is creating EvalBMCS-specific truth definitions and rewiring the completeness theorems.

## 7. References

- CoherentConstruction.lean: Lines 1076-1146 (EvalBMCS structure and modal_backward_eval proof)
- CoherentConstruction.lean: Lines 1405-1558 (eval_saturated_bundle_exists proof)
- Construction.lean: Lines 228-231 (singleFamily_modal_backward_axiom)
- research-001.md: Prior research and implementation outline
- research-004.md (task 857): Why constant families cannot prove temporal backward
- proof-debt-policy.md: Axiom handling standards
