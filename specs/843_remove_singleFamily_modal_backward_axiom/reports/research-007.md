# Research Report: S5-like Box Propagation vs Multi-Family Consistency

**Task**: 843 - remove_singleFamily_modal_backward_axiom
**Session**: sess_1770239346_1af20d
**Date**: 2026-02-04
**Focus**: Rigorous analysis of two approaches to closing the BoxEquivalent gap

## Executive Summary

**DEFINITIVE FINDING**: The TM logic already includes full S5 modal axioms, which DOES guarantee Box propagation - but through MCS semantics, NOT through syntactic MCS sharing. The original gap analysis in research-006.md misidentified the problem.

**RECOMMENDED APPROACH**: Neither Approach 1 nor Approach 2 as originally framed. Instead:

**THE ACTUAL SOLUTION**: Use the existing EvalBMCS construction (fully proven, no axioms needed) together with a completeness theorem specifically for EvalBMCS. The truth lemma only evaluates at eval_family, so EvalBMCS's weaker properties are SUFFICIENT.

## 1. Approach 1: S5-like Box Propagation

### 1.1 TM Logic's S5 Axiom System

Examining `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/ProofSystem/Axioms.lean`:

| Axiom | Name | Formula | Status |
|-------|------|---------|--------|
| T | `modal_t` | `Box phi -> phi` | **INCLUDED** (line 94) |
| 4 | `modal_4` | `Box phi -> Box Box phi` | **INCLUDED** (line 102) |
| B | `modal_b` | `phi -> Box Diamond phi` | **INCLUDED** (line 110) |
| 5-collapse | `modal_5_collapse` | `Diamond Box phi -> Box phi` | **INCLUDED** (line 131) |
| K | `modal_k_dist` | `Box(phi -> psi) -> (Box phi -> Box psi)` | **INCLUDED** (line 193) |

**Conclusion**: TM logic is a FULL S5 modal logic (plus temporal operators). All S5 axioms are present.

### 1.2 Derived S5 Properties

From `Theories/Bimodal/Theorems/ModalS5.lean` and `Theories/Bimodal/Theorems/Perpetuity/Principles.lean`:

| Property | Theorem | Proof Status |
|----------|---------|--------------|
| Diamond 4 | `Diamond Diamond phi -> Diamond phi` | PROVEN (`diamond_4`, line 236) |
| Modal 5 | `Diamond phi -> Box Diamond phi` | PROVEN (`modal_5`, line 331) |
| S5 collapse | `Diamond Box phi <-> Box phi` | PROVEN (`s5_diamond_box`, line 788) |

**Key Insight**: In S5, `Diamond phi -> Box Diamond phi` (modal_5). This means:
- If Diamond phi is in ANY MCS, then Box Diamond phi is in that MCS
- By modal_t applied to Diamond phi: Diamond phi is true at that world
- The accessibility relation is an equivalence relation

### 1.3 Why S5 Does NOT Automatically Give BoxEquivalent

**Critical distinction**: S5 properties are about SEMANTIC accessibility, not about MCS content sharing.

In S5 Kripke semantics:
- Every world is accessible from every other world
- If Box phi holds at one world, phi holds at ALL worlds
- If Box phi holds at one world, Box phi holds at ALL worlds (by Modal 4)

**But in canonical model construction**:
- Each MCS represents a world
- Box phi in MCS M means: for all accessible MCS M', phi in M'
- With S5 accessibility: Box phi in M implies phi in all MCS
- **However**, the converse is NOT automatic: phi in all MCS does NOT imply Box phi in M

The issue is: we construct MCS via Lindenbaum extension independently. Even with S5 axioms, different MCS are different sets. The S5 property ensures SEMANTIC truth propagation, but we need the SYNTACTIC modal_backward property:

```
phi in ALL families => Box phi in ANY family
```

This is what `saturated_modal_backward` proves (ModalSaturation.lean:418-457), but it requires SATURATION.

### 1.4 Verdict on Approach 1

**Mathematical Correctness**: The S5 axioms DO ensure that all MCS "agree" on modal truths semantically (through the equivalence-relation accessibility). However, this agreement is enforced through the SATURATION construction, not automatically from the axioms.

**Feasibility**: The S5 properties are already proven in the codebase. But they don't give "free" BoxEquivalent.

**Status**: DOES NOT DIRECTLY SOLVE THE PROBLEM

## 2. Approach 2: Multi-Family Consistency Lemma

### 2.1 UnionBoxContent Definition

From `CoherentConstruction.lean` lines 404-405:
```lean
def UnionBoxContent (families : Set (IndexedMCSFamily D)) : Set Formula :=
  {chi | exists fam in families, chi in BoxContent fam}
```

Where `BoxContent fam = {chi | exists t, Box chi in fam.mcs t}`.

### 2.2 The Obstruction: Why {psi} U UnionBoxContent Might Be Inconsistent

