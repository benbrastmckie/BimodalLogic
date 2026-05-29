# Phase 5 Blocker: Finite-Position Game Orderings vs GHR93's Continuous Order-Type Preservation

**Date**: 2026-05-28
**Session**: sess_1780001766_2e723d
**Phase**: 5 -- GHR93-Faithful Case II Rewrite (Path C: Full Supremum + Restricted Tau)
**Status**: BLOCKED

## Summary

Phase 5 of plan v47 cannot be implemented as specified. The restricted tau approach (replacing tau_left/tau_right with a single game on [d, b'] -> [c, b] where b = sup of B-satisfying points) does NOT provide the biconditional orderings needed by `same_order_type_of_cases`. The root cause is a fundamental gap between GHR93's mathematical argument (which assumes continuous order-type preservation over all points) and the Lean formalization (which uses finite-position games where orderings are available only at game positions).

## The Core Problem

### What `same_order_type_of_cases` Requires

For the final winning condition of ghr93_case_II, `same_order_type_of_cases` needs:
```
forall (k : Fin n),
  (a_init(k) < p_n <-> a'_resp(k) < e_n) AND
  (a_init(k) = p_n <-> a'_resp(k) = e_n)
```

This biconditional links Spoiler's selections (a_init) relative to p_n (on N-side) with Duplicator's responses (a'_resp) relative to e_n (on M-side).

### How the Current Code Provides It

tau_left is a backward game on [d, p_n] -> [c, e_n]. Its game tuple is:
- N-side: d, a_init(0),...,a_init(n-1), b_resp, p_n  (positions 0, 1..n, n+1, n+2)
- M-side: c, resp_left(0),...,resp_left(n-1), b_sp, e_n  (positions 0, 1..n, n+1, n+2)

At positions (1+k, n+2): `(a_init(k) < p_n iff resp_left(k) < e_n)`. This is EXACTLY the biconditional needed, because p_n and e_n are ENDPOINTS of the game.

### Why the Restricted Tau Fails

The restricted tau on [d, b'] -> [c, b] (with b >= e_n, b' >= p_n) has game tuple:
- N-side: d, a_init(0),...,a_init(n-1), b_resp, b'  (positions 0, 1..n, n+1, n+2)
- M-side: c, resp_restricted(0),...,resp_restricted(n-1), b_sp, b  (positions 0, 1..n, n+1, n+2)

At positions (1+k, n+2): `(a_init(k) < b' iff resp_restricted(k) < b)`. Since b' >= p_n and b >= e_n, these orderings are WEAKER:
- `a_init(k) < b'` does NOT imply `a_init(k) < p_n` (because b' > p_n is possible)
- `resp_restricted(k) < b` does NOT imply `resp_restricted(k) < e_n` (because b > e_n is possible)

When b = e_n and b' = p_n, the restricted tau IS tau_left. So the supremum (b > e_n) makes things WORSE, not better.

### Why Challenging with e_n in Round 2 Doesn't Help

If we challenge the restricted tau's Round 2 with e_n_pt, we get some b_resp in [d, b'] with:
```
(a_init(k) < b_resp iff resp_restricted(k) < e_n)
```

This gives orderings between resp_restricted(k) and e_n. But we need orderings between a_init(k) and p_n, not between a_init(k) and b_resp. Since b_resp is not necessarily p_n (it's just SOME carrier point with the same rank-r type), we cannot substitute.

### The Root Cause: Finite vs Continuous

GHR93's mathematical argument (pp.806-810) claims that a single tau on [d-bar, b'] -> [c, b] provides orderings relative to ALL points in the interval, including p_n and e_n. This is true in the model-theoretic sense: the order-type preservation is a property of the FULL configuration, not just finitely many positions.

The Lean formalization uses `ghr93_duplicator_wins` which is a finite-position game: Spoiler picks n elements, Duplicator responds with n elements, then one Round 2 pair. The `same_order_type` condition applies to exactly n+3 positions. Orderings at other points in the interval are NOT available from the game's winning condition.

To get orderings at a specific point (like p_n or e_n), that point must be a POSITION in the game -- either an endpoint, a selection, or a Round 2 element. The current code achieves this by making p_n and e_n endpoints of sub-games (tau_left: [d, p_n] -> [c, e_n]).

## What the Current Architecture Achieves

The current ghr93_case_II is:
- **Sorry-free**: All 769 lines compile without sorry
- **Axiom-clean**: `#print axioms ghr93_case_II` shows no sorryAx (propext, Classical.choice, Quot.sound only)
- **Mathematically correct**: The 3-way Round 2 case split (A/B1/B2) covers exactly the same cases as GHR93's 5-way split
- **Complete infrastructure**: ghr93_untl_transfer and ghr93_construct_en are proved and available as reusable infrastructure

The tau_left/tau_right decomposition is the correct Lean formalization of GHR93's single-tau argument. It bridges the gap between continuous and discrete by instantiating additional games at the specific points where orderings are needed.

## Possible Resolutions

### Option A: Accept Current Architecture (Recommended)
The current code IS correct and sorry-free. The tau_left/tau_right pattern is the natural Lean encoding of GHR93's order-type argument. No changes needed for Phase 5; proceed to Phase 6 (Cases III/IV) and Phase 7 (Transfer.lean wiring).

### Option B: Reformulate same_order_type_of_cases
Instead of requiring biconditional orderings `(a < p_n iff resp < e_n)`, accept one-directional bounds `(resp(k) <= e_n for all k < n)` plus a separate monotonicity argument. This would require significant changes to EFGameTactics.lean and might introduce new complexities.

### Option C: Extend Game Definition
Add a "multi-challenge" variant of ghr93_duplicator_wins that allows multiple Round 2 challenges simultaneously, providing orderings between all challenge points and selections. This would be a major extension to CustomGame.lean (~200-400 lines) and might not match GHR93's game definition.

### Option D: Richer Game Invariant
Strengthen the game's winning condition to include order-type preservation at arbitrary interior points (not just game positions). This would require a fundamentally different formalization approach and would affect all downstream users of ghr93_duplicator_wins.

## Immediate Next Action

Proceed to Phase 6 (Cases III/IV gap handling) or Phase 7 (Transfer.lean wiring), both of which are independent of the Phase 5 code transformation. The existing ghr93_case_II is sorry-free and correct.

## Files NOT Modified

No Lean files were modified in this session. The blocker was identified through analysis before any code changes were attempted.
