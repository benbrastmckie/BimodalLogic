# Dead Code Inventory for SuccChainFMCS.lean and RestrictedMCS.lean

## Summary

This report inventories dead code targeted for removal from:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` (4542 lines)
- `Theories/Bimodal/Metalogic/Core/RestrictedMCS.lean` (1603 lines)

**Estimated removal**: ~2000 lines from SuccChainFMCS.lean, ~175 lines from RestrictedMCS.lean

## 1. Deprecated Theorems (Mathematically FALSE for Arbitrary MCS)

### 1.1 f_nesting_is_bounded (SuccChainFMCS.lean)

| Property | Value |
|----------|-------|
| **Lines** | 753-757 |
| **Type** | theorem |
| **Status** | Deprecated with `@[deprecated f_nesting_is_bounded_restricted]` |
| **Reason** | Mathematically FALSE: An MCS can consistently contain {F^n(p) \| n in Nat} |
| **Sorry** | Line 757 |
| **Used By** | f_nesting_boundary (line 782) |

### 1.2 f_nesting_boundary (SuccChainFMCS.lean)

| Property | Value |
|----------|-------|
| **Lines** | 782-786 |
| **Type** | theorem |
| **Status** | Deprecated with `@[deprecated f_nesting_boundary_restricted]` |
| **Reason** | Depends on f_nesting_is_bounded |
| **Used By** | succ_chain_forward_F_neg (line 801), succ_chain_forward_F (line 861) |

### 1.3 p_nesting_is_bounded (SuccChainFMCS.lean)

| Property | Value |
|----------|-------|
| **Lines** | 1005-1009 |
| **Type** | theorem |
| **Status** | Deprecated with `@[deprecated p_nesting_is_bounded_restricted]` |
| **Reason** | Mathematically FALSE: symmetric to f_nesting_is_bounded |
| **Sorry** | Line 1009 |
| **Used By** | p_nesting_boundary (line 1022) |

### 1.4 p_nesting_boundary (SuccChainFMCS.lean)

| Property | Value |
|----------|-------|
| **Lines** | 1022-1026 |
| **Type** | theorem |
| **Status** | Deprecated with `@[deprecated p_nesting_boundary_restricted]` |
| **Reason** | Depends on p_nesting_is_bounded |
| **Used By** | succ_chain_backward_P (line 1143) |

## 2. Theorems Depending on Deprecated Nesting Bounds

### 2.1 succ_chain_forward_F_neg (SuccChainFMCS.lean)

| Property | Value |
|----------|-------|
| **Lines** | 794-826 |
| **Type** | theorem |
| **Reason** | Calls f_nesting_boundary (line 801) |
| **Transitively Used By** | succ_chain_forward_F |

### 2.2 succ_chain_forward_F (SuccChainFMCS.lean)

| Property | Value |
|----------|-------|
| **Lines** | 850-886 |
| **Type** | theorem |
| **Status** | Deprecated with custom message |
| **Reason** | Uses f_nesting_boundary (line 861) and succ_chain_forward_F_neg (line 885) |
| **Used By** | SuccChainTemporalCoherent (line 1227) |

### 2.3 succ_chain_backward_P (SuccChainFMCS.lean)

| Property | Value |
|----------|-------|
| **Lines** | 1137-1169 |
| **Type** | theorem |
| **Reason** | Uses p_nesting_boundary (line 1143) |
| **Used By** | SuccChainTemporalCoherent (line 1228) |

### 2.4 SuccChainTemporalCoherent (SuccChainFMCS.lean)

| Property | Value |
|----------|-------|
| **Lines** | 1225-1228 |
| **Type** | noncomputable def |
| **Status** | Deprecated with custom message |
| **Reason** | Uses succ_chain_forward_F and succ_chain_backward_P |
| **Used By** | UltrafilterChain.lean (comment references only) |

## 3. restricted_succ_propagates_F_not Variants (9 Sorries, Proven FALSE)

### 3.1 restricted_single_step_forcing (SuccChainFMCS.lean)

| Property | Value |
|----------|-------|
| **Lines** | 2392-3141 |
| **Line Count** | ~749 lines |
| **Type** | theorem |
| **Sorries** | Line 3141 (boundary case FF(psi) not in deferralClosure) |
| **Status** | Contains sorry; boundary case proven FALSE |

### 3.2 restricted_succ_propagates_F_not (SuccChainFMCS.lean)

| Property | Value |
|----------|-------|
| **Lines** | 3151-3191 |
| **Line Count** | ~40 lines |
| **Type** | theorem |
| **Sorries** | Lines 3173, 3187 |
| **Status** | Contains sorries for both in-closure and out-of-closure cases |

### 3.3 restricted_succ_propagates_F_not' (SuccChainFMCS.lean)

| Property | Value |
|----------|-------|
| **Lines** | 3213-4076 |
| **Line Count** | ~863 lines (includes extensive comments analyzing why it's FALSE) |
| **Type** | theorem |
| **Sorries** | Lines 3258, 3836, 4064, 4076 |
| **Status** | Proven FALSE in comments (lines 4057-4058) |

### 3.4 restricted_single_step_forcing' (SuccChainFMCS.lean)

| Property | Value |
|----------|-------|
| **Lines** | 4089-4112 |
| **Line Count** | ~23 lines |
| **Type** | theorem |
| **Status** | Depends on restricted_succ_propagates_F_not' |

### 3.5 restricted_bounded_witness (SuccChainFMCS.lean)

| Property | Value |
|----------|-------|
| **Lines** | 4128-4192 |
| **Line Count** | ~64 lines |
| **Type** | theorem |
| **Status** | Depends on restricted_single_step_forcing and restricted_succ_propagates_F_not |

## 4. RestrictedMCS.lean Dead Code

### 4.1 p_step_blocking_for_deferral_restricted (RestrictedMCS.lean)

| Property | Value |
|----------|-------|
| **Lines** | 945-1120 |
| **Line Count** | ~175 lines |
| **Type** | theorem |
| **Sorries** | Line 1120 (else branch) |
| **Status** | FALSE as stated; superseded by p_step_blocking_restricted_subset |
| **Note** | Already has corrected version (p_step_blocking_restricted_subset, lines 1136+) |

## 5. Dependency Chain Summary

```
f_nesting_is_bounded (FALSE)
  -> f_nesting_boundary
    -> succ_chain_forward_F_neg
    -> succ_chain_forward_F
      -> SuccChainTemporalCoherent

