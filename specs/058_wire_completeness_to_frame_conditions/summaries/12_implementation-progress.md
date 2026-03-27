# Implementation Progress Summary: Task #58

**Task**: wire_completeness_to_frame_conditions
**Plan**: v12 (restricted-truth-lemma-path)
**Date**: 2026-03-26
**Status**: PARTIAL

## Executive Summary

Analysis of the codebase revealed a mismatch between the plan's assumptions and actual code state. The 3 target sorries in `Completeness.lean` remain, but the path to resolution is now clearly documented.

## Phase Status

### Phase 1: Fix RestrictedTruthLemma.lean Sorries [BLOCKED]

**Finding**: The 3 sorries identified in the plan (lines 106, 115, 135) are in **unused helper lemmas** (`restricted_chain_G_propagates`, `restricted_chain_H_step`). The main `restricted_truth_lemma` theorem is already complete with no sorries.

**Resolution**: These sorries do not block completeness - they are dead code from exploratory development.

### Phase 2: Build TaskModel from RestrictedTemporallyCoherentFamily [PARTIAL]

**Infrastructure Added**:
- New section `Bimodal.Metalogic.Bundle.RestrictedCanonical` in `CanonicalConstruction.lean`
- Import of `SuccChainFMCS` and `RestrictedTruthLemma`
- Helper theorems `neg_in_mcs_implies_not_in_mcs` and `not_in_mcs_implies_not_true`
- Attempted `restricted_tc_family_to_fmcs` with documented sorries

**Gap Identified**: The independent Lindenbaum extensions at each chain position don't preserve the Succ relation. This means:
- forward_G/backward_H cannot be proven for extended chains with arbitrary formulas
- The connection between FMCS structure and BFMCS.temporally_coherent is broken

**Path Forward**: Two approaches documented in code:
1. Prove restricted completeness (bounded F/P-nesting formulas)
2. Build specialized single-family BFMCS for specific formula evaluation

### Phase 3: Wire to Completeness.lean [NOT STARTED]

Blocked by Phase 2 completion.

## Target Sorries (Unchanged)

| File | Line | Status | Blocker |
|------|------|--------|---------|
| Completeness.lean | 120 | OPEN | Model-theoretic glue |
| Completeness.lean | 163 | OPEN | Model-theoretic glue |
| Completeness.lean | 214 | OPEN | Model-theoretic glue |

## New Sorries (Documented)

| File | Line | Purpose |
|------|------|---------|
| CanonicalConstruction.lean | 873 | forward_G for restricted_tc_family_to_fmcs |
| CanonicalConstruction.lean | 876 | backward_H for restricted_tc_family_to_fmcs |

## Key Discoveries

1. **RestrictedTruthLemma is Complete**: The main truth lemma for restricted construction has no sorries.

2. **Infrastructure Gap**: The gap is not in the truth lemma but in converting the restricted construction to a form that `shifted_truth_lemma` can use.

3. **Bundle vs Family Coherence**:
   - `shifted_truth_lemma` requires family-level coherence (same family for F/P witnesses)
   - `construct_bfmcs_bundle` only provides bundle-level coherence (any family)
   - `RestrictedTemporallyCoherentFamily` provides family-level coherence but over DRMs not full MCS

4. **Lindenbaum Extension Problem**: Extending DRMs to full MCS via Lindenbaum produces independent sets that don't preserve the chain structure needed for forward_G/backward_H.

## Files Modified

- `Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean`: Added RestrictedCanonical section
- `specs/058_wire_completeness_to_frame_conditions/plans/12_restricted-truth-lemma-path.md`: Updated phase status

## Verification

- Build: PASSES (938 jobs)
- Sorry count in Completeness.lean: 3 (unchanged)
- New axioms: 0
- New sorries: 2 (documented, in exploratory code)

## Recommendation

The task requires additional research to resolve the Lindenbaum extension problem. The recommended path is approach #2 (specialized single-family construction) which builds a BFMCS specifically for evaluating the target formula, where F/P coherence only needs to hold for subformulas of that formula.

## Session

Session ID: sess_1774583649_35dca7
