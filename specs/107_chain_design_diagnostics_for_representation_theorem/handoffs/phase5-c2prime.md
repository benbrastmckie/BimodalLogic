# Phase 5 Handoff: c2' Co-Construction

## Session
- Session: sess_1778014444_dca927
- Date: 2026-05-05

## Progress Summary

### Completed
1. **Density c2' sorry closed** (was line 1034). Restructured density case to use `lemma_2_6_splitting` with updated g-function for new adjacent pairs.

2. **Three helper lemmas added** (lines 155-268):
   - `BurgessR3Maximal_g_content_sub`: Proves `BurgessR3Maximal(A, B, C) -> g_content(A) subseteq C` for MCS A, C. KEY INSIGHT - this was the missing connection that unlocks all splitting lemmas.
   - `BurgessR3Maximal_sdc`: Proves `BurgessR3Maximal(A, B, C) -> SetDeductivelyClosed(B)` using NoUnivBurgessR3.
   - `c2'_preserved_on_old_adjacent`: Helper for proving c2' for old pairs.

3. **Build passes** with 6 sorries in CE file (down from 7).

### Remaining c2' Sorries (4)

| Sorry | Line | Case | Difficulty |
|-------|------|------|------------|
| C5 forward | 872 | Point beyond max | HARD |
| C5 backward | 910 | Point before min | HARD (mirror) |
| C4 forward | 950 | Point between x,y | MEDIUM |
| C4 backward | 988 | Point between y,x | MEDIUM (mirror) |

### Key Technical Insight

**BurgessR3Maximal implies g_content subset**: This was the critical missing piece. The proof:
- Suppose G(phi) in A but phi not in C.
- Then phi.neg in C (MCS).
- Top (theorem) is in B (CUD has theorems).
- burgessRSet(A, B, C): untl(top, phi.neg) in A.
- BX10 (until_F): F(phi.neg) in A.
- But G(phi) in A means not-F(phi.neg) in A. Contradiction.

This means h_c2' gives g_content(f(a)) subseteq f(b) for all adjacent pairs, which satisfies the precondition of `lemma_2_6_splitting` and `lemma_2_7`.

### Strategy for Remaining Cases

#### C4 Forward/Backward (Lines 950, 988)
These need the same restructuring as density: use `lemma_2_6_splitting` to produce B', D, B'' from the old adjacent pair, and update g for new pairs.

**Complication**: The C4 case creates z between ce.x and ce.y, but they may NOT be adjacent. If there are domain points between them, z splits a different adjacent pair than (ce.x, ce.y).

**Approach**: 
1. Find which adjacent pair (a, b) in old domain contains z (a < z < b with no old point between).
2. Apply lemma_2_6_splitting on (a, b).
3. The D from splitting has beta.neg in D (beta chosen appropriately).
4. For the C4 case: need gamma.neg in f(z). If we choose beta = gamma, then D has gamma.neg.
5. But: the current `eliminate_C4_counterexample` does complex case analysis and might return a DIFFERENT D.

**Better approach**: Don't use `eliminate_C4_counterexample` at all. Instead, construct directly:
1. Find z between ce.x and ce.y, NOT in domain.
2. Find which adjacent pair (a, b) contains z.
3. Apply lemma_2_6_splitting with beta = gamma on (a, b). Get D with gamma.neg in D.
4. Set f(z) = D, g'(a, z) = B', g'(z, b) = B''.
5. c2' follows from the splitting.
6. c4_forward_witness: z is in the new domain, ce.x < z < ce.y, gamma.neg in f(z).

Wait -- the z from step 1 must be between ce.x and ce.y (for the C4 witness), but the adjacent pair containing z is (a, b). We need a = ce.x or a > ce.x, and b = ce.y or b < ce.y. Actually z is between ce.x and ce.y, so a <= ce.x and b >= ce.y? No -- z just needs to be between ce.x and ce.y. The adjacent pair (a, b) containing z has a < z < b, but a could be less than ce.x.

Actually, the adjacent pair containing z is uniquely determined: z is in the open interval (a, b) where (a, b) are adjacent in old domain. Since z is between ce.x and ce.y and NOT in old domain, the pair (a, b) satisfies a < z < b.

For lemma_2_6_splitting with beta = gamma: need gamma not-in g(a, b). If gamma in g(a, b), need a different approach.

**Key issue for C4**: `lemma_2_6_splitting` requires beta not-in B, but we need SPECIFIC beta = gamma for the C4 witness. If gamma is in g(a, b), we can't use it as the splitting formula. This is Burgess's "hard case" (gamma in f(x) AND gamma in f(y)), which is already the sorry at lines 527/625.

So for C4 with the "easy case" (gamma.neg in f(x) or gamma.neg in f(y)): the D is just f(x) or f(y) from the existing domain, no new point is needed, and the chronicle is returned unchanged. c2' = h_c2'.

For C4 with the "hard case": this is the separate sorry (527/625), which is a different problem. The c2' sorry (950) only applies when `eliminate_C4_counterexample` produces a result, and in the easy cases that result has g unchanged but the D is from the existing domain.

Wait, let me re-read the C4 elimination more carefully...

#### C5 Forward/Backward (Lines 872, 910)
These are the hardest. The new point y is placed at an extreme (beyond max or before min).

**When ce.x = max(dom)**: Direct approach with lemma_2_4. Get B, C from lemma_2_4 with A = f(ce.x). Set f(y) = C, g'(ce.x, y) = B. BurgessR3Maximal comes directly.

**When ce.x != max(dom)**: This requires Burgess 2.10 case n >= 1 (induction). Key steps:
1. Let x' = successor of ce.x in domain.
2. Check Burgess conditions (i) and (ii).
3. Either reduce to smaller case or apply lemma_2_7/2.8.
4. This is fundamentally different from the current "place y after everything" approach.

**Alternative for C5**: Instead of placing y after everything, place y between ce.x and its successor. Use lemma_2_7 (which gives eta in D, xi in B') to get a D that works as f(y). This requires xi not-in g(ce.x, successor), which we'd need to verify or use a different splitting.

### Architecture Decision
The density case shows the pattern works: use lemma_2_6_splitting to get B', D, B'' and update g for new pairs. The same pattern extends to C4 (with proper beta choice) and potentially C5 (with lemma_2_7 instead of lemma_2_6_splitting).

### File Locations
- CounterexampleElimination.lean: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean`
- PointInsertion.lean (lemma_2_4, lemma_2_6_splitting, lemma_2_7): `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean`
- RRelation.lean (burgessR3Maximal_from_g_content_sub, burgessR3Maximal_extension_exists): `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Chronicle/RRelation.lean`
- ChronicleTypes.lean (BurgessR3Maximal definition, c2' definition): `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleTypes.lean`
