# Research Report: Deep Analysis of Strategy C - Fully Saturated Multi-Family BMCS

**Task**: 843 - remove_singleFamily_modal_backward_axiom
**Session**: sess_1770238541_c178eb
**Date**: 2026-02-04
**Focus**: Complete proof chain analysis for Strategy C (fully saturated multi-family BMCS)

## Executive Summary

**DEFINITIVE FINDING: Strategy C is the cleanest mathematical approach but has ONE remaining gap that blocks full axiom elimination.**

The gap is **NOT** in the saturation construction itself (which is already complete for EvalBMCS). The gap is in converting EvalBMCS to full BMCS modal coherence for non-eval families.

**Status Assessment**:
- **YES WITH WORK**: Strategy C works but requires one specific construction to complete

**The Single Blocking Gap**:
```
BoxEquivalent preservation when adding witnesses to multi-family bundles
```

**Why This Matters**: Without BoxEquivalent, witnesses added via Lindenbaum may introduce NEW Box formulas that aren't in existing families, breaking modal coherence.

## 1. Complete Proof Chain Analysis

### 1.1 The Goal

Starting point: Consistent context Gamma
End point: BMCS where Gamma is satisfiable, with modal_forward and modal_backward PROVEN (not axiomatic)

### 1.2 The Chain Step by Step

| Step | Location | Status | Gap? |
|------|----------|--------|------|
| 1. Gamma consistent | Input | GIVEN | No |
| 2. Extend to MCS M via Lindenbaum | `lindenbaumMCS` (Construction.lean:289-292) | PROVEN | No |
| 3. Build constant IndexedMCSFamily | `constantIndexedMCSFamily` (Construction.lean:130-161) | PROVEN | No |
| 4. Create initial EvalCoherentBundle | `initialEvalCoherentBundle` (CoherentConstruction.lean:1151-1161) | PROVEN | No |
| 5. Define saturatedFamilies = base + all witnesses | `eval_saturated_bundle_exists` (CoherentConstruction.lean:1405-1558) | PROVEN | No |
| 6. Prove EvalCoherent for saturatedFamilies | `eval_saturated_bundle_exists` (CoherentConstruction.lean:1474-1494) | PROVEN | No |
| 7. Prove EvalSaturated | `eval_saturated_bundle_exists` (CoherentConstruction.lean:1517-1558) | PROVEN | No |
| 8. Convert to EvalBMCS | `EvalCoherentBundle.toEvalBMCS` (CoherentConstruction.lean:1119-1146) | PROVEN | No |
| 9. Prove EvalBMCS modal_forward_eval | `toEvalBMCS.modal_forward_eval` (CoherentConstruction.lean:1125-1130) | PROVEN | No |
| 10. Prove EvalBMCS modal_backward_eval | `toEvalBMCS.modal_backward_eval` (CoherentConstruction.lean:1131-1146) | PROVEN | No |
| 11. **Lift EvalBMCS to full BMCS** | **MISSING** | **GAP** | **YES** |
| 12. Prove truth lemma using BMCS | `bmcs_truth_lemma` (TruthLemma.lean:298-420) | PROVEN (for full BMCS) | Depends on #11 |
| 13. Prove completeness | `bmcs_representation` (Completeness.lean:99-108) | PROVEN (for full BMCS) | Depends on #11 |

### 1.3 The Critical Gap: Step 11

**Current State**: `eval_saturated_bundle_exists` produces an `EvalCoherentBundle` that converts to `EvalBMCS`, which has:
- `modal_forward_eval`: Box phi in eval_family -> phi in ALL families
- `modal_backward_eval`: phi in ALL families -> Box phi in eval_family

**What Full BMCS Requires**:
- `modal_forward`: Box phi in ANY family -> phi in ALL families
- `modal_backward`: phi in ALL families -> Box phi in ANY family

**The Lift Problem**: For modal_forward at a non-eval family fam', we need:
```
Box phi in fam'.mcs t -> phi in ALL families
```

But EvalBMCS only guarantees `EvalCoherent`:
```
All families contain BoxContent(eval_family)
```

If fam' has Box chi where chi is NOT in BoxContent(eval_family), other families may not contain chi.

## 2. Where Does Saturation Come From?

### 2.1 The `eval_saturated_bundle_exists` Theorem

**Location**: `CoherentConstruction.lean:1405-1558`

