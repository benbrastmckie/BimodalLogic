# Phase 6 Blocked: nonconstenv_exist_transfer_general is FALSE

## Current State

- Phase 6 dispatch 2 (continuation)
- PriorComposition.lean: 2 sorry (lines 304, 315) in `nonconstenv_exist_transfer_general`
- KampBypass.lean: 0 sorry (unchanged)
- Build: passes (full `lake build` clean)

## What Was Accomplished

1. **Deleted `zone_compatible_witness_bwd/fwd`** (lines 245-308, previously 2 sorry)
   - These are FALSE as standalone theorems
   - Counterexample: Z with P=evens, envM=[4,-1], envN=[0,-1], w=1

2. **Discovered `nonconstenv_exist_transfer_general` is FALSE at D=0 when n > 0**
   - New counterexample: Z with P=evens, envM=[10,0], envN=[2,0]
   - Depth-1 1-var NFs agree at 10/2 (both even, same depth-0 2-var existentials)
   - Orders match: 0 < 10 iff 0 < 2
   - But sub_nf "w even, 0 < w < 10" satisfiable in M (w=2), not in N (no even in (0,2)={1})

3. **Updated theorem docstring** to document the falsity and correct approach

## Root Cause Analysis

The D-induction in `nonconstenv_exist_transfer_general` calls D=0 at high arity via
arity climbing (D=d+1 calls IH at D=d with n+1 anchors). At D=0, the theorem is
FALSE because:

- h_1var gives depth-1 1-var agreement at EACH anchor independently
- The between-zone existential transfer requires 2-var agreement at the anchor PAIR
- Depth-1 1-var at anchor i captures which depth-0 2-var types exist above/below anchor i
- But it does NOT capture which types exist BETWEEN anchor i and anchor j
- This is because the 2-var sub_nf at [u, envM(i)] involves only 2 variables, not 3

The K-induction in `prior_nonconstenv_2var_agree_until` (which calls this theorem)
provides the needed 2-var agreement at the anchor pair via its IH, but this information
is NOT passed through to `nonconstenv_exist_transfer_general`.

## Correct Architecture (for next dispatch)

1. **Delete**: `nonconstenv_exist_transfer_general`, `nonconstenv_exist_transfer_until`,
   `nonconstenv_exist_transfer_since`

2. **Rewrite `prior_nonconstenv_2var_agree_until/since`** quantifier part inline:

   For K=succ K':
   - IH gives depth-(K'+2) 2-var at [x,t]/[x',t']
   - IH quantifier part gives depth-(K'+1) 3-var existential transfer
   - Need depth-(K'+2) 3-var transfer (1 depth boost)
   - Depth boost: from depth-(K'+1) 3-var agreement at [y,x,t]/[c,x',t'] (from IH transfer)
     + depth-(K'+2) 1-var at y/c (from cross_extend at h_x or h_t)
     + depth-(K'+2) 2-var at [x,t]/[x',t'] (from IH)
     -> depth-(K'+2) 3-var agreement
   - The boost verifies: atoms (depth-independent, from K'+1 agreement)
     + quantifiers (depth-(K'+1) 4-var transfer, which uses arity climbing
     terminating at depth 0 where the IH 2-var resolves the between-zone)

   For K=0:
   - h_x at depth 2, h_t at depth 2
   - Need depth-1 3-var transfer directly
   - Zone analysis: outer zones via cross_extend, between-zone via Prior-UZ/SZ
   - Between-zone: cross_extend from h_x gives c_x < x' with depth-1 2-var at [y,x]/[c_x,x']
     cross_extend from h_t gives c_t > t' with depth-1 2-var at [y,t]/[c_t,t']
   - If c_x > t' or c_t < x': witness in correct interval
   - If neither: Prior-UZ/SZ squeeze with char(0) formula
   - The 4-var quantifier conditions at depth 0 are purely atomic and resolvable
     using the depth-1 2-var agreements from cross_extend

3. **New private theorem** (depth boost lemma):
   ```
   depth_boost_3var : depth-d 3-var agreement + depth-(d+1) 1-var at witness
     + depth-(d+1) 2-var at anchor pair -> depth-(d+1) 3-var agreement
   ```
   Proved by: atoms from depth-d (depth-independent), quantifiers by arity climbing
   inner loop from depth d down to 0.

## Sorry Inventory

| File | Line | Statement | Status |
|------|------|-----------|--------|
| PriorComposition.lean | 304 | nonconstenv_exist_transfer_general D=0 | FALSE |
| PriorComposition.lean | 315 | nonconstenv_exist_transfer_general D=d+1 | FALSE (depends on D=0) |

## Immediate Next Action

Research dispatch to design plan v16 that eliminates `nonconstenv_exist_transfer_general`
and restructures `prior_nonconstenv_2var_agree_until/since` with the inline approach.
The K=0 base case and the depth boost lemma are the key new components.
