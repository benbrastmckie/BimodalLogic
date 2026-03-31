# Medium Confidence Dead Code Analysis

**Task**: 80 - ultrafilter_dead_code_audit
**Follow-up to**: 01_dead-code-audit.md
**Session**: sess_1774989644_e948ec

## Executive Summary

All items previously classified as "medium confidence" or "investigate before removal" have been verified. **All are confirmed ARCHIVE candidates** with no downstream dependencies in the active completeness path.

**Key Finding**: Line 7082 from the first report is a **false positive** - the comment mentions "sorry" but the actual proof at lines 7084-7105 is complete with no sorry keyword.

## Active Completeness Path Dependencies

The active completeness path in `Completeness.lean` uses:

| Definition | Location | Status |
|------------|----------|--------|
| `BFMCS_Bundle` | UltrafilterChain.lean:5653 | ACTIVE |
| `construct_bfmcs_bundle` | UltrafilterChain.lean:5748 | ACTIVE |
| `bundle_to_bfmcs` | Completeness.lean:185 | ACTIVE |
| `construct_bfmcs_bundle_eval_at_zero` | UltrafilterChain.lean:5764 | ACTIVE |
| `boxClassFamilies_*` | UltrafilterChain.lean:4452-5634 | ACTIVE |
| `SuccChainFMCS` | SuccChainFMCS.lean | ACTIVE |

These are **NOT** dependent on any of the medium-confidence items.

## Medium Confidence Items Analysis

### 1. Z_chain Construction (Lines 5088-5369)

**Status**: ARCHIVE

**Definitions**:
- `Z_chain` (line 5112)
- `Z_chain_mcs` (line 5123)
- `Z_chain_box_class` (line 5134)
- `Z_chain_zero` (line 5145)
- `Z_chain_forward_G` (line 5203)
- `Z_chain_backward_H` (line 5283) - sorry at 5287
- `OmegaFMCS` (line 5295)
- `OmegaFMCS_zero` (line 5304)
- `Z_chain_forward_F` (line 5330) - sorry at 5352
- `Z_chain_backward_P` (line 5360) - sorry at 5369

**External References**: None. The `Z_chain` functions are referenced ONLY in:
1. Completeness.lean lines 226, 348 - **comments only**, not code
2. UltrafilterChain.lean itself - internal definitions

**Reason**: The Z_chain approach was abandoned because it uses `omega_chain_forward/backward` which don't guarantee F/P-resolution. The comment at line 5350-5351 explicitly states: "This sorry represents the gap between Z_chain and F-preserving chain."

**Sorries**: 5251, 5273, 5287, 5352, 5369 (5 sorries)

**Estimated Lines**: ~280 lines (5088-5369)

### 2. Omega Chain Non-F-Preserving Theorems (Lines 6377-6579)

**Status**: ARCHIVE

**Definitions**:
- `omega_forward_F_persistence_or_resolution` (line 6377) - sorry at 6487
- `omega_forward_F_bounded_persistence` (line 6500) - sorry at 6510
- `Z_chain_forward_F'` (line 6518) - sorry at 6551

**External References**: None. Used only by:
- `Z_chain_forward_F'` uses `omega_forward_F_bounded_persistence`
- No external files import these

**Reason**: These theorems attempt to prove F-resolution for the basic omega chain, which lacks the dovetailed F-resolution guarantee. Comment at line 6509: "For non-F-preserving chain, we note that the resolution eventually happens but proving it requires tracking F-obligations explicitly."

**Sorries**: 6487, 6510, 6551 (3 sorries)

**Estimated Lines**: ~200 lines (6377-6579)

### 3. P-Preserving Seed Construction (Lines 7116-7563)

**Status**: ARCHIVE

**Definitions**:
- `P_unresolved_theory` (line 7145)
- `P_unresolved_theory_subset_M` (line 7151)
- `p_preserving_seed` (line 7165)
- Various p_preserving_seed subset theorems (7171-7221)
- `p_preserving_seed_consistent` (line 7237) - sorries at 7426, 7448
- `past_theory_witness_P_preserving` (line 7512)

