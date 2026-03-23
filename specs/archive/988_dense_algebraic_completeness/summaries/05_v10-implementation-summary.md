# Implementation Summary: Task #988 - Dense Algebraic Completeness (Plan v10)

**Date**: 2026-03-19
**Status**: BLOCKED
**Session ID**: sess_1773942570_45c1de

## Objective

Prove dense algebraic completeness using D = Rat by connecting DovetailedCoverage's sorry-free `has_future`/`has_past` lemmas to TimelineQuot via bridges.

## Investigation Summary

### Architecture Analysis

The task requires filling sorries in `CanonicalEmbedding.lean`:
- `ratFMCS_forward_F` (line 181)
- `ratFMCS_backward_P` (line 192)
- `ratBFMCS.modal_backward` (line 231)
- `ratFMCS_root_eq` (line 280)
- `construct_bfmcs_rat_for_root` (line 299)

### Key Findings

1. **DovetailedCoverage provides CanonicalR witnesses, not phi-witnesses**
   - `dovetailedTimeline_has_future` gives: exists q with CanonicalR(p.mcs, q.mcs)
   - Does NOT give: phi in q.mcs (needed for forward_F)

2. **DenseTimeline has the same limitation**
   - `dense_timeline_has_future` gives CanonicalR witnesses
   - Does NOT give phi-witnesses

3. **The Boneyard has more complete attempts but with sorries**
   - `Boneyard/Task994_DovetailedQuot/DovetailedTimelineQuot.lean` has:
     - `dovetailedTimelineQuotFMCS_forward_F` - nearly complete
     - `dovetailedTimelineQuotFMCS_backward_P` - nearly complete
   - But sorries remain in `forward_F_chain_witness` for the `j > 0` case

4. **The "late entry" gap**
   - When point p enters the build at stage m > 2k (where k = encoding of phi)
   - The staged construction already processed phi at stage 2k+1
   - So p's F(phi) obligation wasn't processed
   - DovetailedCoverage handles this via dovetailing but the `j > 0` chain is incomplete

5. **Existing file has build errors**
   - `CanonicalEmbedding.lean` was created with type errors in prior iteration
   - Errors in variable handling for `construct_bfmcs_rat`

### Blocking Issues

1. **Mathematical gap**: The chain witness lemmas (`forward_F_chain_witness`, `backward_P_chain_witness`) need the `j > 0` case proved. This requires showing that when we iterate through larger encodings, we eventually reach the original phi.

2. **Architectural gap**: Two separate constructions exist:
   - `denseTimelineUnion` (StagedPoint-based, used by TimelineQuot)
   - `dovetailedTimelineUnion` (DovetailedPoint-based, has better coverage lemmas)
   These are not connected; transferring results between them is non-trivial.

3. **Build state**: The `CanonicalEmbedding.lean` file has pre-existing type errors that need resolution before new code can be added.

## Recommendations for Next Iteration

### Option A: Complete the chain witness proofs (Recommended)
1. Restore `DovetailedTimelineQuot.lean` from Boneyard
2. Prove the `j > 0` case in `forward_F_chain_witness`:
   - Use well-founded recursion on (build_stage, formula_depth)
   - Each iteration increases build_stage, even if formula_depth increases
3. Similar fix for `backward_P_chain_witness`

### Option B: Unify the constructions
1. Prove `dovetailedTimelineUnion` and `denseTimelineUnion` are equal (or related)
2. This would allow DovetailedCoverage lemmas to apply to TimelineQuot

### Option C: Fix at the FMCS level
1. Define `ratFMCS` directly using DovetailedTimelineQuot instead of TimelineQuot
2. The Cantor isomorphism works for both constructions

## Files Examined

- `Theories/Bimodal/Metalogic/Algebraic/CanonicalEmbedding.lean` - Main file with sorries
- `Theories/Bimodal/Metalogic/StagedConstruction/DovetailedCoverage.lean` - Sorry-free has_future/has_past
- `Theories/Bimodal/Metalogic/StagedConstruction/DenseTimeline.lean` - TimelineQuot basis
- `Theories/Bimodal/Metalogic/StagedConstruction/ClosureSaturation.lean` - Partial forward_F proof
- `Theories/Bimodal/Boneyard/Task994_DovetailedQuot/DovetailedTimelineQuot.lean` - Most complete attempt

## Metrics

- Phases attempted: 1 (BLOCKED)
- Phases completed: 0
- Sorries eliminated: 0
- Build status: File has pre-existing errors
