# Implementation Summary: Task 843 - Remove singleFamily_modal_backward_axiom

**Date**: 2026-02-04
**Status**: BLOCKED
**Session ID**: sess_1770232217_e791e8

## Summary

Task 843 attempted to eliminate `singleFamily_modal_backward_axiom` from Construction.lean by rewiring the completeness theorems to use the EvalBMCS infrastructure from task 856. The implementation revealed a fundamental limitation in the EvalBMCS structure that prevents this approach from working.

## Work Completed

### Phase 1: EvalBMCS Truth Definitions (COMPLETED)

Added to `BMCSTruth.lean`:
- `eval_bmcs_truth_at`: Truth definition for EvalBMCS (mirrors BMCS structure)
- `eval_bmcs_satisfies_context`: Context satisfaction predicate
- `eval_bmcs_truth_neg`, `eval_bmcs_truth_and`, `eval_bmcs_truth_or`, `eval_bmcs_truth_diamond`: Truth properties
- `eval_bmcs_truth_box_family_independent`, `eval_bmcs_truth_box_reflexive`: Box properties

### Phase 2: EvalBMCS Truth Lemma (BLOCKED)

Added to `TruthLemma.lean`:
- `eval_bmcs_truth_lemma`: Attempted proof with sorries in box cases
- `eval_bmcs_eval_truth`: Forward direction corollary

**Why Blocked**: The box case of the truth lemma requires membership ↔ truth at ALL families, not just eval_family. EvalBMCS only has:
- `modal_forward_eval`: Box phi in eval → phi in all families
- `modal_backward_eval`: phi in all families → Box phi in eval

These properties only work AT the eval_family, not FROM other families. The box forward case needs:
1. Box ψ ∈ eval.mcs t
2. By modal_forward_eval: ψ ∈ fam'.mcs t for all fam'
3. Convert ψ ∈ fam'.mcs t to truth of ψ at fam' (NEEDS IFF AT FAM')
4. Conclude truth of Box ψ at eval

Step 3 requires the full truth lemma IFF at non-eval families, which we can't prove because:
- The IH only gives us the IFF at eval_family
- For non-eval families, we'd need modal coherence there (which EvalBMCS doesn't have)

## Root Cause Analysis

The fundamental issue is that BMCS and EvalBMCS have different structural properties:

| Property | BMCS | EvalBMCS |
|----------|------|----------|
| `modal_forward` | At ALL families | Only at eval_family |
| `modal_backward` | At ALL families | Only at eval_family |
| Truth lemma IFF | Provable at ALL families | Only provable at eval_family |

The original `bmcs_truth_lemma` proves the IFF for ALL families simultaneously using mutual induction. This works because BMCS has modal coherence everywhere.

EvalBMCS was designed to be "sufficient for completeness" but the completeness proof actually needs the truth lemma's forward direction to work at ALL families (for the box case), not just eval_family.

## Impact on Axiom Removal

The `singleFamily_modal_backward_axiom` CANNOT be removed using the EvalBMCS approach because:

1. The axiom is used by `construct_bmcs` which produces a full BMCS
2. The completeness theorems use `bmcs_truth_lemma` which requires full BMCS
3. EvalBMCS is a weaker structure that cannot serve as a drop-in replacement
4. The EvalBMCS truth lemma has sorries in the box case

## Alternative Paths (Not Implemented)

1. **Strengthen EvalBMCS**: Add full modal coherence at all families, making it equivalent to BMCS. This would defeat the purpose of the simpler EvalBMCS structure.

2. **Prove multi-family truth lemma by well-founded induction**: Potentially provable if we can show that the box case at non-eval families never encounters nested boxes deeper than what's in eval. This requires complex formula-depth arguments.

3. **Use the FMP completeness approach**: The `semantic_weak_completeness` theorem in `FMP/SemanticCanonicalModel.lean` is already sorry-free and doesn't use BMCS at all. However, this doesn't help with the BMCS-based completeness theorems that are the target of this task.

4. **Complete the `saturated_extension_exists` proof**: This axiom in CoherentConstruction.lean, if proven, would enable full BMCS construction without `singleFamily_modal_backward_axiom`. This is a separate substantial task.

## Files Modified

- `Theories/Bimodal/Metalogic/Bundle/BMCSTruth.lean`: Added EvalBMCS truth definitions
- `Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean`: Added import and EvalBMCS truth lemma (with sorries)

## Recommendation

This task should be marked as **BLOCKED** pending one of:

1. **Research into multi-family truth lemma proof**: Investigate whether the specific structure of constructed EvalBMCS enables a proof that avoids the general limitation.

2. **Completion of task to prove `saturated_extension_exists`**: This would provide a true axiom-free path to full BMCS construction.

3. **Accept current axiom**: Document `singleFamily_modal_backward_axiom` as acceptable proof debt with clear justification (it captures a metatheoretic fact about canonical models).

The alternative FMP-based completeness (`semantic_weak_completeness`) is already sorry-free and provides the same logical guarantees, just through a different proof path.

## Build Status

The project builds successfully. All new code compiles. The sorries in `eval_bmcs_truth_lemma` are documented structural limitations, not implementation failures.