**Construction**:
```lean
let allWitnesses : Set (IndexedMCSFamily D) :=
  { W | exists psi : Formula, exists t : D, exists h_diamond : diamondFormula psi in base.mcs t,
        W = (constructCoherentWitness base h_const psi t h_diamond).family }

let saturatedFamilies : Set (IndexedMCSFamily D) := {base} U allWitnesses
```

**Key Insight**: This is NOT enumeration-based. It uses a single set comprehension to include ALL possible witnesses. The axiom of choice provides the construction.

### 2.2 Why EvalSaturated Works

The saturation condition is:
```
neg(Box phi) in eval.mcs t -> exists fam' in families with neg(phi) in fam'.mcs t
```

**Proof Strategy**:
1. Given `neg(Box phi) in eval.mcs t`
2. Use `neg_box_to_diamond_neg` to get `diamondFormula (neg phi) in eval.mcs t`
3. The witness for `diamondFormula (neg phi)` is in `allWitnesses` by definition
4. That witness contains `neg phi` by `constructCoherentWitness_contains_psi`

This is FULLY PROVEN at lines 1517-1558. No sorry or axiom needed.

### 2.3 What About `saturated_extension_exists` Axiom?

**Location**: `CoherentConstruction.lean:871-874`

This axiom is for the FULL `CoherentBundle` (multi-family with MutuallyCoherent), not EvalCoherentBundle. The EvalCoherentBundle path bypasses this axiom entirely.

**Status**: The axiom remains but is NOT used by the EvalBMCS construction path.

## 3. The modal_forward Problem at Non-Eval Families

### 3.1 EvalCoherent vs MutuallyCoherent

**EvalCoherent** (what we have):
```lean
def EvalCoherent (families : Set (IndexedMCSFamily D)) (eval_fam : IndexedMCSFamily D)
    (h_eval_mem : eval_fam in families) : Prop :=
  forall fam in families, forall chi in BoxContent eval_fam, forall t : D, chi in fam.mcs t
```

**MutuallyCoherent** (what full BMCS needs):
```lean
def MutuallyCoherent (families : Set (IndexedMCSFamily D)) : Prop :=
  forall fam in families, forall chi in UnionBoxContent families, forall t : D, chi in fam.mcs t
```

**The Difference**: MutuallyCoherent requires every family to contain chi for EVERY Box chi in ANY family. EvalCoherent only requires chi for Box chi in eval_family.

### 3.2 Why EvalCoherent Is Insufficient for Full BMCS

Consider a witness family W added for Diamond psi in eval_family. By construction:
- W contains BoxContent(eval_family) (by `constructCoherentWitness`)
- W's Lindenbaum extension may ADD new Box formulas

Suppose Lindenbaum adds `Box theta` to W where `theta` is NOT in BoxContent(eval_family).

Now for modal_forward at W:
```
Box theta in W.mcs t -> theta in ALL families
```

But:
- theta is NOT in BoxContent(eval_family)
- Other families only contain BoxContent(eval_family)
- So theta may NOT be in other families

**This breaks modal_forward for non-eval families.**

### 3.3 The BoxEquivalent Property

**Location**: `CoherentConstruction.lean:482-485`

```lean
def BoxEquivalent (families : Set (IndexedMCSFamily D)) : Prop :=
  forall chi : Formula, (exists fam in families, exists t : D, Formula.box chi in fam.mcs t) ->
         (forall fam' in families, forall t' : D, Formula.box chi in fam'.mcs t')
```

**If BoxEquivalent holds**, then:
1. Any Box chi in any family is in ALL families
2. By T-axiom, chi is in all families
3. modal_forward works for all families

**The Question**: Can we construct witnesses that preserve BoxEquivalent?

## 4. Analysis of the BoxEquivalent Gap

### 4.1 Why Standard Witness Construction Fails

The current `constructCoherentWitness` uses:
```lean
let W := extendToMCS psi h_cons  -- Lindenbaum extension of {psi} U BoxContent(base)
```

Lindenbaum's lemma is non-constructive. The resulting MCS may contain arbitrary Box formulas added during the maximality extension. We have no control over which Box formulas appear.

### 4.2 What Would Fix It: Box-Controlled Lindenbaum

