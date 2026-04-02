# Execution Summary: Task #81 - F/P Witness Representation Theorem

- **Task**: 81 - F/P Witness Representation Theorem
- **Status**: PARTIAL (Phase 1 partial, Phases 2-4 blocked)
- **Session**: sess_1743559200_impl81r2
- **Date**: 2026-04-02

## Overview

Attempted to close the sorry in `bfmcs_from_mcs_temporally_coherent` (Completeness.lean:237) by proving fuel exhaustion is unreachable in the restricted bounded witness functions. Deep analysis revealed a fundamental gap in the `constrained_predecessor_restricted` construction that prevents the fuel=0 sorries from being closed with the current infrastructure.

## Key Contributions

### 1. Targeted Predecessor Construction (sorry-free, NEW)

Added to `SuccChainFMCS.lean` (after line 1801):

- **`single_target_with_h_content_consistent`**: Proves `{target} ∪ h_content(u)` is consistent when `P(target) ∈ u` and `u` is a DeferralRestrictedMCS. This is the P-direction analog of the existing F-direction `single_target_with_g_content_consistent`.

- **`targeted_predecessor`**: Constructs a DeferralRestrictedMCS extending `{target} ∪ h_content(u)`, proving that:
  - The target formula is in the predecessor (`targeted_predecessor_contains_target`)
  - The predecessor is a DeferralRestrictedMCS (`targeted_predecessor_is_drm`)
  - H-content of the original MCS is preserved

These are foundational building blocks for a future modified backward chain construction.

### 2. Critical Analysis: f_step_blocking Prevents P-Resolution

**Finding**: The `constrained_predecessor_restricted` seed includes `f_step_blocking_formulas_restricted`, which adds `G(neg chi)` for formulas chi where `F(chi) ∉ u AND chi ∉ u`. When `P(chi) ∈ u` (P-obligation exists) but `chi ∉ u` and `F(chi) ∉ u`, the blocking formula `G(neg chi)` enters the seed, and:

1. `G(neg chi)` in the seed propagates to `neg(chi)` in the predecessor (by T-axiom of G)
2. The `pastDeferralDisjunction` `chi ∨ P(chi)` resolves to `P(chi)` (since `neg(chi)` blocks `chi`)
3. P(chi) defers permanently in the chain

This means `restricted_backward_bounded_witness` (and its fueled version) makes a claim that is **not provable** with the current predecessor construction. The fuel=0 sorry represents a genuine gap, not just a proof engineering challenge.

### 3. Forward Direction is Unaffected

The forward chain's F-resolution (`restricted_forward_chain_F_resolves`) is sorry-free because the forward successor seed includes `f_content(u)` directly (not just deferralDisjunctions). This asymmetry is by design but creates the P-direction gap.

## Dependency Analysis

```
bfmcs_from_mcs_temporally_coherent (Completeness.lean:237)
  └── needs family-level forward_F and backward_P
      └── boxClassFamilies uses SuccChainFMCS (unrestricted chain)
          └── unrestricted chain has NO forward_F or backward_P
              (F/P can defer indefinitely in full MCS)
      └── restricted chain has forward_F (sorry-free)
      └── restricted chain backward_P depends on fuel=0 sorry
          └── fuel=0 is NOT closeable (f_step_blocking blocks P-resolution)
```

## Path Forward (Recommended)

### Option A: Modified Backward Chain (Most Promising)

Modify `constrained_predecessor_restricted` to resolve P-obligations rather than defer them. Specifically:

1. Replace `pastDeferralDisjunctions` with direct `p_content` in the seed
2. Adjust `f_step_blocking` to exclude formulas in `p_content` (to avoid inconsistency)
3. Prove the modified seed is consistent (the `targeted_predecessor` construction proves this for the special case)
4. Re-prove all dependent theorems with the modified predecessor

**Estimated effort**: 8-12 hours (significant restructure of backward chain)

### Option B: Restructured boxClassFamilies

Replace `boxClassFamilies` to use restricted chain families extended to full MCS, rather than unrestricted SuccChainFMCS. This avoids the need for unrestricted chain forward_F/backward_P entirely.

**Estimated effort**: 10-15 hours (restructure of UltrafilterChain.lean and Completeness.lean)

### Option C: Alternative Completeness Path

Use the restricted truth lemma path (RestrictedTruthLemma.lean + SuccChainCompleteness.lean) instead of the BFMCS bundle path. This bypasses the `bfmcs_from_mcs_temporally_coherent` sorry entirely.

**Estimated effort**: 6-10 hours (requires RestrictedTruthLemma sorries to be addressed)

## Files Modified

- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`: Added targeted predecessor construction (~200 lines, sorry-free)

## Files NOT Modified (No Regressions)

- `Theories/Bimodal/FrameConditions/Completeness.lean`: Sorry at line 237 remains
- All other files: Unchanged, build passes

## Verification

- `lake build`: Passes (938 jobs)
- New code: Zero sorries introduced
- Existing sorries: Unchanged (6 in SuccChainFMCS.lean, 2 in Completeness.lean)
- No new axioms introduced
