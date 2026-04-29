# Handoff: Phase 9 — C4/g_prop/h_prop c2' Sorry Sites Blocker Analysis

**Session**: sess_1777516822_impl9
**Date**: 2026-04-29
**Phase**: 9 [IN PROGRESS → BLOCKED]
**Branch**: irr_until

## What Was Done

Thorough analysis of all 4 sorry sites in CounterexampleElimination.lean (lines 908, 946, 982, 1014) to determine whether the plan's Lemma 2.6 splitting approach is feasible.

## Key Finding: Fundamental Blocker

**The plan's Phase 9 approach cannot close these sorry sites as described.** The blocker is structural, not merely technical.

### Root Cause

All 4 sorry sites require proving `χ'.c2'` for a chronicle χ' returned by:
- `eliminate_C4_counterexample` (lines 908, 946)
- `eliminate_g_prop_counterexample` (line 982)
- `eliminate_h_prop_counterexample` (line 1014)

These functions ALL return chronicles where `χ'.g = χ.g` (the g-function is completely inherited, unchanged). When a new point z is inserted:
- `χ'.dom = insert z χ.dom`
- `χ'.f z = D` (some MCS)
- `χ'.g a z = χ.g a z` for all a (ARBITRARY, since z was not in domain before)
- `χ'.g z b = χ.g z b` for all b (ARBITRARY)

For `c2'` of χ', adjacent pairs involving z require:
- `BurgessR3Maximal (χ.f a) (χ.g a z) D` — **unprovable** since χ.g a z is unconstrained
- `BurgessR3Maximal D (χ.g z b) (χ.f b)` — **unprovable** since χ.g z b is unconstrained

### Why Lemma 2.6 Doesn't Help Directly

The plan says to apply `lemma_2_6_splitting` to `BurgessR3Maximal(f(x), g(x,x_next), f(x_next))`. This lemma requires:
```
theorem lemma_2_6_splitting {A B C : Set Formula}
    (h_r3m : BurgessR3Maximal A B C)
    (h_gc : g_content A ⊆ C)  -- ← REQUIRED HYPOTHESIS
    ...
```

For g_prop: A = f(pc.x), C = f(pc.y). The counterexample is `G(α) ∈ f(pc.x)` but `α ∉ f(pc.y)`. This means `α ∈ g_content(f(pc.x))` but `α ∉ f(pc.y)`, so `g_content(f(pc.x)) ⊈ f(pc.y)`. **The h_gc hypothesis is directly contradicted by the g_prop counterexample condition.**

For h_prop: Mirror — h_content(f(pc.x)) ⊈ f(pc.y) is the counterexample condition.

For C4/C4': g_content(f(w)) ⊆ f(w_next) for the bridging pair (w, w_next) is NOT derivable from the C4 elimination conditions alone.

### Why burgessR3Maximal_from_g_content_sub Is Insufficient for Both Pairs