**External References**: None. These are used only internally within UltrafilterChain.lean by:
- `omega_step_backward_P_preserving` (line 7570)
- Which feeds into `CoherentZChain` (also dead code)

**Reason**: The P-preserving seed is symmetric to the F-preserving seed approach. Both approaches hit the same structural gap: the "sub-case (b)" problem where cross-direction temporal formulas cannot be properly handled.

**Sorries**: 7426, 7448 (2 sorries)

**Estimated Lines**: ~445 lines (7116-7563)

### 4. Line 7082 Investigation

**Status**: FALSE POSITIVE - No sorry here

**Details**: The previous report listed line 7082 as having a sorry. Investigation reveals:
- Line 7082 contains a **comment**: `-- For now, use sorry and complete this in Phase 6A refinement.`
- The actual proof at lines 7084-7105 is **complete** with no sorry keyword
- The comment is outdated - the proof was subsequently filled in

**Verdict**: Remove from sorry count. This code is ACTIVE (part of `FPreservingForwardChain.forward_G`).

## Summary Table

| Region | Lines | Sorries | External Deps | Classification |
|--------|-------|---------|---------------|----------------|
| Z_chain construction | 5088-5369 | 5 | None | ARCHIVE |
| Omega F-persistence | 6377-6579 | 3 | None | ARCHIVE |
| P-preserving seed | 7116-7563 | 2 | None | ARCHIVE |
| Line 7082 | 7082 | 0 | - | FALSE POSITIVE |
| **TOTAL** | ~925 lines | 10 | | |

## Combined Removal Summary

Adding to the high-confidence removals from the first report:

| Category | Lines | Sorries |
|----------|-------|---------|
| High confidence (report 01) | ~2,000 | 13 |
| Medium confidence (this report) | ~925 | 10 |
| **TOTAL** | ~2,925 | 23 |

After cleanup, UltrafilterChain.lean would go from ~8,376 lines to ~5,450 lines (35% reduction).

## Removal Action Plan

### Phase 1: Remove Z_chain region
```
DELETE: Lines 5088-5369
VERIFY: `grep -r "Z_chain" Theories/` shows only comments remain
```

### Phase 2: Remove omega F-persistence theorems
```
DELETE: Lines 6377-6579
VERIFY: No external references
```

### Phase 3: Remove P-preserving seed region
```
DELETE: Lines 7116-7563
VERIFY: `grep -r "P_unresolved_theory\|p_preserving_seed" Theories/` returns empty
```

### Dependencies to Remove First

Before removing medium confidence items, remove the high confidence items that depend on them:

1. `OmegaFMCS` uses `Z_chain` - remove with Z_chain
2. `CoherentZChain` uses `omega_chain_P_preserving_backward` - remove after P-preserving seed
3. `omega_true_dovetailed_forward_F_resolution` uses `Z_chain_forward_F'` - remove after it

## Verification Commands

After each removal phase:

```bash
# Build verification
lake build Theories.Bimodal.Metalogic.Algebraic.UltrafilterChain

# Sorry count verification
grep -c "sorry" Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean

# Reference check
grep -rn "Z_chain\|OmegaFMCS\|P_unresolved_theory\|p_preserving_seed" Theories/Bimodal/ | grep -v "^.*\.lean:.*--"
```

## Conclusion

All medium confidence items are confirmed ARCHIVE candidates:
- **Z_chain**: Dead alternative to SuccChainFMCS
- **omega F-persistence**: Dead building block for Z_chain
- **P-preserving seed**: Dead symmetric approach to F-preserving (which is also dead)

The line 7082 "sorry" was a **false positive** - it's a comment, not code.

Combined with high-confidence removals, this cleanup eliminates 23 of 24 sorries (96%) and ~35% of the file.
