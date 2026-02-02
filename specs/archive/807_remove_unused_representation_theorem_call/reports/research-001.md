# Research Report: Unused representation_theorem Call

**Task**: 807 - Remove unused representation_theorem call from InfinitaryStrongCompleteness.lean
**Date**: 2026-02-02
**Status**: Complete

## Summary

The `representation_theorem` call at line 248 of `InfinitaryStrongCompleteness.lean` is confirmed to be dead code. It can be safely removed along with the associated `h_neg_cons` hypothesis (lines 239-244) and the comments discussing this abandoned approach (lines 233-235, 246-261).

## Analysis

### Location and Context

**File**: `Theories/Bimodal/Metalogic/Completeness/InfinitaryStrongCompleteness.lean`
**Function**: `infinitary_strong_completeness` (theorem starting at line 218)

The unused code is at lines 247-248:
```lean
obtain ⟨family, t, h_neg_in, h_neg_true⟩ :=
  Bimodal.Metalogic.Representation.representation_theorem phi.neg h_neg_cons
```

### Why It Is Unused

The proof initially tried to use the representation theorem on `{phi.neg}` alone, but this approach was abandoned because:

1. **Insufficient Hypothesis**: The representation theorem only guarantees that `phi.neg` is true at some point in the canonical model. It does NOT guarantee that all of `Gamma` is true at that point.

2. **Comments Document the Issue**: Lines 261, 287-289, and 345-346 explain:
   - "The problem: the MCS at t extends {phi.neg}, not necessarily Gamma ∪ {phi.neg}"
   - "The question is: does Gamma ⊆ family.mcs t? Not necessarily!"

3. **Alternative Approach Taken**: The proof pivots to a stronger approach at line 274:
   ```lean
   obtain ⟨Γ_mcs, h_extends, h_is_mcs⟩ := set_lindenbaum (Gamma ∪ {phi.neg}) h_union_cons
   ```
   This extends `Gamma ∪ {phi.neg}` (not just `{phi.neg}`) to an MCS, ensuring all formulas in Gamma are included.

### Evidence of Non-Use

1. **Variables Never Referenced**:
   - `family` (from line 247) - The actual `family` used in the proof is defined at line 425
   - `t` (from line 247) - Only appears in comments after line 247
   - `h_neg_in` (from line 247) - Never used; `h_neg_in_mcs` (line 364) serves the purpose
   - `h_neg_true` (from line 247) - Shadowed by `h_neg_true` at line 431, which is the one actually used

2. **Shadowing Confirms Dead Code**:
   - Line 431 defines a new `have h_neg_true` that shadows the original
   - Lines 456-457 use this new `h_neg_true`, not the original

3. **`h_neg_cons` Also Unused**:
   - Lines 239-244 define `h_neg_cons : SetConsistent {phi.neg}`
   - This is only used to call `representation_theorem`
   - Since that call is unused, `h_neg_cons` is also dead code

## Files to Modify

Only one file needs modification:

- `Theories/Bimodal/Metalogic/Completeness/InfinitaryStrongCompleteness.lean`

## Recommended Changes

### Option 1: Minimal Removal (Recommended)

Remove lines 233-261 (the entire abandoned approach):
- Lines 233-235: Comments about initial approach
- Lines 237-244: `h_neg_cons` definition
- Lines 246-248: The `representation_theorem` call
- Lines 250-261: Comments explaining why this approach fails

This leaves line 236 (blank) and continues cleanly from line 262 onward.

### Option 2: Conservative Removal

Keep the educational comments (233-235, 261-261) but remove:
- Lines 237-248: The actual dead code

## Verification

The file currently builds successfully:
```
lake build Bimodal.Metalogic.Completeness.InfinitaryStrongCompleteness
# Completes without errors
```

After removal, run:
```bash
lake build Bimodal.Metalogic.Completeness.InfinitaryStrongCompleteness
```

## Risk Assessment

**Risk Level**: Very Low

1. **Pure Dead Code**: The bindings are never referenced in the proof
2. **No External Dependencies**: No other files reference this internal proof structure
3. **Build Verification**: Easy to verify correctness by building after removal

## Dependencies

- `Bimodal.Metalogic.Representation.UniversalCanonicalModel` imports `representation_theorem`
- After removal, this import may become partially unused, but it's still needed for other functions:
  - `construct_coherent_family`
  - `canonical_model`
  - `canonical_history_family`
  - `truth_lemma`
  - `construct_coherent_family_origin`
  - `UniversalCanonicalFrame`

## Implementation Notes

When removing the code:

1. Remove lines 233-261 entirely
2. Keep lines 262 onward unchanged (starting with "-- We need to use a stronger version...")
3. Verify build succeeds
4. The proof flow will read:
   - Line 229-232: Establish `h_union_cons`
   - Lines 262+: Comments explaining the correct approach
   - Line 274+: `set_lindenbaum` call that is actually used