p_nesting_is_bounded (FALSE)
  -> p_nesting_boundary
    -> succ_chain_backward_P
      -> SuccChainTemporalCoherent

restricted_single_step_forcing (has sorry)
  -> restricted_bounded_witness
    -> restricted_forward_chain_iter_F_witness
      -> restricted_forward_chain_forward_F

restricted_succ_propagates_F_not' (FALSE)
  -> restricted_single_step_forcing'
```

## 6. Recommended Deletion Order

**Phase 1: Remove FALSE restricted variants (safe, no external dependencies)**

1. `restricted_succ_propagates_F_not'` (lines 3213-4076) - ~863 lines
2. `restricted_single_step_forcing'` (lines 4089-4112) - ~23 lines
3. `restricted_succ_propagates_F_not` (lines 3151-3191) - ~40 lines

**Phase 2: Remove single_step_forcing and bounded_witness (depend on Phase 1)**

4. `restricted_bounded_witness` (lines 4128-4192) - ~64 lines
5. `restricted_single_step_forcing` (lines 2392-3141) - ~749 lines

**Phase 3: Remove deprecated nesting bounds and dependents**

6. `SuccChainTemporalCoherent` (lines 1225-1228) - ~4 lines
7. `succ_chain_backward_P` (lines 1137-1169) - ~32 lines
8. `succ_chain_forward_F` (lines 850-886) - ~36 lines
9. `succ_chain_forward_F_neg` (lines 794-826) - ~32 lines
10. `p_nesting_boundary` (lines 1022-1026) - ~4 lines
11. `p_nesting_is_bounded` (lines 1005-1009) - ~4 lines
12. `f_nesting_boundary` (lines 782-786) - ~4 lines
13. `f_nesting_is_bounded` (lines 753-757) - ~4 lines

**Phase 4: RestrictedMCS.lean cleanup**

14. `p_step_blocking_for_deferral_restricted` (lines 945-1120) - ~175 lines

## 7. Verification of Non-Usage

All items were verified to have no external usages:

1. **f_nesting_is_bounded / p_nesting_is_bounded**: Only used in same file by deprecated theorems
2. **restricted_succ_propagates_F_not variants**: Only used in same file by other dead code
3. **SuccChainTemporalCoherent**: Referenced in UltrafilterChain.lean comments only, not called
4. **p_step_blocking_for_deferral_restricted**: Superseded by p_step_blocking_restricted_subset in same file

## 8. Estimated Line Reduction

| File | Lines to Remove | Original Size |
|------|-----------------|---------------|
| SuccChainFMCS.lean | ~1859 lines | 4542 lines |
| RestrictedMCS.lean | ~175 lines | 1603 lines |
| **Total** | **~2034 lines** | 6145 lines |

## 9. Risks

### Low Risk
- All dead code is self-contained within the same files
- Deprecated annotations are already in place
- Comments document why theorems are FALSE

### Considerations
- Keep `f_nesting_is_bounded_restricted` and `p_nesting_is_bounded_restricted` - these WORK for RestrictedMCS
- Keep `p_step_blocking_restricted_subset` - this is the corrected version
- Keep `restricted_forward_chain_forward_F` - needs reimplementation via Lindenbaum extension approach
- Update summary section at end of file (lines 4486-4540) after cleanup