For the (pc.x, z) pair with f(z) = D (g_prop D from g_propagation_witness):
- `g_content(f(pc.x)) ⊆ D` ✓ (from g_propagation_witness)
- `burgessR3Maximal_from_g_content_sub` gives B' with `BurgessR3Maximal(f(pc.x), B', D)` ✓

**For the (z, pc.y) pair with f(z) = D:**
- Need `g_content(D) ⊆ f(pc.y)` for `burgessR3Maximal_from_g_content_sub`
- Equivalently (via h_content_subset_implies_g_content_reverse): need `h_content(f(pc.y)) ⊆ D`
- D extends `{α} ∪ g_content(f(pc.x))` — h_content(f(pc.y)) is NOT guaranteed to be in D
- From `h_content_sub_B_of_BurgessR3Maximal`: h_content(f(pc.y)) ⊆ g(pc.x,pc.y) requires `g_content(f(pc.x)) ⊆ f(pc.y)` — FAILS for g_prop

### Two-Sided Seed Approach

The right D for f(z) would need BOTH:
- `g_content(f(pc.x)) ⊆ D` (for (pc.x, z) pair)
- `h_content(f(pc.y)) ⊆ D` (for (z, pc.y) pair)

Seed = `{α} ∪ g_content(f(pc.x)) ∪ h_content(f(pc.y))`.

**Consistency** of this seed requires `splitting_seed_consistent`-style argument, which needs `g_content(f(pc.x)) ⊆ f(pc.y)` — FAILS for g_prop.

So even two-sided seeds don't work without an additional consistency proof for the g_prop/h_prop case.

## Chronicle Structure Analysis

The `eliminate_g_prop_counterexample` inserts `z = (x+y)/2` between the ADJACENT pair (x, y) with `Adjacent χ.dom x y`. So:
- Adjacent pairs in χ'.dom: (pc.x, z) and (z, pc.y) — only these two new ones
- All old adjacent pairs that don't involve the gap (pc.x, pc.y) remain adjacent

For (pc.x, z): provable with g_content(f(pc.x)) ⊆ D from g_propagation_witness.
For (z, pc.y): **blocked** — no way to show g_content(D) ⊆ f(pc.y).

## Resolution Options

### Option A: Two-Sided Seeds with g_ordered Invariant

Add `g_content(f(a)) ⊆ f(b)` as an additional chronicle invariant for all adjacent pairs. This would allow:
- The (pc.x, z) pair: use g_content(f(pc.x)) ⊆ D from g_propagation_witness
- The (z, pc.y) pair: use h_content_subset_implies_g_content_reverse + h_content(f(pc.y)) ⊆ D

**But the g_prop counterexample says g_content(f(pc.x)) ⊈ f(pc.y)!** So the invariant would be violated at the g_prop step, meaning the g_prop counterexample couldn't arise.

Actually wait — if g_content(f(a)) ⊆ f(b) holds for all adjacent pairs, then the g_prop counterexample (G(α) ∈ f(a), α ∉ f(b)) could never arise. The g_prop case in `eliminate_potential_counterexample` would be vacuous. So the sorry never triggers.

**This is actually the correct approach**: maintain g_content inclusion as a chronicle invariant. This is the "g_ordered" invariant from the earlier design. If it's maintained throughout the omega chain, the counterexample cases for g_prop/h_prop never arise, making those sorry sites vacuously provable.

**Effort**: Substantial refactoring. Need to:
1. Add `g_ordered : ∀ a b, Adjacent χ.dom a b → g_content (χ.f a) ⊆ χ.f b` to ChronicleInvariant
2. Show singleton_invariant satisfies g_ordered (trivially for singleton domain)
3. For each point insertion, show g_ordered is maintained
4. Then c2' becomes provable via the available g_content inclusion

### Option B: Remove c2' from EliminationResult for Finite Stages

Since `c2'` is vacuously true at the limit (dense domain, no adjacent pairs), Burgess's approach is to prove c2' ONLY at the limit. At finite stages, we just need c0, f-agreement, and the specific counterexample witness.

**Changes needed**:
1. Remove `c2' : val.c2'` field from `EliminationResult` structure
2. Remove `c2'` from the 4 sorry sites (they become vacuously absent)
3. Restructure the limit construction to prove c2' at the limit (vacuously true for dense domains)

**Effort**: Medium. The EliminationResult structure change will have ripple effects throughout the omega chain. Need to verify the limit construction still gets all properties it needs.

**Risk**: May need to restructure `eliminate_potential_counterexample` to not propagate c2' through iterations.

### Option C: Defer to Phase 10+ with g_ordered Invariant

Change the plan to:
1. Phase 9: Add g_ordered as invariant (or remove c2' from EliminationResult)
2. Phase 10 (formerly): C5 case uses g_ordered to prove (pc.x, z) pair trivially
3. The g_prop/h_prop cases become vacuous under g_ordered

## Recommendation

**Option B (Remove c2' from EliminationResult)** is most aligned with Burgess's design and has been discussed since report 43 (Strategy 2). Key points:
- Burgess's c2' is vacuously true at the limit (his design intent)
- The 4 sorry sites exist precisely because c2' is over-specified for finite stages
- Removing c2' from EliminationResult is a clean architectural fix
- The limit c2' proof becomes trivial (no adjacent pairs in dense domain)

**Option A (g_ordered invariant)** is also viable but more complex since it changes all insertion functions and requires consistency proofs.

## Files Analyzed

- `CounterexampleElimination.lean` — all 4 sorry sites (908, 946, 982, 1014)
- `PointInsertion.lean` — lemma_2_6_splitting signature, splitting_seed_consistent
- `ChronicleTypes.lean` — Chronicle.c2' definition
- `RRelation.lean` — burgessR3Maximal_from_g_content_sub, g_content_sub_B_of_BurgessR3Maximal
- `WitnessSeed.lean` — h_content_subset_implies_g_content_reverse

## Current Build State

Build passes. Sorry count in CounterexampleElimination.lean: 7 (lines 830, 868, 908, 946, 982, 1014, 1130). No change from Phase 9 start.

## Action Required

Plan revision needed. Choose Option A or B before attempting to close the 4 sorry sites. The current plan's "apply lemma_2_6" approach does not work for these cases.

Recommend `/revise 107` to update Phase 9 approach.
