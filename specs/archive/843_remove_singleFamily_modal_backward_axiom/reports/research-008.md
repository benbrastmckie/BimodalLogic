# Research Report: Post-Task-857 Assessment of Axiom Removal Path

**Task**: 843 - remove_singleFamily_modal_backward_axiom
**Session**: sess_1770241651_4af934
**Date**: 2026-02-04
**Focus**: Evaluate current axiom/sorry state after task 857 and determine concrete next steps

## Executive Summary

Task 857 achieved its goal of eliminating sorries from `bmcs_truth_lemma` and the completeness chain, but it did so by introducing a NEW axiom (`temporally_saturated_mcs_exists`). The completeness theorem is now sorry-free but depends on TWO axioms. The EvalBMCS approach from research-007 remains the correct path for eliminating `singleFamily_modal_backward_axiom`, but 857's changes have created a more complex axiom landscape that must be addressed holistically.

## 1. What Task 857 Actually Accomplished

### 1.1 Completeness Chain: Before vs After

**Before 857**:
- `bmcs_truth_lemma`: 4 sorries in temporal backward cases (G, H)
- Completeness theorem: Sorry-free (used only forward direction)
- Axioms: `singleFamily_modal_backward_axiom` (Construction.lean)

**After 857**:
- `bmcs_truth_lemma`: Zero sorries (all 6 cases proven)
- Completeness theorem: Zero sorries
- Axioms: `singleFamily_modal_backward_axiom` (Construction.lean) + `temporally_saturated_mcs_exists` (TemporalCoherentConstruction.lean)

### 1.2 The Tradeoff

Task 857 traded 4 sorries for 1 axiom. The `temporally_saturated_mcs_exists` axiom asserts the existence of temporally saturated MCS extending any consistent context. The axiom is mathematically justified (standard Henkin-style construction) but represents technical debt that propagates to the completeness theorem.

### 1.3 How 857 Diverged from Its Plan

Plan v003 proposed building `temporalLindenbaumMCS` - a modified Lindenbaum construction with temporal witness insertion. Instead, 857 used an axiom-based shortcut: declare temporal saturation existence as an axiom, build `TemporalCoherentFamily` from it, and prove the truth lemma. The `temporal_witness_seed_consistent` theorem IS proven (TemporalCoherentConstruction.lean:477-538) but the actual Lindenbaum construction was not implemented.

## 2. Current Axiom and Sorry Inventory

### 2.1 Axioms in the Completeness Chain

| Axiom | File | Line | Used By | Category |
|-------|------|------|---------|----------|
| `singleFamily_modal_backward_axiom` | Construction.lean | 228-231 | `singleFamilyBMCS` -> `construct_temporal_bmcs` -> completeness | Construction assumption |
| `temporally_saturated_mcs_exists` | TemporalCoherentConstruction.lean | 575-580 | `temporal_eval_saturated_bundle_exists` -> `construct_temporal_bmcs` -> completeness | Existence assumption |

**Both axioms are in the completeness dependency chain.** The completeness theorem inherits both.

### 2.2 Axioms NOT in the Completeness Chain

| Axiom | File | Line | Used By | Status |
|-------|------|------|---------|--------|
| `saturated_extension_exists` | CoherentConstruction.lean | 871-874 | `construct_coherent_bmcs` | Dead code (not used by completeness) |
| `weak_saturated_extension_exists` | WeakCoherentBundle.lean | 826 | WeakCoherentBundle path | Dead code (not used by completeness) |

### 2.3 Sorries in TruthLemma.lean

| Location | Function | Nature |
|----------|----------|--------|
| Line 604 | `eval_bmcs_truth_lemma` box forward | EvalBMCS structural limitation |
| Line 611 | `eval_bmcs_truth_lemma` box backward | EvalBMCS structural limitation |
| Line 625 | `eval_bmcs_truth_lemma` all_future backward | Temporal saturation |
| Line 639 | `eval_bmcs_truth_lemma` all_past backward | Temporal saturation |

These 4 sorries are in the LEGACY `eval_bmcs_truth_lemma`, which is NOT used by the completeness theorem. The main `bmcs_truth_lemma` (used by completeness) has zero sorries.

### 2.4 Current Completeness Dependency Graph

```
bmcs_strong_completeness (sorry-free)
  -> bmcs_context_representation (sorry-free)
    -> construct_temporal_bmcs
      -> singleFamilyBMCS
        -> singleFamily_modal_backward_axiom [AXIOM 1]
      -> temporal_eval_saturated_bundle_exists
        -> temporally_saturated_mcs_exists [AXIOM 2]
    -> bmcs_truth_lemma (sorry-free)
      -> temporal_backward_G / temporal_backward_H (sorry-free)
        -> TemporalCoherentFamily.forward_F / backward_P
```

## 3. Does the EvalBMCS Approach from Research-007 Still Apply?

### 3.1 What Research-007 Recommended

Research-007 recommended:
1. Use the existing EvalBMCS construction (fully proven, no axioms)
2. Implement `eval_bmcs_truth_lemma` for EvalBMCS
3. Connect to completeness via `eval_bmcs_completeness`

