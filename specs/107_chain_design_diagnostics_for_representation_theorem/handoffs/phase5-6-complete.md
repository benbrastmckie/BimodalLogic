# Phase 5-6 Completion: C4/C4' Sorries Closed + Dead Code Removed

## Session
- Session: sess_1778014444_dca927
- Date: 2026-05-05

## Changes Made

### 1. Dead Code Deletion (2 sorries removed)
Deleted the unused `eliminate_C4_counterexample` and `eliminate_C4'_counterexample` functions
along with their supporting structures `C4Counterexample` and `C4'Counterexample` from
CounterexampleElimination.lean. These functions were no longer called by
`eliminate_potential_counterexample` and contained 2 sorries.

### 2. C4 Forward Sorry CLOSED (line 1135 -> 0 sorries)
The sorry at the eta-not-in-f(w_next) sub-case of the C4 forward elimination
was closed using the Burgess 2.9 case n=m+1 argument:

**Proof strategy (Burgess 2.9 induction)**:
1. Derive `xi in f(w_next)` from `h_no_wit` (no xi.neg between pc.x and pc.y)
   and the fact that `pc.x < w_next < pc.y`.
2. Form `xi AND untl(xi, eta) in f(w_next)` via `dcs_conj_closed` (MCS conjunction).
3. Apply `burgessRSet` with beta=xi, gamma=`xi AND untl(xi, eta)`:
   `untl(xi, xi AND untl(xi, eta)) in f(w)`.
4. Apply BX6 absorption (`Axiom.absorb_until`):
   `untl(xi, xi AND untl(xi, eta)) -> untl(xi, eta)`.
5. Contradiction with `neg(untl(xi, eta)) in f(w)`.

### 3. C4' Backward Sorry CLOSED (line 1364 -> 0 sorries)
Mirror of the above for the Since direction:
1. Derive `xi in f(w_prev)` from `h_no_wit` and `pc.y < w_prev < pc.x`.
2. Form `xi AND snce(xi, eta) in f(w_prev)` via `dcs_conj_closed`.
3. Apply `burgessRSetSince` with beta=xi, gamma=`xi AND snce(xi, eta)`:
   `snce(xi, xi AND snce(xi, eta)) in f(w)`.
4. Apply BX6' absorption (`Axiom.absorb_since`):
   `snce(xi, xi AND snce(xi, eta)) -> snce(xi, eta)`.
5. Contradiction with `neg(snce(xi, eta)) in f(w)`.

### 4. Comment Cleanup
Removed ~70 lines of stale analysis comments that documented wrong approaches
to the C4/C4' sorry sites. Replaced with concise 4-line summary of the proof strategy.

Updated reference in ChronicleConstruction.lean from `eliminate_C4_counterexample`
to `eliminate_potential_counterexample (C4 case)`.

## Remaining Sorries in CE (2)

| Line | Location | Type | Why Hard |
|------|----------|------|----------|
| 725 | eliminate_potential_counterexample (C5 forward) | BurgessR3Maximal(f(max_old), B, C) when pc.x != max_old | Requires Burgess 2.10 induction: B/C constructed for f(pc.x), not f(max_old). g_content(f(max_old)) not implied by g_content(f(pc.x)). |
| 839 | eliminate_potential_counterexample (C5' backward) | exists B_new, BurgessR3Maximal(C, B_new, f(min_old)) when pc.x != min_old | Mirror of above: h_content(f(pc.x)) subset C doesn't give h_content(f(min_old)) subset C. |

### Why C5/C5' n>=1 Cannot Be Closed Without Restructuring
The current proof places the new point y after ALL domain points (C5) or before ALL
domain points (C5'). This creates a new adjacent pair (max_old, y) or (y, min_old) that
needs BurgessR3Maximal for f(max_old)/f(min_old). But the B/C were constructed for
f(pc.x), which may differ from f(max_old)/f(min_old).

The correct Burgess 2.10 approach requires induction on n (number of domain points
after/before pc.x), either:
- Moving to x' (successor/predecessor of pc.x) and recursing with n-1, or
- Splitting (pc.x, x') to handle the gap.

This would require restructuring `eliminate_potential_counterexample` to use well-founded
induction on domain size, which is a significant architectural change.

## File Locations
- CounterexampleElimination.lean: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean`
- ChronicleConstruction.lean: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean`

## Sorry Count Summary
- CE file: 6 -> 2 (removed 4: 2 dead code + 2 C4/C4' closed)
- CTC file: 2 -> 2 (unchanged)
- Total project: no change in axiom count (4)
- Build: passes (1097 jobs)
