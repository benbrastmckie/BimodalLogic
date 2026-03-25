# Handoff: Task 58 Phase 1 Partial Progress

## Status

Phase 1 is PARTIAL. The `restricted_bounded_witness` theorem has been reformulated but the proof is incomplete.

## What Was Done

1. **Identified the issue**: The original theorem statement `theta ∈ chain(k + d)` was too strong. The F_step_witness gives a disjunction that allows the F-nesting to be deferred, so theta may appear at a position later than `k + d`.

2. **Reformulated the theorem**: Changed to existential form:
   ```lean
   theorem restricted_bounded_witness (phi : Formula)
       (M0 : DeferralRestrictedSerialMCS phi) (k : Nat) (theta : Formula) (d : Nat)
       (h_d_ge : d ≥ 1)
       (h_iter_in : iter_F d theta ∈ restricted_forward_chain phi M0 k)
       (h_iter_not : iter_F (d + 1) theta ∉ restricted_forward_chain phi M0 k) :
       ∃ m : Nat, m > k ∧ theta ∈ restricted_forward_chain phi M0 m
   ```

3. **Updated the caller**: Modified `restricted_forward_chain_iter_F_witness` to work with the existential result.

4. **Partial proof structure**: Wrote the induction framework with two cases (resolved/deferred) but the recursive structure needs adjustment.

## Remaining Issues

### Case 1 (n >= 1, resolved branch)

After getting `iter_F n theta ∈ chain(k+1)` and applying F_bounded to get boundary d' for `iter_F (n-1) theta`, we recursively call `restricted_bounded_witness` to get `iter_F (n-1) theta ∈ chain(m')` for some `m' > k+1`.

If `n-1 = 0`, we have `theta ∈ chain(m')` and are done.
If `n-1 >= 1`, we need to continue unwinding. The recursion here needs to be on the F-nesting depth of the formula, but the current induction is on `d` which is the boundary depth, not the formula's depth.

### Case 2 (deferred branch)

After getting `iter_F (n+1) theta ∈ chain(k+1)` and applying F_bounded to get boundary d' for `iter_F n theta`, we call the IH which gives us `theta ∈ chain(m)` (not `iter_F n theta ∈ chain(m)`!).

Wait, actually the IH is for depth `n`, so it should produce `theta` from `iter_F n theta`. But we're passing `iter_F d' (iter_F n theta)` which has a different depth.

### Root Cause

The issue is that the IH is parameterized by `d` (the boundary depth from F_bounded), but what we need is to track the F-nesting depth of the formula itself (`iter_F d theta` has F-nesting depth d).

## Suggested Fix Approach

1. **Prove a different lemma first**: For any formula `F(psi) ∈ chain(k)`, show `psi ∈ chain(m)` for some `m > k`. This doesn't need the boundary condition.

2. **Use well-founded recursion on formula complexity**: Define a complexity measure based on F-nesting depth in deferralClosure, and prove termination using that.

3. **Alternative: Prove by strong induction on the global F-bound**:
   - Let `maxF := max{d | iter_F d theta ∈ deferralClosure(phi)}` (finite since deferralClosure is finite)
   - Use well-founded recursion on `maxF - current_depth`

## Files Modified

- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`:
  - Line ~2155: Added `restricted_bounded_witness` theorem (with sorries)
  - Line ~2320: Updated `restricted_forward_chain_iter_F_witness` to use existential result

## Build Status

The code compiles with warnings about sorries. No breaking changes to the rest of the codebase.

## Next Steps for Continuation

1. Implement the alternative approach (strong induction on global F-bound)
2. Or prove the simpler lemma: `F(psi) ∈ chain(k) → ∃ m > k, psi ∈ chain(m)` without the boundary condition, then derive the bounded witness from it
3. Verify `restricted_forward_chain_forward_F` becomes sorry-free
4. Continue with Phase 2 (backward chain construction)