This would eliminate `singleFamily_modal_backward_axiom` because EvalBMCS does not use it.

### 3.2 How 857 Changed the Landscape

Task 857 changed the completeness path to use `construct_temporal_bmcs` (which uses `singleFamilyBMCS`, which uses the modal backward axiom). This was done to solve the temporal backward problem, which research-007 did not address.

The EvalBMCS path in CoherentConstruction.lean:
- `eval_saturated_bundle_exists`: PROVEN (no axioms, no sorries)
- `construct_eval_bmcs`: PROVEN
- `construct_eval_bmcs_contains_context`: PROVEN

However, the EvalBMCS truth lemma (`eval_bmcs_truth_lemma`) still has 4 sorries:
- **Box forward/backward** (lines 604, 611): Structural limitation - EvalBMCS only has coherence at eval_family, but the truth lemma needs the iff at ALL families
- **Temporal backward** (lines 625, 639): These could be solved by the same approach 857 used

### 3.3 The Box Case Problem in EvalBMCS

This is the critical issue that research-007 underestimated. The `eval_bmcs_truth_lemma` requires an iff (not just one direction) at ALL families, not just eval_family. Specifically:

```
Box case forward: Box psi in eval.mcs t -> for all fam', truth(psi) at fam'
  Needs: psi in fam'.mcs t -> truth(psi) at fam' [for non-eval fam']
  This requires the FULL truth lemma iff at non-eval families

Box case backward: (for all fam', truth(psi) at fam') -> Box psi in eval.mcs t
  Needs: truth(psi) at fam' -> psi in fam'.mcs t [for non-eval fam']
  This also requires the FULL truth lemma iff at non-eval families
```

The EvalBMCS only guarantees modal coherence at eval_family. For non-eval families, we do not have the inductive hypothesis of the truth lemma.

### 3.4 Assessment: EvalBMCS Path is Fundamentally Limited

The EvalBMCS truth lemma cannot be proven sorry-free because:
1. Truth semantics for Box requires truth at ALL families
2. The truth lemma iff must hold at ALL families (not just eval)
3. EvalBMCS lacks the inter-family coherence needed for non-eval families

**This is a structural limitation, not a missing lemma.** Research-007's claim that "EvalBMCS properties are SUFFICIENT for completeness" was incorrect for the box case of the truth lemma.

## 4. The Correct Path Forward

### 4.1 Two Distinct Problems

There are actually TWO separate axiom-removal problems:

| Problem | Axiom | Remediation |
|---------|-------|-------------|
| Modal backward | `singleFamily_modal_backward_axiom` | Multi-family saturated BMCS construction |
| Temporal saturation | `temporally_saturated_mcs_exists` | Modified Lindenbaum construction (temporalLindenbaumMCS) |

### 4.2 Eliminating `singleFamily_modal_backward_axiom` (Original Task 843 Goal)

The single-family construction uses the axiom because `phi in MCS -> Box phi in MCS` is not valid in modal logic. The fix requires a multi-family saturated BMCS where:
- Every Diamond formula has a witness family
- The contraposition argument then proves modal_backward

**What exists today** (in CoherentConstruction.lean):
- `CoherentBundle.toBMCS`: Converts saturated CoherentBundle to BMCS - PROVEN, no axioms
- `eval_saturated_bundle_exists`: Constructs an EvalCoherent + EvalSaturated bundle - PROVEN
- `diamond_boxcontent_consistent_constant`: Core consistency lemma - PROVEN

**What is missing**:
The `CoherentBundle.toBMCS` path requires a FULL `CoherentBundle.isSaturated` (saturation for ALL families, not just eval). This requires proving `saturated_extension_exists`, which is currently an axiom.

However, we do NOT need full `CoherentBundle` saturation. We need a construction that:
1. Has modal_forward and modal_backward for ALL families (not just eval)
2. Has temporal coherence for all families

### 4.3 The Hybrid Path: Saturated Multi-Family + Temporal Coherence

The most promising approach combines:

1. **For modal coherence**: Use the existing `eval_saturated_bundle_exists` construction, which produces an EvalCoherentBundle with EvalSaturated property. Then upgrade to a full BMCS.

2. **Key insight**: The current `bmcs_truth_lemma` works on a BMCS with `temporally_coherent` property. If we can build a BMCS that is:
   - Multi-family (with witnesses for Diamond formulas)
   - Has modal_forward and modal_backward proven (not axiom)
   - Is temporally coherent

   Then we eliminate BOTH axioms.

3. **For temporal coherence in multi-family**: All families must have forward_F and backward_P. For constant families (which is what CoherentBundle uses), temporal saturation of the underlying MCS gives these properties. The `temporally_saturated_mcs_exists` axiom could be replaced by the actual `temporalLindenbaumMCS` construction.

### 4.4 Concrete Steps

**Step 1: Implement `temporalLindenbaumMCS`** (eliminates `temporally_saturated_mcs_exists`)
- The `temporal_witness_seed_consistent` theorem is already proven
- Need: enumeration of formulas + modified Lindenbaum step + omega-step limit
- This was plan v003's Phase 1-2 but was not implemented by task 857
- Effort: 6-10 hours

