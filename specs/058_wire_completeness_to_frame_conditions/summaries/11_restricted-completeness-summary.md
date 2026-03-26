# Implementation Summary: Task #58 - Restricted Completeness

**Task**: 58 - wire_completeness_to_frame_conditions
**Status**: PARTIAL
**Session**: sess_1774552842_e97593
**Date**: 2026-03-26

## Overview

This session implemented Phase 2 (Restricted Bidirectional Truth Lemma) of the restricted completeness approach for task #58. Phase 1 was marked [COMPLETED] in the plan but had sorries in `build_restricted_tc_family` (lines 3892, 3917 in SuccChainFMCS.lean).

## Work Completed

### Phase 2: RestrictedTruthLemma.lean (NEW FILE)

Created `Theories/Bimodal/Metalogic/Algebraic/RestrictedTruthLemma.lean` with:

1. **FMCS Construction** (`restricted_chain_to_fmcs`)
   - Converts `RestrictedTemporallyCoherentFamily` to `FMCS Int`
   - Uses `lindenbaumMCS_set` to extend DeferralRestrictedMCS to full MCS
   - FMCS fields `forward_G` and `backward_H`: sorry (lines 91, 95)

2. **Temporal Coherence Lifting**
   - `restricted_fmcs_forward_F`: Forward F coherence for extended FMCS (sorry, line 122)
   - `restricted_fmcs_backward_P`: Backward P coherence for extended FMCS (sorry, line 138)

3. **Embedding Theorems**
   - `restricted_chain_subset_extended`: DRM subset of extended MCS (PROVEN)
   - `extended_fmcs_closure_subset`: Converse for closure formulas (sorry, line 185)

4. **Main Truth Lemma**
   - `restricted_truth_lemma`: Biconditional for membership in restricted chain vs extended FMCS (PROVEN, uses above theorems)
   - `restricted_truth_at_seed`: Corollary for target formula at time 0 (PROVEN)

### Key Insights

1. **Approach**: Rather than building new frame/model infrastructure, leverage existing `FMCS`/`lindenbaumMCS_set` infrastructure
2. **Embedding Strategy**: Show restricted chain membership is equivalent to extended MCS membership for closure formulas
3. **Main Lemma Structure**: Truth lemma reduces to proving the embedding is a biconditional for subformulaClosure formulas

## Sorry Inventory

### RestrictedTruthLemma.lean (5 sorries)
| Line | Location | Description |
|------|----------|-------------|
| 91 | `restricted_chain_to_fmcs.forward_G` | G-persistence through Succ relation |
| 95 | `restricted_chain_to_fmcs.backward_H` | H-persistence through Succ relation |
| 122 | `restricted_fmcs_forward_F` | Lift forward_F from tc_fam to extended FMCS |
| 138 | `restricted_fmcs_backward_P` | Lift backward_P from tc_fam to extended FMCS |
| 185 | `extended_fmcs_closure_subset` | Converse embedding using DRM maximality |

### SuccChainFMCS.lean (Pre-existing, Phase 1)
| Lines | Location | Description |
|-------|----------|-------------|
| 3892 | `build_restricted_tc_family.forward_F` | F in backward chain case |
| 3917 | `build_restricted_tc_family.backward_P` | P in forward chain case |
| 3824 | `restricted_backward_bounded_witness` | Termination proof |
| + others | Various | Pre-existing infrastructure sorries |

## Build Status

- `lake build`: SUCCESS (937 jobs)
- No new axioms introduced
- Warnings only (unused variables, sorry declarations)

## Next Steps

### To Complete Phase 2
1. Prove `forward_G` and `backward_H` in FMCS structure (use Succ/G-persistence)
2. Prove `restricted_fmcs_forward_F` and `restricted_fmcs_backward_P` (key: formulas in extended MCS that have F/P structure come from the original chain)
3. Prove `extended_fmcs_closure_subset` (use DRM maximality within deferralClosure)

### To Complete Phase 1
1. Fill sorries in `build_restricted_tc_family` (cross-chain coherence)
2. Fix termination proof in `restricted_backward_bounded_witness`

### Phase 3-4 (Blocked)
- Requires Phase 1 and 2 completion
- Phase 3: Lifting to full completeness
- Phase 4: Wire to FrameConditions/Completeness.lean

## Files Modified

| File | Change |
|------|--------|
| `Theories/Bimodal/Metalogic/Algebraic/RestrictedTruthLemma.lean` | NEW: 205 lines |
| `specs/058.../plans/10_restricted-completeness.md` | Phase 2 status: IN PROGRESS -> PARTIAL |

## Verification Results

```
Build: SUCCESS
New axioms: 0
RestrictedTruthLemma.lean sorries: 5
Total project sorry count (Metalogic): increased by 5
```
