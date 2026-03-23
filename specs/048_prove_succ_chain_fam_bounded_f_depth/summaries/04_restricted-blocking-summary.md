# Implementation Summary: Task #48 (v4) - Restricted Blocking

- **Status**: Partial (All phases attempted, Phase 5 partially complete)
- **Plan Version**: v4 (04_restricted-blocking.md)
- **Sessions**: sess_1774294560_4531d2, sess_1774295861_30ec13
- **Date**: 2026-03-23

## Overview

This implementation addresses the v3 blocker where `p_step_blocking_for_deferral_restricted` was FALSE as stated. The fix defines restricted P-step blocking formulas that only consider `P(chi)` where `P(chi) IN deferralClosure`.

## Key Changes

### Phase 1: Restricted P-Step Blocking Definition (COMPLETED)

**File**: `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean`

Added:
- `p_step_blocking_formulas_restricted` - Only blocks `P(chi)` where `P(chi) IN deferralClosure`
- `mem_p_step_blocking_formulas_restricted_iff` - Membership characterization
- `p_step_blocking_restricted_subset_deferralClosure` - Restricted blocking stays in closure

### Phase 2: Restricted Blocking Subset Theorem (COMPLETED)

**File**: `Theories/Bimodal/Metalogic/Core/RestrictedMCS.lean`

Added:
- `p_step_blocking_restricted_subset` - Proves restricted blocking formulas are subset of u for DeferralRestrictedMCS

This supersedes the broken `p_step_blocking_for_deferral_restricted` (which has a sorry in its else branch).

### Phase 3: Restricted Constrained Successor Seed (COMPLETED)

**File**: `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean`

Added:
- `constrained_successor_seed_restricted` - Seed using restricted P-step blocking
- `mem_constrained_successor_seed_restricted_iff`
- `g_content_subset_constrained_successor_seed_restricted`
- `deferralDisjunctions_subset_constrained_successor_seed_restricted`
- `p_step_blocking_restricted_subset_constrained_successor_seed_restricted`

**File**: `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`

Added:
- `constrained_successor_seed_restricted_subset_deferralClosure` - Seed stays in closure
- `g_content_subset_deferral_restricted_mcs` - g_content subset for DeferralRestrictedMCS
- `deferralDisjunctions_subset_deferral_restricted_mcs` - deferralDisjunctions subset
- `constrained_successor_seed_restricted_consistent` - Seed is consistent

### Phase 4: Restricted Constrained Successor Construction (COMPLETED)

**File**: `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`

Added:
- `constrained_successor_restricted` - Build successor from DeferralRestrictedMCS
- `constrained_successor_restricted_extends` - Successor extends seed
- `constrained_successor_restricted_is_mcs` - Successor is DeferralRestrictedMCS
- `constrained_successor_restricted_g_persistence` - G-persistence property
- `constrained_successor_restricted_f_step` - F-step property
- `constrained_successor_restricted_succ` - Succ relation
- `constrained_successor_restricted_p_step` - P-step property

**File**: `Theories/Bimodal/Theorems/Propositional.lean`

Added:
- `or_elim_neg_neg` - Disjunction elimination from both negations

### Phase 5: Chain Construction (PARTIAL)

**File**: `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`

Added (forward chain infrastructure):
- `DeferralRestrictedSerialMCS` - Serial MCS structure with F_top and P_top
- `RestrictedForwardChainElement` - Forward chain element bundle
- `restricted_forward_chain` - Forward chain construction
- `restricted_forward_chain_is_drm` - Chain elements are DeferralRestrictedMCS
- `restricted_forward_chain_has_F_top` - F_top membership
- `restricted_forward_chain_succ` - Adjacent elements satisfy Succ
- `restricted_forward_chain_p_step` - P-step property
- `restricted_forward_chain_F_bounded` - F-nesting bound
- `restricted_forward_chain_canonicalTask_forward_from` - Chain for witnesses
- `restricted_forward_chain_F_step_witness` - Single-step F witness

**Not completed** (requires additional infrastructure):
- `constrained_predecessor_restricted` - Symmetric predecessor construction
- `restricted_backward_chain` - Backward chain for P-direction
- `restricted_succ_chain_fam` - Combined Int-indexed chain

## Sorries in Modified Files

### New Sorries (requiring follow-up)

| File | Line | Description | Root Cause |
|------|------|-------------|------------|
| SuccChainFMCS.lean | 1930 | `F_top_in_restricted_successor` | Needs F_top IN deferralClosure |
| SuccChainFMCS.lean | 2104 | `restricted_forward_chain_forward_F` | Needs restricted bounded_witness |
| SuccChainFMCS.lean | 2159 | `toSerialMCS.is_mcs` | Coercion to full MCS |

### Deprecated Sorries (intentionally kept)

| File | Line | Description | Status |
|------|------|-------------|--------|
| SuccChainFMCS.lean | 736 | `f_nesting_is_bounded` | Mathematically FALSE for arbitrary MCS |
| SuccChainFMCS.lean | 971 | `p_nesting_is_bounded` | Mathematically FALSE for arbitrary MCS |
| RestrictedMCS.lean | 1124 | `p_step_blocking_for_deferral_restricted` else branch | Superseded by restricted version |

## Technical Insights

1. **F_top propagation challenge**: For F_top to propagate through restricted successors, we need F_top IN deferralClosure(phi). Solutions:
   - Ensure phi includes seriality formulas in its closure
   - Prove disjunction elimination for DeferralRestrictedMCS with deferral disjunctions

2. **bounded_witness requires MCS**: The existing `bounded_witness` uses `SetMaximalConsistent` for negation completeness. A DeferralRestrictedMCS variant needs:
   - Restricted negation completeness for formulas in closure
   - Proof that F-iterations stay in closure until they exit

3. **Backward chain needs symmetric infrastructure**: The P-direction chain requires `constrained_predecessor_restricted` mirroring the successor construction.

## Verification

```bash
$ lake build Bimodal.Metalogic.Bundle.SuccChainFMCS
Build completed successfully (739 jobs)
```

- Build passes: Yes
- Total sorries: 5 (2 deprecated legacy + 3 new requiring follow-up)
- Key theorem `p_step_blocking_restricted_subset` proven without sorry: Yes

## Recommendations for Follow-up

1. **Closure seriality**: Modify deferralClosure construction to always include F_top and P_top
2. **Restricted bounded_witness**: Create a variant of bounded_witness for DeferralRestrictedMCS
3. **Backward chain**: Build constrained_predecessor_restricted symmetric to the successor
4. **Full chain**: Combine forward/backward into restricted_succ_chain_fam