**Step 2: Prove multi-family diamond-consistency for saturated constant families** (eliminates `singleFamily_modal_backward_axiom`)
- The singleton case is proven: `diamond_boxcontent_consistent_constant`
- The multi-family case requires `{psi} U UnionBoxContent(B)` consistency
- This is the same gap identified in CoherentConstruction.lean:846-851
- The EvalCoherent approach sidesteps this by only requiring BoxContent(eval_family)
- For full BMCS modal_backward, we need the stronger property
- Effort: 8-15 hours (this is the hardest step)

**Step 3: Build temporally coherent saturated BMCS** (combines steps 1-2)
- Use temporalLindenbaumMCS for each family construction
- All families are temporally saturated constant families
- Modal saturation via witness families
- Effort: 4-6 hours (integration)

**Step 4: Rewire completeness to use axiom-free BMCS**
- Replace `construct_temporal_bmcs` with the new construction
- Verify `bmcs_truth_lemma` still applies
- Effort: 2-3 hours

### 4.5 Alternative: Incremental Approach

If Step 2 (multi-family consistency) proves too difficult:

**Step 1 alone** eliminates `temporally_saturated_mcs_exists`. This reduces the completeness theorem from 2 axioms to 1 axiom. This is independently valuable.

**Step 2 can be deferred** since `singleFamily_modal_backward_axiom` is a separate concern. However, this leaves the original task 843 goal unmet.

## 5. Definitive Assessment

### 5.1 Current State

| Component | Sorries | Axioms | Status |
|-----------|---------|--------|--------|
| `bmcs_truth_lemma` | 0 | 0 (direct) | Publication-ready (pending axiom chain) |
| `bmcs_strong_completeness` | 0 | 0 (direct) | Publication-ready (pending axiom chain) |
| Completeness chain (transitive) | 0 | 2 | Requires axiom disclosure |
| `eval_bmcs_truth_lemma` | 4 | 0 | Not used by completeness; structural limitation |

### 5.2 Research-007 EvalBMCS Recommendation: REVISED

Research-007 was incorrect about EvalBMCS being sufficient for completeness. The box case of the truth lemma requires the full iff at ALL families, which EvalBMCS cannot provide. The 4 sorries in `eval_bmcs_truth_lemma` are structural, not fixable.

### 5.3 Recommended Next Step

**Immediate priority**: Implement `temporalLindenbaumMCS` to eliminate `temporally_saturated_mcs_exists`. This is the lower-hanging fruit:
- The consistency lemma is already proven (`temporal_witness_seed_consistent`)
- The mathematical approach is well-understood (standard Henkin construction)
- It reduces the axiom count from 2 to 1

**Medium-term priority**: Prove multi-family diamond-consistency to eliminate `singleFamily_modal_backward_axiom`. This is harder but is the original task 843 goal.

### 5.4 Blocking Issues

For `temporalLindenbaumMCS`: No mathematical blockers. Requires formula enumeration infrastructure and omega-step Lindenbaum construction. All necessary lemmas exist.

For multi-family modal backward: The core gap remains `{psi} U UnionBoxContent(B)` consistency when Diamond(psi) is in SOME family of B (not necessarily the only family). The K-distribution argument works when Box formulas come from the same family as the Diamond, but fails across families. The EvalCoherent approach sidesteps this but produces EvalBMCS (insufficient for full truth lemma).

## 6. Summary

| Question | Answer |
|----------|--------|
| What did 857 accomplish? | Eliminated truth lemma sorries; added 1 axiom (`temporally_saturated_mcs_exists`) |
| New axioms from 857? | Yes: `temporally_saturated_mcs_exists` in TemporalCoherentConstruction.lean |
| Current axiom count in completeness chain | 2 (`singleFamily_modal_backward_axiom` + `temporally_saturated_mcs_exists`) |
| Does EvalBMCS approach still apply? | No - it has a structural limitation in the box case |
| Concrete next step | Implement `temporalLindenbaumMCS` to eliminate `temporally_saturated_mcs_exists` (6-10 hours) |
| Can `singleFamily_modal_backward_axiom` be removed? | Yes, via multi-family saturated BMCS, but requires solving multi-family consistency gap (8-15 hours) |

## References

### Files Examined
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean` - Main truth lemma (sorry-free) + legacy EvalBMCS truth lemma (4 sorries)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/Construction.lean` - `singleFamily_modal_backward_axiom` declaration
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/Completeness.lean` - Sorry-free completeness theorems
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/CoherentConstruction.lean` - EvalBMCS infrastructure (proven)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` - `temporally_saturated_mcs_exists` axiom + proven infrastructure

### Prior Research
- `specs/843_remove_singleFamily_modal_backward_axiom/reports/research-007.md` - EvalBMCS recommendation (now revised)
- `specs/857_add_temporal_backward_properties/plans/implementation-003.md` - Task 857 plan (temporalLindenbaumMCS approach)
- `specs/857_add_temporal_backward_properties/summaries/implementation-summary-20260204-v3.md` - What 857 actually did
