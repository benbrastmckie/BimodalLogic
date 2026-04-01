# Implementation Summary: Task #81 (Round 12)

**Completed**: 2026-04-01
**Duration**: ~2 hours
**Status**: Partial

## Overview

Attempted to close the sorry in `constrained_successor_seed_restricted_consistent`
(SuccChainFMCS.lean). Discovered the theorem is **FALSE** and cannot be closed.
Provided sorry-free alternative infrastructure for targeted F-resolution.

## Key Discovery: Theorem is FALSE

**Counterexample**: If both `F(A)` and `F(neg A)` are in a DeferralRestrictedMCS `u`
(which is consistent — it means "A holds at some future time" and "not-A holds at
some other future time"), then both `A` and `neg A` are in `f_content(u)`, which is
a subset of the seed. The set `{A, neg A}` derives bot, so the seed is inconsistent.

**Root cause**: `f_content(u) = {psi | F(psi) in u}` includes both psi and psi.neg
when both F(psi) and F(psi.neg) are in u. Unlike `boundary_resolution_set` which has
a mutual exclusion guard (`F(chi.neg) not in u`), `f_content` has no such guard.

**Impact**: The entire chain of theorems depending on this sorry
(`restricted_forward_chain_F_resolves`, `restricted_forward_chain_forward_F`,
`build_restricted_tc_family`, and ultimately `completeness_over_Int`) cannot be
closed through this path.

## Sorry-Free Contributions

### 1. `single_target_with_g_content_consistent`
Generalizes `single_brs_element_with_g_content_consistent` to prove that
`{target} ∪ g_content(u)` is consistent for ANY target formula with `F(target) in u`.
Uses the G-wrapping technique from `temporal_theory_witness_consistent`.

### 2. Targeted Successor Construction
Built a complete sorry-free targeted successor infrastructure:
- `targeted_g_content_seed`: Definition of `{target} ∪ g_content(u)`
- `targeted_g_content_seed_subset_dc`: Seed is within deferralClosure
- `targeted_g_content_seed_consistent`: Seed is consistent (via G-wrapping)
- `targeted_successor`: Lindenbaum extension to DRM
- `targeted_successor_extends`: Seed ⊆ successor
- `targeted_successor_is_drm`: Successor is DeferralRestrictedMCS
- `targeted_successor_has_target`: Target formula in successor
- `targeted_successor_g_persistence`: g_content(u) ⊆ successor

All theorems verified sorry-free via `lean_verify`.

## Files Modified

- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`
  - Added `single_target_with_g_content_consistent` (sorry-free)
  - Added targeted successor construction (7 sorry-free definitions/theorems)
  - Updated docstrings on FALSE theorems with counterexample documentation
  - Updated `augmented_seed_consistent` docstring (also FALSE, reduces to main)

## Verification

- Build: Success (no regressions)
- New theorems: All sorry-free (verified via lean_verify)
- Existing sorries: Unchanged (3 in SuccChainFMCS.lean, cannot be closed)
- `completeness_over_Int`: Still has sorry (via `bfmcs_from_mcs_temporally_coherent`)
- `constrained_predecessor_seed_restricted_consistent`: Already sorry-free (unaffected)

## Phases Completed

| Phase | Status | Notes |
|-------|--------|-------|
| 1: Analyze seed components | COMPLETED | Identified theorem falsity, proved subset lemmas |
| 2: MCS witness argument | COMPLETED | Built targeted successor with G-wrapping consistency |
| 3: Close sorry | PARTIAL | Theorem is FALSE, documented counterexample |
| 4: Verify propagation | COMPLETED | Verified sorry landscape across codebase |
| 5: Completeness wiring | BLOCKED | Cannot proceed without F-resolution chain |

## Recommended Next Steps

1. **Restructure the chain to use targeted resolution**: Build a chain where each step
   uses `targeted_successor` to resolve one F-obligation. Combined with bounded F-nesting,
   this ensures all F-obligations resolve within bounded steps.

2. **Alternative: Use `temporal_theory_witness_exists` directly**: For the full MCS chain
   (not DRM-restricted), build the chain using the sorry-free `temporal_theory_witness_exists`
   at each step, targeting one F-obligation per step. This requires a fair scheduling
   argument to ensure all obligations eventually get resolved.

3. **Fix the seed definition**: Remove `f_content` from `constrained_successor_seed_restricted`
   (or add mutual exclusion guard). This would make the existing theorems provable but
   requires rewiring the F-resolution mechanism.

## Technical Notes

- The G-wrapping technique (generalized temporal K + DRM closure) is the key tool for
  seed consistency proofs. It works when the background set is G-liftable (g_content).
- Non-G-liftable elements (deferralDisjunctions, p_step_blocking) break the G-wrapping.
  Adding these to the seed alongside non-u targets makes consistency unprovable via G-wrapping.
- The predecessor seed does NOT include f_content or boundary_resolution_set, so it IS
  provably consistent (all components ⊆ u). The asymmetry is intentional.
