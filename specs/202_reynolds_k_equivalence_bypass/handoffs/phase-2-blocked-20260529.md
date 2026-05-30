# Phase 2 Blocked Handoff

## Session
- Session ID: sess_1748545200_orch202
- Date: 2026-05-29
- Agent: lean-implementation-agent (plan v10)

## What Was Done

### Deep Mathematical Analysis of `no_gaps_prior`

Performed exhaustive analysis of the theorem statement and proof approaches. Key finding: the theorem `no_gaps_prior` (ReynoldsNoGaps.lean:277-292) is **mathematically incorrect as stated**.

### Counterexample

**Structure**: M.carrier = Z + Z (two disjoint copies of integers, first copy entirely below the second). M.interp p x = True for all predicates p and all points x (constant predicates).

**Why it satisfies all hypotheses**:
1. SuccOrder: succ(n) = n+1 within each copy
2. PredOrder: pred(n) = n-1 within each copy
3. NoMaxOrder, NoMinOrder: each copy extends infinitely
4. h_surj: trivially satisfied (every predicate maps to an atom)
5. Prior-UZ: satisfied because ALL temporal formulas evaluate to constants (True or False at every point). Proved by structural induction on Formula: atoms are constant (constant predicates), bot is False everywhere, imp/neg preserve constancy, box is constant (predicates), and U(phi,psi) with constant phi/psi evaluates to a constant (True if phi is True, False if phi is False, True if phi True and psi False in discrete case since succ(t) exists). The "first occurrence" is always succ(t) with empty guard interval.
6. Prior-SZ: same argument mirrored.

**Why it has a gap**: The cut = first copy is successor-closed, nonempty, proper. Its complement = second copy is predecessor-closed with no minimum. This is a Dedekind Gap.

### Analysis of Alternative Approaches

1. **Reynolds model surgery (Lemmas 6-13)**: The Reynolds argument from the 1994 paper works for "faithful" structures where temporal truth determines/is determined by predicate truth. The abstract theorem lacks this faithfulness hypothesis.

2. **Direct proof of `succ_cofinal`**: The existing `succ_reaches_dom_N` (ChronicleToCountermodel.lean:1147-1448) handles the "between" case but has two sorry'd boundary cases:
   - Line 1285: b above max(dom(N)), where succ(max_N_sub) might enter limit_dom at an arbitrarily later stage
   - Line 1441: a below min(dom(N)), symmetric boundary case

3. **Convergence approach**: Previously attempted (archived in Boneyard/DeadConvergenceProof/). Failed because the successor sequence's limit might not be in limit_dom, and pred(z) at the limit point might not be in the successor orbit.

## What Remains

### Three Viable Paths Forward

**Path A: Fix `no_gaps_prior` statement**
Add faithfulness hypothesis: `forall t phi, temporal_truth M atomMap t phi <-> M.interp (atomMap phi) t`. Then prove the corrected theorem using Reynolds' argument (model surgery). Verify the chronicle satisfies the new hypothesis via `chronicle_temporal_truth_effective`. Estimated: 600-1000 lines.

**Path B: Prove `succ_cofinal` at ChronicleAsPriorModel level**
Bypass the abstract `no_gaps_prior` entirely. Prove succ_cofinal using the specific properties of ChronicleAsPriorModel (MCS structure, C4/C5 coherence, Prior-UZ/SZ in MCS form). The key argument: if a gap existed, the MCS-level Prior-SZ would be violated (the LAST occurrence of a distinguishing formula below a complement point would require a maximum of the cut, which doesn't exist). Requires showing that a distinguishing formula EXISTS in the MCS setting. Estimated: 300-500 lines.

**Path C: Fix boundary cases in `succ_reaches_dom_N`**
The two sorry'd boundary cases at lines 1285 and 1441 might be fixable with a different induction principle. Instead of inducting on N (the stage), use well-founded induction on a pair like (N, max_dom(N) - a.val) or use transfinite induction on the rational distance. The key obstacle is that succ(max_N_sub) might enter at a later stage M > N+1, and we need to handle M > N+1 within the induction. This might require changing from induction on N to induction on the PAIR (a, b) with well-founded order on rational distance. Estimated: 200-400 lines.

## Immediate Next Action

A plan revision (v11) is needed to address the mathematical incorrectness of `no_gaps_prior` and choose one of the three viable paths. Path B or C appear most promising as they avoid the 600+ line Reynolds model surgery formalization.

## Key Files
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/ReynoldsNoGaps.lean` -- contains the incorrect `no_gaps_prior` (line 292)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- contains `succ_cofinal` (line 1510) and `succ_reaches_dom_N` (lines 1147-1448)
- `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` -- contains `chronicle_temporal_truth_effective` (faithfulness bridge)
- `Theories/Bimodal/Metalogic/WeakCanonical/ChronicleExtraction.lean` -- contains `ChronicleAsPriorModel` structure (line 85)