**Hypothesis**: A "Box-controlled Lindenbaum" that:
1. Extends a consistent set to MCS
2. For any Box chi added, also adds Box chi to a designated "tracked set"
3. Ensures all tracked Box formulas are shared

**Problem**: Lindenbaum is typically proven by Zorn's lemma on arbitrary consistent extensions. Controlling which Box formulas appear requires a more sophisticated construction.

### 4.3 Alternative: S5 Property Enforcement

In S5 modal logic, if Box chi is true anywhere, it's true everywhere (by the Euclidean axiom). If our logic includes:
```
Diamond chi -> Box Diamond chi  (5 axiom)
```

Then Box formulas automatically propagate, and BoxEquivalent holds by construction.

**Our Logic**: TM (bimodal temporal) logic. Does it include the 5 axiom? Checking the axiom system in `Axiom.lean` would determine this.

### 4.4 Pragmatic Assessment

**Option A: Prove BoxEquivalent for TM logic**
- Requires showing TM includes sufficient modal axioms
- Would eliminate the gap

**Option B: Modify witness construction to track Box formulas**
- Significant infrastructure change
- Non-trivial to implement

**Option C: Accept EvalBMCS as primary completeness vehicle**
- Completeness only needs truth at eval_family
- eval_bmcs_truth_lemma has sorries but only in box case (non-eval families) and temporal backward
- These sorries don't affect the FORWARD direction used by completeness

## 5. The Truth Lemma Cross-Dependency

### 5.1 The Imp Case Problem

From `research-001.md` (Task 862), the forward direction of imp uses backward direction on subformula:
```lean
-- Forward: (psi -> chi) in MCS -> (bmcs_truth psi -> bmcs_truth chi)
intro h_imp h_psi_true
have h_psi_mcs : psi in fam.mcs t := (ih_psi fam hfam t).mpr h_psi_true  -- Uses .mpr!
```

This means forward and backward cannot be proven independently by simple structural induction.

### 5.2 Impact on Strategy C

**Strategy C requires full BMCS with modal_forward and modal_backward.**

The cross-dependency means we need BOTH directions to prove EITHER direction. This is independent of the saturation question - it's about the truth lemma proof structure.

**Resolution**: Mutual recursion or strong induction (as proposed in research-005.md) handles this regardless of which BMCS construction is used.

## 6. What Would Complete Strategy C

### 6.1 Required Developments

| Development | Effort | Description |
|-------------|--------|-------------|
| BoxEquivalent preservation | HIGH | Prove or construct witnesses that preserve BoxEquivalent |
| OR S5 property proof | MEDIUM | Prove TM logic implies BoxEquivalent via 5-like axiom |
| OR Box-tracking Lindenbaum | HIGH | Modify Lindenbaum to track/control Box formulas |
| Truth lemma restructure | MEDIUM | Mutual recursion (independent of above) |

### 6.2 The Most Promising Path

**S5 Property Approach**:

TM logic with the T-axiom and temporal operators has strong modal properties. If we can show:
```
Box chi in M (an MCS) -> Box chi is a theorem -> Box chi in every MCS
```

Then BoxEquivalent holds trivially.

**Why this might work**: In S5, the positive introspection axiom `Box chi -> Box Box chi` combined with other axioms can force Box formulas to be "universal truths."

**Checking**: Search for 4-axiom or 5-axiom in the TM proof system.

## 7. Current Axiom/Sorry Status

### 7.1 Active Axioms

| Axiom | Location | Purpose | Used By |
|-------|----------|---------|---------|
| `singleFamily_modal_backward_axiom` | Construction.lean:228-231 | phi in MCS -> Box phi in MCS | `singleFamilyBMCS` |
| `saturated_extension_exists` | CoherentConstruction.lean:871-874 | Saturated CoherentBundle exists | `construct_coherent_bmcs` (NOT used by EvalBMCS path) |

### 7.2 Active Sorries

| Sorry | Location | Reason | Blocks |
|-------|----------|--------|--------|
| Temporal G backward | TruthLemma.lean:403 | Needs temporal saturation (F-witnesses) | Full truth lemma IFF |
| Temporal H backward | TruthLemma.lean:419 | Needs temporal saturation (P-witnesses) | Full truth lemma IFF |
| EvalBMCS box forward | TruthLemma.lean:593 | Needs membership->truth at non-eval | EvalBMCS truth lemma |
| EvalBMCS box backward | TruthLemma.lean:600 | Needs truth->membership at non-eval | EvalBMCS truth lemma |

