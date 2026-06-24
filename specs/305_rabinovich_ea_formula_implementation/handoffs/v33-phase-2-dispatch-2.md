# Phase 2 Dispatch 2 Handoff -- NfDepth0Generalized

## Immediate Next Action

Prove the forward direction of `nf_nvar_exist_depth0_tl` succ case (line ~533).
The forward direction requires showing: if the temporal formula holds,
then there exists env satisfying the full arity-(n+2) depth-0 NF.

## Current State

- **Phase 2 status**: IN PROGRESS (1 sorry remaining)
- **Sorry location**: Forward direction of biconditional in succ n case
- **Backward direction**: PROVED (existential -> formula, all 3 subcases)
- **Build status**: Builds with 1 sorry (no other errors)
- **Helper lemmas**: nf_depth0_pair_cycle_empty', nf_depth0_3cycle_empty (sorry-free)
- **Consistency checks**: h_pair (no 2-cycles), h_3cycle (no 3-cycles) in context

## Analysis of the Forward Direction Blocker

### The Cross-Condition Problem

The forward direction (formula -> existential) is blocked by a fundamental
structural issue with the IH-based approach.

**Setup**: The succ n case peels off position n (= x) as an outermost
existential. The IH handles the inner n existentials at arity (n+1) via
`restrict_inner` (positions 0..n). The formula is:
- x < t case: `pred_t AND S(A_inner AND pred_x, top)`
- t < x case: `pred_t AND U(A_inner AND pred_x, top)`
- x = t case: `pred_t AND A_inner AND pred_x`

**Problem**: `restrict_inner` captures atom conditions among positions 0..n
(inner variables + x) but NOT conditions between positions i (i < n) and
position n+1 (= t). These "cross-conditions" are:
- `sub_nf (.order ⟨i⟩ ⟨n+1⟩ _)`: whether env'(i) < t
- `sub_nf (.order ⟨n+1⟩ ⟨i⟩ _)`: whether t < env'(i)

**Why it matters**: The IH produces env' satisfying `restrict_inner` at x.
But these env' values may NOT satisfy the cross-conditions. Specifically:
- If env'(i) > x and x < t: env'(i) could be in (x,t) or beyond t.
  The cross-condition constrains which, but the formula doesn't enforce it.
- If env'(i) < x and x > t: same undetermined relationship.

So the formula OVER-APPROXIMATES the existential. The forward direction
(formula -> existential) can fail because the IH produces env' that
don't satisfy cross-conditions with t.

### Why the Backward Direction Works

The backward direction is fine: given env satisfying the FULL sub_nf,
we extract x = env(n), verify pred_t, pred_x, x-vs-t order, and
use the IH (whose restrict_inner is a subset of sub_nf's conditions).

### Approaches to Fix the Forward Direction

**Approach A: Direct construction via translateEF1** (recommended)
- Don't use the IH at all
- Check if sub_nf's order booleans define a valid total order
- If invalid: Formula.bot (empty existential)
- If valid: sort positions, find t's rank, build alpha/beta for translateEF1
- Correctness follows from translateEF1_correct
- Estimated effort: 200-300 lines of new infrastructure
- Risk: Sorting infrastructure in Lean is non-trivial

**Approach B: Strengthen the IH** (alternative)
- Change the theorem statement to carry ordering information
- The IH would say not just "TL-definable" but also "witnesses placed in specific order"
- Complicates the interface with Phase 3
- Risk: May break Phase 3 usage

**Approach C: Finite disjunction over inner NFs** (alternative)
- Enumerate all NormalForm sig 0 n values (Fintype)
- For each inner NF nf_inner, check compatibility with sub_nf
- Build formula as disjunction
- Risk: exponential formula size, complex compatibility check

## What Was Accomplished This Dispatch

1. Analyzed the cross-condition problem in depth (was not identified in prior dispatches)
2. Proved backward direction (existential -> formula) for all 3 cases (x<t, t<x, x=t)
3. Added helper lemmas for NF inconsistency detection (pair cycles, 3-cycles)
4. Added consistency gates (h_pair, h_3cycle) to the proof structure
5. Identified that no-3-cycles is necessary but not sufficient for full consistency

## Key Decisions

- Kept the IH-based approach for the backward direction (it works)
- The forward direction requires a fundamentally different approach
- The formula construction itself may need to change for the forward direction
  to be provable (it's currently too weak)
- Approach A (translateEF1) is the cleanest mathematically

## Sorry Inventory

| File | Line | Statement | Assumption | Why Deferred | Next Dispatch |
|------|------|-----------|------------|--------------|---------------|
| NfDepth0Generalized.lean | ~533 | nf_nvar_exist_depth0_tl (forward direction of succ case) | That the temporal formula implies the existential with cross-conditions | IH-based formula doesn't capture cross-conditions between inner variables and t; requires either translateEF1-based direct construction or formula redesign | Implement Approach A: define ordering consistency check, extract sorted order, build alpha/beta for translateEF1, prove correctness |

## References

- Plan: specs/305_rabinovich_ea_formula_implementation/plans/33_nf-strong-induction.md
- Phase 1: Theories/Bimodal/Metalogic/WeakCanonical/Kamp/VecEA_m.lean (sorry-free)
- This file: Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfDepth0Generalized.lean
- translateEF1: Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Translation.lean (sorry-free)
- Arity-2 case: Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfToVecEA.lean (sorry-free)
