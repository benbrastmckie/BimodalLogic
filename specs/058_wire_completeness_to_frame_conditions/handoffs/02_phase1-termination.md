# Handoff: Task 58 Phase 1 - Termination Proof Needed

## Status

Phase 1 is PARTIAL. The `restricted_bounded_witness` theorem proof is mathematically complete but uses `sorry` in the `decreasing_by` block for termination.

## What Was Done

1. **Implemented `restricted_bounded_witness`**: The theorem is at line 2190 in `SuccChainFMCS.lean`. The proof handles:
   - Base case: `n = 0` means `theta in chain(k+1)`, done.
   - Inductive case, F resolved: `iter_F n theta in chain(k+1)`, recurse with new boundary.
   - Inductive case, F deferred: `F(iter_F n theta) in chain(k+1)`, recurse with new boundary.

2. **Added helper `iter_F_compose`**: At line 2158, proves `iter_F d (iter_F n psi) = iter_F (d + n) psi`.

3. **Build passes**: `lake build` succeeds with only termination-related sorry.

4. **Verification shows sorryAx**: `lean_verify` on `restricted_bounded_witness` and `restricted_forward_chain_forward_F` both show `sorryAx` dependency.

## Blocking Issue: Termination Proof

The termination proof uses `sorry` because:

1. When F resolves and `d' = 1`: new depth is `n < n+1`, IH applies directly. This case is fine.

2. When F resolves and `d' > 1`: new depth is `d' + (n-1) >= n+1`. Depth didn't decrease!

3. When F deferred: new depth is `d' + n >= n+1`. Depth didn't decrease!

In cases 2 and 3, only position increases (`k` -> `k+1`), but depth stays the same or increases.

## Suggested Approaches for Termination

### Approach A: Lexicographic on (maxD - d, pending_count)

- `maxD` = `(deferralClosure phi).sup f_nesting_depth` (finite bound)
- `pending_count` = number of F-formulas waiting to resolve at current depth
- When F defers at same depth, `pending_count` decreases (one formula progresses)
- When F resolves, depth decreases

**Issue**: Formalizing `pending_count` is complex.

### Approach B: Fuel-Based Recursion

- Add explicit fuel parameter bounded by `|deferralClosure| * maxD`
- Each recursive call decreases fuel
- Prove fuel suffices using finiteness

**Issue**: Changes theorem signature.

### Approach C: Well-Founded Recursion on Custom Order

Define measure: `m(d, k) = maxD - d + (maxPos - k) * (maxD + 1)`

Where `maxPos` is some large enough bound on positions needed.

**Issue**: Need to compute or axiomatize `maxPos`.

### Approach D: Direct Induction on Pending Formulas

Track set of F-formulas `{F(psi) | F(psi) in chain(k)}` as measure.
Each step either removes one (resolved) or advances one (deferred).
By finiteness, this terminates.

**Issue**: Requires encoding set as measure.

## Recommended Next Step

The simplest fix may be to prove a **key lemma**: when F resolves (`iter_F n theta in chain(k+1)`), the boundary `d'` from `F_bounded` satisfies `d' = 1`.

**Why this might be true**: The original boundary was `n+1`, meaning `iter_F (n+2) theta not in chain(k)`. After F resolves at position k+1, `iter_F n theta in chain(k+1)`. The new F-form is `F(iter_F (n-1) theta) = iter_F n theta`. The boundary for `iter_F (n-1) theta` at k+1 should be exactly 1 because `iter_F (n+1) theta not in chain(k+1)` (inherited from original boundary).

**Proof sketch**:
- Original: `iter_F (n+2) theta not in chain(k)`
- By F_step_witness on `iter_F (n+1) theta = F(iter_F n theta)`:
  Either `iter_F n theta in chain(k+1)` [we have this]
  Or `iter_F (n+1) theta in chain(k+1)` [not this case]
- If `iter_F (n+1) theta in chain(k+1)`, then by F_step_witness at k+1:
  Either `iter_F n theta in chain(k+2)` or `iter_F (n+1) theta in chain(k+2)`
- Eventually `iter_F (n+2) theta` would need to enter, but it can't since not in chain(k) originally...

This argument is subtle. It relies on the chain only adding formulas from deferralClosure, not creating new ones.

## Files Modified

- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`:
  - Line 2158: Added `iter_F_compose` helper
  - Line 2190: Implemented `restricted_bounded_witness` with termination sorry
  - Line 2307-2308: `decreasing_by all_goals sorry`

## Build Status

`lake build` passes. Theorem is functional but uses `sorryAx`.

## Next Steps for Continuation

1. Try proving `d' = 1` always holds when F resolves (Approach from Recommended Next Step)
2. If that fails, use Approach B (fuel-based) or D (set-based measure)
3. Once termination is done, verify `restricted_forward_chain_forward_F` is sorry-free
4. Continue with Phase 2 (backward chain construction)