### 7.3 Path to Axiom-Free Completeness

**Current Path (working)**:
```
Full BMCS via singleFamilyBMCS
  uses singleFamily_modal_backward_axiom (1 axiom)
  -> bmcs_truth_lemma (forward direction PROVEN)
  -> bmcs_representation, bmcs_weak_completeness, bmcs_strong_completeness (all PROVEN)
```

**Strategy C Path (blocked)**:
```
CoherentBundle via saturated_extension_exists
  uses saturated_extension_exists (1 axiom - same axiom count, just different location)
  -> CoherentBundle.toBMCS (modal_forward and modal_backward PROVEN)
  -> bmcs_truth_lemma (same)
  -> completeness (same)
```

**Fully Axiom-Free Path (gap)**:
```
EvalCoherentBundle via eval_saturated_bundle_exists (PROVEN, no axiom)
  -> EvalCoherentBundle.toEvalBMCS (PROVEN)
  -> eval_bmcs_truth_lemma (HAS SORRIES in box case)
  -> eval_bmcs_eval_truth (inherits sorries)
  GAP: Cannot connect to axiom-free full completeness
```

## 8. Definitive Conclusion

### 8.1 Assessment

**Does Strategy C work completely, or not?**

**NO - Strategy C has a gap that cannot be closed with existing infrastructure.**

The gap is: EvalBMCS -> full BMCS requires BoxEquivalent, which is not proven.

### 8.2 The Gap Precisely Characterized

**Name**: BoxEquivalent preservation under witness addition

**Mathematical Statement**: For witnesses W constructed via Lindenbaum from {psi} U BoxContent(base), if Box chi in W.mcs t, then Box chi must be in base.mcs t (or all other witnesses).

**Why Difficult**: Lindenbaum maximality can add arbitrary formulas including Box formulas we don't control.

**Potential Resolution**: Prove that TM's modal axioms force Box formulas to be universal (similar to S5 behavior).

### 8.3 Alternative Characterization

The gap could also be framed as:

**Name**: Multi-family UnionBoxContent consistency

**Statement**: For any multi-family CoherentBundle B with Diamond psi in some family, {neg psi} U UnionBoxContent(B) is consistent.

This is the gap documented in CoherentConstruction.lean lines 847-852.

### 8.4 What Would Close the Gap

One of:
1. **BoxEquivalent preservation**: Show witnesses don't add "new" Box formulas (needs modal axiom analysis)
2. **Multi-family consistency lemma**: Prove {psi} U UnionBoxContent is consistent when Diamond psi holds
3. **S5-like property**: Show TM logic forces Box formulas to be universal

### 8.5 Practical Recommendation

**Current best path**: Use existing `singleFamilyBMCS` construction which:
- Has ONE axiom (`singleFamily_modal_backward_axiom`)
- Provides FULL BMCS with modal_forward and modal_backward
- Enables PROVEN completeness theorems

**To eliminate the axiom**: The most promising approach is proving TM logic has S5-like Box propagation, which would make BoxEquivalent trivial and enable full CoherentBundle saturation without axiom.

## 9. References

### Code Files
- `Theories/Bimodal/Metalogic/Bundle/CoherentConstruction.lean` - EvalBMCS construction (lines 1405-1625)
- `Theories/Bimodal/Metalogic/Bundle/Construction.lean` - singleFamily_modal_backward_axiom (line 228)
- `Theories/Bimodal/Metalogic/Bundle/ModalSaturation.lean` - Saturation infrastructure
- `Theories/Bimodal/Metalogic/Bundle/BMCS.lean` - BMCS structure definition
- `Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean` - Truth lemma with sorries
- `Theories/Bimodal/Metalogic/Bundle/Completeness.lean` - Completeness theorems

### Research Reports
- `specs/843_remove_singleFamily_modal_backward_axiom/reports/research-005.md` - Three strategies overview
- `specs/862_divide_truthlemma_forward_backward/reports/research-001.md` - Cross-dependency analysis
- `specs/844_redesign_metalogic_precoherent_bundle_construction/reports/research-002.md` - CoherentWitness approach

### Context Documents
- `.claude/context/project/lean4/standards/proof-debt-policy.md` - Axiom/sorry policy