**Scenario**:
- Diamond psi is in family F1's MCS at time t
- UnionBoxContent includes chi where Box chi is in F2's MCS (different family!)
- We need: {psi} U {chi | Box chi in some family} is consistent

**The K-distribution argument works when**: All Box formulas come from the SAME MCS that contains Diamond psi. Then:
- If L derives bot from {psi} U {chi1, ..., chik} where Box chi_i in M
- Then Box(chi1 -> chi2 -> ... -> neg psi) in M (by generalized K)
- Contradicts Diamond psi = neg(Box neg psi) in M

**The argument FAILS when**: Box chi comes from a DIFFERENT MCS M' that doesn't contain Diamond psi. We can't derive the contradiction because we can't use K-distribution across different MCS.

### 2.3 The Existing Solution: EvalCoherent

The codebase already solves this by weakening the requirement:

**EvalCoherent** (line 1032-1034):
```lean
def EvalCoherent (families : Set (IndexedMCSFamily D)) (eval_fam : IndexedMCSFamily D)
    (h_eval_mem : eval_fam in families) : Prop :=
  forall fam in families, forall chi in BoxContent eval_fam, forall t : D, chi in fam.mcs t
```

This only requires families to contain `BoxContent(eval_family)`, NOT `UnionBoxContent`.

**Why this works**:
1. Witnesses are constructed from eval_family's Diamonds
2. Each witness contains BoxContent(eval_family) by construction
3. New Box formulas in witnesses don't propagate requirements
4. The K-distribution argument works because all relevant Box formulas come from eval_family

### 2.4 Verdict on Approach 2

**Mathematical Correctness**: The multi-family consistency lemma (for full UnionBoxContent) is NOT needed. The EvalCoherent approach sidesteps it.

**Feasibility**: Already implemented and proven.

**Status**: NOT THE RIGHT FRAMING - problem was solved differently

## 3. The Actual State of the Codebase

### 3.1 What's Already Proven (No Axioms)

| Component | Location | Status |
|-----------|----------|--------|
| `diamond_boxcontent_consistent_constant` | CoherentConstruction.lean:249-338 | PROVEN |
| `constructCoherentWitness` | CoherentConstruction.lean:354-369 | PROVEN |
| `EvalCoherent_singleton` | CoherentConstruction.lean:1039-1053 | PROVEN |
| `addWitness_preserves_EvalCoherent` | CoherentConstruction.lean:1196-1207 | PROVEN |
| `EvalCoherentBundle.toEvalBMCS` | CoherentConstruction.lean:1119-1146 | PROVEN |
| `neg_box_to_diamond_neg` | CoherentConstruction.lean:1389-1403 | PROVEN |
| `eval_saturated_bundle_exists` | CoherentConstruction.lean:1405-1558 | **PROVEN** (no axiom) |
| `construct_eval_bmcs` | CoherentConstruction.lean:1565-1570 | PROVEN |
| `construct_eval_bmcs_contains_context` | CoherentConstruction.lean:1575-1585 | PROVEN |

### 3.2 Active Axioms

| Axiom | Location | Used By | Can Eliminate? |
|-------|----------|---------|----------------|
| `singleFamily_modal_backward_axiom` | Construction.lean:228-231 | `singleFamilyBMCS` | Yes - use EvalBMCS path instead |
| `saturated_extension_exists` | CoherentConstruction.lean:871-874 | `construct_coherent_bmcs` (NOT EvalBMCS) | N/A - not used by EvalBMCS |

### 3.3 The Key Insight: EvalBMCS is Sufficient for Completeness

The completeness theorem evaluates truth at a SINGLE family (eval_family):

```lean
-- Completeness only needs truth at eval_family
theorem bmcs_weak_completeness : Formula.valid phi -> [] ⊢ phi
theorem bmcs_strong_completeness : Gamma ⊨ phi -> Gamma ⊢ phi
```

**EvalBMCS provides exactly what's needed**:
- `modal_forward_eval`: Box phi in eval_family -> phi in ALL families
- `modal_backward_eval`: phi in ALL families -> Box phi in eval_family

This is sufficient because the truth lemma is evaluated at eval_family.

## 4. The Path to Axiom-Free Completeness

### 4.1 Current Path (Working, 1 Axiom)

```
Context Gamma consistent
  -> singleFamilyBMCS (uses singleFamily_modal_backward_axiom)
  -> BMCS with modal_forward, modal_backward
  -> bmcs_truth_lemma
  -> completeness
```

### 4.2 Axiom-Free Path (Ready to Implement)

```
Context Gamma consistent
  -> eval_saturated_bundle_exists (PROVEN, no axiom)
  -> EvalCoherentBundle
  -> toEvalBMCS (PROVEN)
  -> EvalBMCS with modal_forward_eval, modal_backward_eval
  -> eval_bmcs_truth_lemma (needs implementation)
  -> eval_bmcs_completeness (needs implementation)
```

### 4.3 What Remains to Implement

