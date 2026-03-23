# Implementation Summary: Task #48 (v4) - Restricted Blocking

- **Status**: Partial (Phases 1-4 complete, Phase 5 partial)
- **Plan Version**: v4 (04_restricted-blocking.md)
- **Session**: sess_1774294560_4531d2
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

The restricted successor construction is complete. The chain construction itself (building sequences of restricted successors) was not completed in this session but the foundation is in place.

## Remaining Work

1. Define `restricted_forward_chain` using `constrained_successor_restricted`
2. Define `restricted_backward_chain` for P-direction
3. Define `restricted_succ_chain_fam` combining forward and backward
4. Prove F/P-nesting coherence using the bounded depth theorems
5. Add coercion from restricted chain to standard chain type

## Sorries Remaining in Modified Files

| File | Line | Description | Status |
|------|------|-------------|--------|
| SuccChainFMCS.lean | 736 | `f_nesting_is_bounded` | Deprecated (mathematically FALSE) |
| SuccChainFMCS.lean | 971 | `p_nesting_is_bounded` | Deprecated (mathematically FALSE) |
| RestrictedMCS.lean | 1124 | `p_step_blocking_for_deferral_restricted` else branch | Superseded by `p_step_blocking_restricted_subset` |

The deprecated sorries are for theorems that are mathematically false for arbitrary MCS. The migration path is to use the `_restricted` versions which work with RestrictedMCS.

## Verification

- Build passes: Yes
- No new sorries in new code: Yes (all sorries are in deprecated or superseded code)
- Key theorem `p_step_blocking_restricted_subset` proven without sorry: Yes

## Next Steps

To complete Task 48, a follow-up implementation should:
1. Complete Phase 5 by building the restricted chain construction
2. Wire up the coherence proofs
3. Potentially deprecate or remove the old `p_step_blocking_for_deferral_restricted` theorem
