# Handoff: Lemma 2.8 Implementation and Since Mirror

## Session: sess_1778014444_dca927

## What Was Done

### 1. Lemma 2.8 implemented (PointInsertion.lean)

Added `lemma_2_8_seed_consistent` and `lemma_2_8` after the existing `lemma_2_7`.

**Burgess 2.8**: Given R(A,B,C), U(xi,eta) in A, and neg(eta or (xi and U(xi,eta))) in C, the conclusion of 2.7 holds (split into B', D, B'' with eta in D).

The seed is the same as `lemma_2_7_seed`. The consistency proof differs:
- No maximality witness (beta0, gamma0) needed
- D1/D2 elimination uses gamma' = neg(eta or chi_gen) in C to derive contradictions:
  - D1 event has gamma_hat and eta; since gamma_hat implies gamma' implies neg_eta, the event is contradictory
  - D2 event has gamma_hat and chi_gen; since gamma' implies neg_chi_gen, the event is contradictory
- D3 survives and the BX13 enrichment chain is identical to 2.7

### 2. CE:862 partially closed (CounterexampleElimination.lean)

The original sorry at CE:862 (forward Until, C5a case n>=1) had hypotheses:
- xi in g, eta not in g, eta.neg in g
- untl(xi, eta) in f(x)
- BurgessR3Maximal(f(x), g(x,x'), f(x'))

Replaced with a 3-way case split:

**Case A** (xi and untl(xi,eta) not in g): CLOSED.
- Apply BX5 to get untl(xi and untl(xi,eta), eta) in f(x)
- Apply lemma_2_7 with guard = xi and untl(xi,eta) (which is not in g)
- The accumulated guard is not in g, so lemma_2_7 applies directly

**Case B.2** (xi and untl(xi,eta) in g, but not in f(x')): CLOSED.
- Derive neg(eta or (xi and untl(xi,eta))) in f(x') via De Morgan
- Apply lemma_2_8

**Case B.1** (xi and untl(xi,eta) in g AND in f(x')): SORRY REMAINS.
- This is Burgess condition (i): the Until formula propagates to x'
- Neither lemma_2_7 nor lemma_2_8 applies
- Burgess handles this by induction on n (replace x by x')
- The code architecture commits to splitting at (x,x') and cannot recurse
- Requires restructuring `eliminate_potential_counterexample` to support condition (i) reduction

### 3. CE:1197 unchanged (Since mirror)

The backward (Since) case at CE:1197 needs Since mirrors of lemma_2_7 and lemma_2_8.
The mirror involves:
- `lemma_2_7_since_seed`: like lemma_2_7_seed but with 5th component being untl(beta and xi, gamma) for gamma in C instead of snce(beta and xi, alpha) for alpha in A
- `lemma_2_7_since_seed_consistent`: BX5'+BX7' chain on C-side Since formulas
- `lemma_2_7_since` and `lemma_2_8_since`: full theorems

## Current Sorry Count

- CE:861 (condition (i), forward Until case) — requires Burgess 2.10 induction
- CE:1197 (backward Since case) — requires lemma_2_7_since/lemma_2_8_since implementation
- CTC:634, CTC:638 (FUC/FSC coherence) — separate task

## Remaining Work

### Priority 1: CE:1197 (Since mirror, ~6-8 hours)
1. Define `lemma_2_7_since_seed` (5th component: untl(beta and xi, gamma) with gamma in C)
2. Implement seed extractors (l27s_collect_guards, l27s_c_event_list, l27s_a_event_list)
3. Prove `lemma_2_7_since_seed_consistent` with BX5'+BX7' chain
4. Prove `lemma_2_7_since` using the seed + Zorn
5. Prove `lemma_2_8_since` with gamma' based D1/D2 elimination
6. Apply at CE:1197 with same case split as CE:862

### Priority 2: CE:861 (condition (i), ~4-6 hours)
Two approaches:
a. Restructure `eliminate_potential_counterexample` to add condition (i) check BEFORE the split. When (i) holds, replace x by x' and recurse (requires well-founded induction on dom size after x).
b. Prove that condition (i) is actually impossible in the code's case structure (if BurgessR3Maximal with xi in g forces xi and untl(xi,eta) not in f(x')).

### Files Modified
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` — added lemma_2_8_seed_consistent, lemma_2_8 (~250 lines)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` — restructured CE:862 sorry into 3-way case split