1. **eval_bmcs_truth_lemma**: Truth lemma for EvalBMCS
   - Forward direction at eval_family: STRAIGHTFORWARD (same as BMCS)
   - Backward direction at eval_family: STRAIGHTFORWARD (same as BMCS)
   - Box case only needs eval_family properties

2. **eval_bmcs_completeness**: Completeness using EvalBMCS
   - Representation theorem for eval_family
   - Lift to strong completeness

### 4.4 Effort Estimate

| Task | Effort | Blocking? |
|------|--------|-----------|
| Define `eval_bmcs_truth_lemma` | 2-3 hours | No |
| Prove forward direction | 3-4 hours | No |
| Prove backward direction | 3-4 hours | No |
| Connect to completeness | 2-3 hours | No |
| **Total** | **10-14 hours** | **No blockers** |

## 5. Definitive Assessment

### 5.1 Summary of Findings

| Approach | Works? | Why? |
|----------|--------|------|
| S5 Box Propagation | No | S5 gives semantic agreement, not syntactic MCS sharing |
| Multi-Family Consistency | Unnecessary | EvalCoherent sidesteps the issue |
| EvalBMCS Path | **YES** | Already proven, just needs truth lemma adaptation |

### 5.2 Recommended Approach

**RECOMMENDED APPROACH**: Neither Approach 1 nor Approach 2 as originally framed.

**THE SOLUTION**: Complete the EvalBMCS path by implementing:
1. `eval_bmcs_truth_lemma` - truth lemma specialized for EvalBMCS
2. Connect to existing completeness infrastructure

**JUSTIFICATION**:
- The EvalBMCS construction is FULLY PROVEN with no axioms
- EvalBMCS properties are SUFFICIENT for completeness (truth evaluated at eval_family)
- The gap in research-006.md was identifying BoxEquivalent as blocking; it's not - EvalCoherent suffices

### 5.3 Blocking Issues

**NONE**. The path to axiom-free completeness is clear:
1. EvalBMCS construction: DONE (no axioms)
2. Truth lemma for EvalBMCS: Needs implementation (no expected blockers)
3. Completeness via EvalBMCS: Needs implementation (no expected blockers)

## 6. Revised Understanding of the Gap

### 6.1 Original Gap (from research-006.md)

"BoxEquivalent preservation when adding witnesses to multi-family bundles"

### 6.2 Why This Isn't the Real Blocker

The BoxEquivalent property is needed for FULL BMCS (modal_forward and modal_backward for ALL families). But completeness only needs:
- modal_forward_eval (from eval_family)
- modal_backward_eval (to eval_family)

EvalCoherent guarantees these without BoxEquivalent.

### 6.3 The Actual Work Needed

Implement the truth lemma for EvalBMCS, which uses EvalCoherent properties instead of full MutuallyCoherent. The proof structure is identical to the existing truth lemma, just using the weaker modal coherence properties.

## 7. Technical Details

### 7.1 Why EvalCoherent is Sufficient

**For modal_forward_eval**:
- Need: Box phi in eval_family -> phi in ALL families
- By EvalCoherent: all families contain BoxContent(eval_family)
- Box phi in eval_family means phi in BoxContent(eval_family)
- Therefore phi is in all families

**For modal_backward_eval**:
- Need: phi in ALL families -> Box phi in eval_family
- Use contraposition + saturation (same as BMCS)
- EvalSaturated guarantees witness exists in eval_family

### 7.2 Why BoxEquivalent Would Be Overkill

BoxEquivalent: Box chi in ANY family -> Box chi in ALL families

This is stronger than needed. We only care about:
- Box formulas in eval_family propagating OUT (modal_forward_eval)
- Formulas in all families propagating INTO eval_family as Box (modal_backward_eval)

We don't need Box formulas from non-eval families to propagate anywhere.

## 8. Next Steps

1. **Create task for EvalBMCS truth lemma** - Implement `eval_bmcs_truth_lemma`
2. **Create task for EvalBMCS completeness** - Connect to existing infrastructure
3. **Verify axiom elimination** - Check `singleFamily_modal_backward_axiom` is no longer needed
4. **Clean up** - Remove or deprecate axiom-based path

## 9. References

### Code Files
- `Theories/Bimodal/ProofSystem/Axioms.lean` - S5 axiom system (full S5)
- `Theories/Bimodal/Metalogic/Bundle/CoherentConstruction.lean` - EvalBMCS construction
- `Theories/Bimodal/Metalogic/Bundle/ModalSaturation.lean` - Saturation infrastructure
- `Theories/Bimodal/Theorems/ModalS5.lean` - S5 theorem proofs
- `Theories/Bimodal/Theorems/Perpetuity/Principles.lean` - modal_5, diamond_4 proofs

### Research Reports
- `specs/843_remove_singleFamily_modal_backward_axiom/reports/research-006.md` - Previous gap analysis
- `specs/862_divide_truthlemma_forward_backward/reports/research-001.md` - Cross-dependency analysis
