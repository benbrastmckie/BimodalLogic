# Handoff: Termination Proof Analysis for Task 67

## Summary

Phase 1 of task 67 aims to fill 4 `decreasing_by sorry` blocks in `SuccChainFMCS.lean`. Analysis reveals a common structural issue across all 4 functions that prevents the current termination measure from working.

## Affected Functions

1. `restricted_bounded_witness` (line ~2725)
2. `restricted_backward_bounded_witness` (line ~4270)
3. `restricted_combined_bounded_witness` (line ~4345)
4. `restricted_combined_bounded_witness_P` (line ~4525)

## Root Cause

All four functions use `induction d generalizing k` but make recursive calls where:
- The induction gives us depth `d = n + 1` (from `| succ n ih`)
- Recursive calls use depth `d' + n` or `d' + (n - 1)` where `d' >= 1`
- When `d' = 1`: new depth equals old depth (no decrease)
- When `d' = 2` (in some cases): new depth equals old depth

The termination measure `(B - d, d)` fails because:
1. When `d_new > d_old`: `B - d_new < B - d_old` (first component decreases) - WORKS
2. When `d_new = d_old`: pair is equal - FAILS (not strictly decreasing)

The termination checker cannot see that `d = n + 1` from the induction pattern, so it cannot prove `d_new > d`.

## Current State

- Added case splits for `d' = 1` to use IH (induction hypothesis) where possible
- Added case split for `d' = 2` in the resolved case to isolate the problematic case
- Sorries remain in:
  - `decreasing_by` blocks (4 total across 4 functions)
  - Two special cases per function where depth equals original

## Proposed Solutions

### Option A: Fuel-Based Approach
Add explicit `fuel : Nat` parameter that decreases on every recursive call:
```lean
theorem restricted_bounded_witness_fueled (phi : Formula)
    (M0 : DeferralRestrictedSerialMCS phi) (k : Nat) (theta : Formula) (d : Nat)
    (fuel : Nat) ...
termination_by fuel
```
Then prove main theorem using fueled version with `fuel = B * B`.

**Pros**: Clean termination proof, fuel always decreases
**Cons**: Requires restructuring, need to prove sufficient fuel exists

### Option B: Well-Founded Recursion on Custom Relation
Define a well-founded relation that captures both depth and chain position progress:
```lean
def witness_order : (Nat × Nat × Nat) → (Nat × Nat × Nat) → Prop :=
  fun (fuel, depth, pos) (fuel', depth', pos') =>
    fuel < fuel' ∨ (fuel = fuel' ∧ depth < depth')
```

**Pros**: More precise termination argument
**Cons**: Complex setup, may require proving well-foundedness

### Option C: Restructure to Avoid Recursive Calls
Reformulate the proof to use `Nat.find` or existential witness:
```lean
theorem restricted_bounded_witness := by
  have h_exists : ∃ m > k, theta ∈ restricted_forward_chain phi M0 m := by
    -- Non-recursive existence proof
  exact Nat.find_spec h_exists
```

**Pros**: No termination proofs needed
**Cons**: May require significant proof restructuring

## Recommended Approach

**Option A (Fuel-Based)** is recommended because:
1. Minimal restructuring of existing proof logic
2. Clear semantic justification (bounded by `B * B` recursive calls)
3. Pattern matches existing comment in code about fuel approach

## Implementation Steps for Option A

1. Create `restricted_bounded_witness_fueled` with fuel parameter
2. Copy existing proof body, use fuel for termination
3. Prove `restricted_bounded_witness` by calling fueled version with `fuel = closure_F_bound phi * closure_F_bound phi`
4. Repeat for the other 3 functions

## Files Modified

- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`
  - Updated docstrings explaining termination strategy
  - Added case splits for `d' = 1` and `d' = 2`
  - Sorries remain in `decreasing_by` blocks

## Next Steps

1. Choose solution approach (recommend Option A)
2. Implement for `restricted_bounded_witness` first
3. Verify build passes
4. Apply same pattern to other 3 functions
5. Proceed to Phase 2 (G/H propagation)

## Session Information

- Session ID: sess_1774744695_5a67fc
- Plan: specs/067_prove_bundle_validity_implies_provability/plans/03_termination-first-plan.md
- Phase Status: 1 [PARTIAL]
