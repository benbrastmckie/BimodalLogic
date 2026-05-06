# Phase 5-6 Handoff: C4/C4' c2' Inline Construction

## Session
- Session: sess_1778014444_dca927
- Date: 2026-05-05

## Progress Summary

### Completed
1. **C4 forward c2' sorry CLOSED** (old line 1215): Replaced `eliminate_C4_counterexample` call with inline construction using `lemma_2_6_splitting`. The c2' condition is now proved for the case where the guard formula xi can be shown to NOT be in g(w, w_next).

2. **C4' backward c2' sorry CLOSED** (old line 1253): Mirror of the above for the Since direction, using `burgessRSetSince` to show xi not in g(w_prev, w).

3. **Key mathematical fact proved**: For any adjacent pair (w, w_next) where neg(untl(xi, eta)) in f(w) and eta in f(w_next): xi not in g(w, w_next). Proof: if xi in g, then by burgessRSet, untl(xi, eta) in f(w), contradicting neg(untl(xi, eta)). Similarly for Since direction.

### New Sorry Locations

The old 2 c2' sorries are replaced by 2 more specific sub-case sorries:

| Line | Location | Type | Difficulty |
|------|----------|------|------------|
| 1400 | eliminate_potential_counterexample (C4 forward) | eta not in f(w_next) sub-case | HARD (Burgess 2.9 induction) |
| 1619 | eliminate_potential_counterexample (C4' backward) | eta not in f(w_prev) sub-case | HARD (mirror) |

These sub-cases arise when:
- w is the rightmost (resp. leftmost) domain point with neg-until (resp. neg-since)
- w_next (resp. w_prev) does NOT contain eta (the event formula)
- This means w_next < y (resp. w_prev > y), and eta is not at w_next

In this sub-case, we cannot prove xi not in g(w, w_next) because the burgessRSet argument requires eta in f(w_next) to produce the contradiction untl(xi, eta) in f(w).

### Unchanged Sorries

| Line | Location | Type |
|------|----------|------|
| 586 | eliminate_C4_counterexample | C4 hard case (NOW DEAD CODE) |
| 684 | eliminate_C4'_counterexample | C4' hard case (NOW DEAD CODE) |
| 990 | eliminate_potential_counterexample (C5 forward) | n>=1 sub-case of c2' |
| 1104 | eliminate_potential_counterexample (C5' backward) | n>=1 sub-case of c2' |

Lines 586 and 684 are now in dead code -- `eliminate_C4_counterexample` and `eliminate_C4'_counterexample` are no longer called by `eliminate_potential_counterexample`. They could be removed.

### Technical Details

#### Approach for C4/C4' c2'

1. Find w = rightmost (C4) or leftmost (C4') domain point with neg-until/since
2. Find successor w_next (C4) or predecessor w_prev (C4')
3. Prove xi not in g(w, w_next) using burgessRSet/burgessRSetSince
4. Apply `lemma_2_6_splitting` with beta = xi to get B', D, B''
5. Insert z = midpoint of (w, w_next), set f'(z) = D, g'(w,z) = B', g'(z,w_next) = B''
6. c2' follows from splitting output (new pairs) and h_c2' (old pairs)

#### Why the Hard Sub-Case is Hard

When eta not in f(w_next) and w_next < y:
- untl(xi, eta) in f(w_next) (since w is rightmost with neg-until)
- xi in g(w, w_next) is consistent: burgessRSet gives U(xi, untl(xi,eta)) in f(w),
  but U(xi, U(xi,eta)) does NOT imply U(xi,eta) under open guard semantics
- The gap at the eventuality point of U(xi, U(xi,eta)) prevents chaining
- Full Burgess 2.9 induction (case n=m+1) is needed:
  either reduce by replacing x with x', or split (x, x') using lemma 2.7/2.8

#### Why C5 n>=1 is Hard

When pc.x != max_old: the construction places y after all points with g'(max_old, y) = B.
But B satisfies BurgessR3Maximal(f(pc.x), B, C), NOT BurgessR3Maximal(f(max_old), B, C).
Getting g_content(f(max_old)) subset of C is NOT provable from g_content(f(pc.x)) subset of C
because G-formulas propagate FORWARD (from left to right), not backward.
The fix requires either:
- Placing y after pc.x (not after all points) and using a different splitting strategy
- Full Burgess 2.10 induction (replace x by its successor, reduce n)

### File Locations
- CounterexampleElimination.lean: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean`
- PointInsertion.lean: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean`
