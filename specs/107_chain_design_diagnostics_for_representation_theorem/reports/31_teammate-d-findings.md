# Teammate D Findings: Horizons -- The Correct Architecture

**Task**: 107 - Burgess chronicle construction for BX representation theorem
**Date**: 2026-04-26
**Angle**: Burgess's truth lemma structure, dependency analysis, gamma=top edge case

## 1. Burgess's Proof of Claim 2.11 (Truth Lemma): Complete Structure

### What is being proved

For every formula alpha and every x in the limit domain X:

> alpha in f(x) if and only if x in V(alpha)

where V is the valuation defined by V(p_i) = {x : p_i in f(x)} for atoms.

### Induction variable

Formula complexity (structural induction on alpha).

### Case-by-case analysis

**Atom p_i**: By definition of V. This is the base case.

**Negation (neg alpha)**: V(neg alpha) = X \ V(alpha). By IH, alpha in f(x) iff x in V(alpha). Since f(x) is MCS, neg(alpha) in f(x) iff alpha not in f(x) iff x not in V(alpha) iff x in V(neg alpha). No chronicle conditions needed beyond C0.

**Conjunction (alpha and beta)**: V(alpha and beta) = V(alpha) intersect V(beta). By IH plus MCS closure under conjunction. No chronicle conditions needed beyond C0.

**Until (U(gamma, delta))** -- this is the critical case:

- **Forward direction** (alpha in f(x) implies x in V(alpha)):
  If U(gamma, delta) in f(x), then by **C5** there exists y in X with x < y, delta in f(y), and gamma in g(x,y). For any z with x < z < y, by **C3**: g(x,y) subset f(z), hence gamma in f(z). By IH, y in V(delta) and z in V(gamma) for all such z. Hence x in V(U(gamma, delta)).

- **Backward direction** (x in V(alpha) implies alpha in f(x)):
  Suppose neg(U(gamma, delta)) in f(x) (for contradiction). Take any y > x with y in V(delta). By IH, delta in f(y). By **C4**, there exists z with x < z < y and neg(gamma) in f(z). By IH, z not in V(gamma). So the semantic Until condition fails at x. Hence x not in V(U(gamma, delta)). Contrapositive: x in V(U(gamma, delta)) implies U(gamma, delta) in f(x).

**Since (S(gamma, delta))**: Mirror of Until, using C5' and C4'.

**G(alpha)**: Burgess does NOT have G as a primitive connective. G(alpha) = neg(U(neg(alpha), top)) = neg(F(neg(alpha))). So the G case reduces to the Until case via the abbreviation. Specifically:
- G(alpha) in f(x) iff neg(untl(top, neg(alpha))) in f(x) (by BX12 contrapositive: G(phi) iff neg(F(neg(phi))) iff neg(untl(top, neg(phi))))
- Wait: actually F(alpha) = U(alpha, top) in Burgess. So G(alpha) = neg(F(neg(alpha))) = neg(U(neg(alpha), top)).

But in the codebase, G and H are separate connectives with their own axioms, and the truth lemma for G uses forward_G (a consequence of C4, not an independent lemma).

### Where each condition appears

| Case | Forward (phi in f(x) -> x in V(phi)) | Backward (x in V(phi) -> phi in f(x)) |
|------|---------------------------------------|----------------------------------------|
| Atom | Definition | Definition |
| Neg | C0 (MCS) | C0 (MCS) |
| Conj | C0 (MCS) | C0 (MCS) |
| Until | **C5** (witness) + **C3** (guard propagation) | **C4** (counterexample) |
| Since | **C5'** + **C3** | **C4'** |
| G | Consequence of Until case | Consequence of Until case |
| H | Consequence of Since case | Consequence of Since case |

### Is there any circularity in Burgess's proof?

**No.** The proof is a clean structural induction. Each case uses only:
- Chronicle conditions (C0-C5) which are properties of the *limit* chronicle
- The induction hypothesis for *sub-formulas*

There is no mutual recursion between cases. The G case reduces to the Until case by definition. C4 and C5 are properties of the limit chronicle, proved before the truth lemma.

## 2. BUC and FUC: Cases of the Truth Lemma, Not Separate Lemmas

In Burgess's paper, there are no separate "BUC" and "FUC" lemmas. What the codebase calls:

- **FUC** (Forward Until Coherence): "U(gamma, delta) in f(x) implies there exists y > x with delta in f(y) and gamma holds on (x,y)" -- this is the **forward direction of the Until case** of the truth lemma
- **BUC** (Backward Until Coherence): "semantic Until pattern implies U(gamma, delta) in f(x)" -- this is the **backward direction of the Until case** of the truth lemma

In Burgess's structure:

- FUC uses **C5** (Until witness existence) + **C3** (interval subset property for guard)
- BUC uses **C4** (counterexample: if neg(U) in f(x) and delta in f(y), get neg(gamma) intermediate)

The dependency structure is:

```
Truth lemma (induction on phi)
  Until forward: C5 + C3
  Until backward: C4
  G case: reduces to Until (Burgess) or uses forward_G (codebase)
```

**BUC IS the backward Until case.** It depends on C4. It does NOT depend on forward_G or limit_forward_G. It depends on C4 at the LIMIT, which holds because C4 was ensured at every finite stage by the omega-chain construction (counterexample elimination).

## 3. Does C4 at the Limit Depend on forward_G?

### In Burgess: NO

Burgess's proof structure:

1. Define the finite chronicle conditions C0-C3 (Lemma 2.9 setup)
2. Prove Lemma 2.9: every C4 counterexample at a finite stage can be eliminated by inserting one point
3. Build omega chain where each finite stage satisfies C0-C3 and C4/C5 counterexamples are systematically eliminated
4. At the limit: C4 holds because every counterexample was eventually eliminated (by step 2)
5. forward_G is a CONSEQUENCE of C4 at the limit (proved as in the codebase's `limit_forward_G`)

There is **no circularity** in Burgess. The dependency is strictly:

```
Lemma 2.6 (splitting) -> Lemma 2.9 (C4 elimination at finite stages) ->
omega chain -> C4 at limit -> forward_G at limit -> truth lemma
```

### In the codebase: CIRCULAR (confirmed)

The codebase has:
- `limit_forward_G` calls `limit_satisfies_c4` (line 1060)
- `limit_satisfies_c4` calls `omega_chain_c4_witness` which calls `eliminate_C4_counterexample`
- `eliminate_C4_counterexample` has a `sorry` at line 332 (the hard case)

This is not technically a forward_G -> C4 -> forward_G cycle, but rather a cycle where the sorry in C4 elimination blocks C4 at the limit, which blocks forward_G.

The key question is: **can the C4 hard case sorry (line 332) be closed?**

## 4. The Codebase's Error and the Fix

### The error

The C4 hard case at line 332 requires: given gamma in f(x), G(gamma) in f(x), gamma in f(y), H(gamma) in f(y), and neg(untl(gamma, delta)) in f(x), and delta in f(y), find z between x and y with neg(gamma) in f(z).

The current code structure tries to close this by using `limit_forward_G` (which would propagate G(gamma) to all future points, making neg(gamma) impossible). But `limit_forward_G` depends on `limit_satisfies_c4`, creating the dependency issue.

### The Burgess approach

Burgess's Lemma 2.9 operates at **finite stages**. The C4 hard case at a finite stage uses Lemma 2.6 (splitting), which requires **BurgessR3Maximal g-values** at adjacent pairs.

The argument (Lemma 2.6 applied to C4):

1. We have R(f(x), g(x,y), f(y)) -- BurgessR3Maximal for adjacent pair
2. neg(untl(gamma, delta)) in f(x), delta in f(y)
3. By `burgessR3_gamma_not_in_B`: gamma not in g(x,y) (because if gamma in g(x,y), then untl(gamma, delta) in f(x) by burgessR3, contradicting neg(untl(gamma, delta)) in f(x))
4. Since g(x,y) is a DCS and gamma not in g(x,y): {gamma.neg} union g(x,y) is consistent (by `dcs_neg_insert_consistent`)
5. Apply Lindenbaum to get MCS D containing gamma.neg
6. Insert z with f(z) = D, and define g(x,z), g(z,y) via Lemma 2.6

**This works at finite stages without ANY reference to the limit, forward_G, or the truth lemma.**

### The fix

The codebase already has steps 2-4 proved sorry-free (`burgessR3_gamma_not_in_B`, `dcs_neg_insert_consistent`). What is missing:

1. **BurgessR3Maximal g-values at finite stages**: The current `limit_g` is a placeholder (`deductiveClosure(g_content(limit_f(x)))`). The omega chain needs to be rebuilt so that each finite stage constructs BurgessR3Maximal interval sets.

2. **Lemma 2.6 adapted for BurgessR3Maximal**: The splitting lemma that, given BurgessR3Maximal(f(x), g(x,y), f(y)) and delta not in g(x,y), produces BurgessR3Maximal(f(x), g(x,z), f(z)) and BurgessR3Maximal(f(z), g(z,y), f(y)) with g(x,y) = g(x,z) intersect f(z) intersect g(z,y).

## 5. Proposed Architecture: Validated

### Phase A: Build omega chain maintaining invariants at every finite stage

At each finite stage, the chronicle (f_n, g_n) satisfies:
- C0: f_n maps dom_n to MCS
- C1: g_n maps adjacent pairs to DCS
- C2': BurgessR3Maximal(f(x), g(x,y), f(y)) for adjacent pairs
- C3: g(x,z) = g(x,y) intersect f(y) intersect g(y,z) for x < y < z in dom_n

When inserting a new point z between x and y:
- Use Lemma 2.6 (BurgessR3Maximal splitting) to construct g(x,z) and g(z,y)
- C3 is maintained by definition (non-adjacent g values are defined by intersection)
- C4 counterexample is eliminated because gamma.neg in f(z) (by step 5 above)

### Phase B: At the limit

- C4 holds: every counterexample was eliminated at some finite stage
- C5 holds: every Until formula gets a witness at some finite stage
- forward_G holds: consequence of C4 at the limit (already proved in codebase)
- Truth lemma by formula induction: uses C3 (guard at intermediate points), C4 (backward Until), C5 (forward Until)

**This is exactly what Burgess does. There is no circularity.**

### Is this correct? Are there subtleties I am missing?

One subtlety: Burgess's Lemma 2.9 handles the case n > 0 (intermediate points between x and y) by induction on n. The case n = 0 (adjacent) uses Lemma 2.6 directly. The case n = m+1 (non-adjacent) either reduces to a smaller n (if neg(untl(gamma, delta)) propagates to the next point) or to n = 0 (by replacing gamma with a stronger formula).

The codebase's current `eliminate_C4_counterexample` does NOT do this induction on n. It case-splits on G(gamma) in f(x) vs not and H(gamma) in f(y) vs not. This case analysis is NOT what Burgess does. Burgess's approach uses the BurgessR3Maximal structure directly -- it does not need to case-split on G or H membership at all.

**However**, the codebase's case analysis is not wrong for the n=0 case (adjacent pairs). For the n=0 case, the easy sub-cases (neg(gamma) already in f(x) or f(y)) work as-is. The hard sub-case (gamma in both, G(gamma) in f(x), H(gamma) in f(y)) is exactly where BurgessR3Maximal is needed.

For non-adjacent pairs (n > 0): the current code handles this at the limit level (`limit_satisfies_c4` finds the right finite stage). Burgess handles it at the finite stage level (Lemma 2.9, case n = m+1). Both approaches are valid.

## 6. The gamma = top Edge Case

### The concern

If gamma = top in the C4 hard case, then:
- neg(untl(top, delta)) = neg(F(delta)) = G(neg(delta)) in f(x)
- delta in f(y)
- Need to find z with neg(top) = top.neg in f(z)
- But top is a theorem, so top in every MCS. Having top.neg in f(z) contradicts f(z) being MCS.

This seems to make the C4 hard case impossible for gamma = top. Let me trace through what happens.

### Analysis

If gamma = top and neg(untl(top, delta)) in f(x) and delta in f(y), then the C4 condition requires z with top.neg in f(z), which is impossible (top is a theorem in every MCS).

But wait: is this actually a counterexample? For it to be a C4 counterexample, we need neg(untl(top, delta)) in f(x) and delta in f(y) and NO z between x and y with top.neg in f(z). Since top.neg can never be in any MCS, the "no witness" condition is trivially true. So this IS a valid counterexample that can never be resolved.

**Does this mean C4 can fail?** No. The point is that **such a counterexample can never arise** if the chronicle is properly constructed. Here is why:

neg(untl(top, delta)) in f(x) means neg(F(delta)) in f(x) means G(neg(delta)) in f(x). If delta in f(y) for some y > x, then neg(delta) not in f(y) (MCS). But G(neg(delta)) in f(x) and x < y should imply neg(delta) in f(y) by forward_G. Contradiction. So f(y) cannot contain delta.

In other words: the premises neg(untl(top, delta)) in f(x) AND delta in f(y) with x < y are **inconsistent** for a properly constructed limit chronicle. C4 holds vacuously because such a counterexample cannot exist.

### But wait -- this uses forward_G at the limit!

Yes, showing that the counterexample premises are inconsistent uses forward_G. But this is NOT circular because:

1. At **finite stages**, the gamma = top case works differently. If gamma = top and we are at a finite stage with BurgessR3Maximal(f(x), g(x,y), f(y)):
   - burgessR3_gamma_not_in_B: top not in g(x,y)
   - But top IS a theorem, so top is in every DCS (by dcs_contains_theorems)
   - Therefore top IS in g(x,y)
   - Contradiction!

This means: **if BurgessR3Maximal(f(x), g(x,y), f(y)) holds, then neg(untl(top, delta)) in f(x) and delta in f(y) is impossible.** The counterexample cannot arise at any finite stage where BurgessR3Maximal holds.

### Proof

Suppose neg(untl(top, delta)) in f(x) and delta in f(y) and BurgessR3Maximal(f(x), g(x,y), f(y)).

By burgessR3_gamma_not_in_B: top not in g(x,y).

But g(x,y) is a DCS (from BurgessR3Maximal). Every DCS contains all theorems (dcs_contains_theorems). top is a theorem. So top in g(x,y). Contradiction.

Therefore, the premises are inconsistent. The C4 hard case for gamma = top **cannot arise** at any finite stage where BurgessR3Maximal holds.

### Conclusion on gamma = top

This is NOT a problem. The gamma = top case is resolved by showing the premises are contradictory. The argument uses `dcs_contains_theorems` (top in every DCS) + `burgessR3_gamma_not_in_B` (top not in g(x,y) from the contradiction). These are both already proved sorry-free in the codebase.

The implementation should add a short-circuit: before entering the hard case, check if gamma is a theorem (or more generally, if gamma is in g(x,y) by DCS membership). If gamma is in g(x,y) AND neg(untl(gamma, delta)) in f(x) AND delta in f(y), then burgessR3 gives untl(gamma, delta) in f(x), contradicting neg(untl(gamma, delta)) in f(x). So the counterexample premises are impossible, and the C4 case is vacuously satisfied.

## 7. Concerning the BurgessR3Maximal g(x,y): Is B an MCS?

### Burgess's observation

In Burgess's paper, R(A, B, C) is defined as B being maximal DCS with r(A, B, C). Burgess notes (after Definition 2.5) that whenever R(A, B, C) holds and delta not in B, there exists beta in B such that r(A, beta and delta, C) does not hold. This means for some gamma in C, untl(beta and delta, gamma) not in A.

This **does not** mean B is an MCS. B is maximal among DCS satisfying burgessR3, but it need not be maximal among all consistent sets. The anti-monotonicity of burgessR3 means adding a formula to B might break burgessR3, so the Lindenbaum extension to MCS is not available.

### Does B need to be an MCS?

For the C4 hard case, we need:
1. gamma not in g(x,y) (by burgessR3_gamma_not_in_B) -- DONE
2. gamma.neg in g(x,y) (by negation completeness) -- REQUIRES g(x,y) to be MCS or at least have negation completeness

**Problem**: If g(x,y) is "merely" a DCS (not MCS), then gamma not in g(x,y) does NOT imply gamma.neg in g(x,y). DCS do not have negation completeness.

### Resolution: The C3 route

The fix is to NOT use gamma.neg in g(x,y) directly. Instead, the C4 hard case constructs a NEW point z with f(z) containing gamma.neg, using Lemma 2.6 (splitting). Lemma 2.6 does not require gamma.neg in g(x,y). It requires:
1. R(f(x), g(x,y), f(y)) -- BurgessR3Maximal for the adjacent pair
2. delta not in g(x,y) -- where delta is the formula to negate

Wait, re-reading Lemma 2.6: "Suppose R(A, B, C) and delta not in B." Then there exist B', D, B'' with neg(delta) in D and R(A, B', D), R(D, B'', C), B = B' intersect D intersect B''.

In the C4 application: we need neg(gamma) in f(z). Burgess's Lemma 2.6 gives us D containing neg(delta) (not neg(gamma)). Let me re-read the C4 elimination proof (Lemma 2.9).

### Re-reading Lemma 2.9 carefully

Lemma 2.9 (Case n = 0): We have R(f(x), g(x,y), f(y)). The counterexample is: neg(untl(gamma, delta)) in f(x), delta in f(y), and no z between x and y with neg(gamma) in f(z).

The claim: we can add z between x and y with neg(gamma) in f(z).

But Burgess applies Lemma 2.6 to delta (the GUARD of the Until formula), not to gamma.

Wait, let me re-read more carefully. Burgess's C4a says: neg(untl(gamma, delta)) in f(x) and **delta** in f(y) implies z with neg(**gamma**) in f(z). So gamma is the guard and delta is the event. The counterexample needs a point where the guard fails (neg(gamma)).

Now, Lemma 2.6 says: given R(A, B, C) and **delta** not in B, there exist B', D, B'' with **neg(delta)** in D. So Lemma 2.6 produces a point with neg(delta) where delta is the formula not in B.

For C4: we need neg(gamma) in the new point. So we need to apply Lemma 2.6 to the formula **gamma** (showing gamma not in g(x,y)), getting neg(gamma) in D = f(z).

We showed gamma not in g(x,y) using burgessR3_gamma_not_in_B. Then Lemma 2.6 with "delta = gamma" gives D containing neg(gamma). This is the z we need.

**So the argument is**:

1. BurgessR3Maximal(f(x), g(x,y), f(y)) -- by c2'
2. neg(untl(gamma, delta)) in f(x) and delta in f(y) -- counterexample
3. gamma not in g(x,y) -- by burgessR3_gamma_not_in_B
4. Apply Lemma 2.6 with "the formula not in B" = gamma: get D with neg(gamma) in D
5. D = f(z) for new point z. neg(gamma) in f(z). Done.

This does NOT require g(x,y) to be MCS. It only requires BurgessR3Maximal and the splitting lemma. The splitting lemma (2.6) works with DCS, not just MCS.

## 8. Summary: Complete Architecture

### Dependency graph (no cycles)

```
burgessR3 infrastructure (sorry-free)
    |
    v
burgessR3Maximal_extension_exists (sorry-free, Zorn)
    |
    v
Lemma 2.6 splitting [NEEDS IMPLEMENTATION for burgessR3]
    |
    v
C4 hard case elimination at finite stages [NEEDS IMPLEMENTATION]
    |
    v
omega chain with C0 + C1 + C2' (BurgessR3Maximal) + C3
    |
    v
limit_satisfies_c4 (already implemented, sorry propagates from C4 hard case)
    |
    v
limit_forward_G (already implemented, depends on limit_satisfies_c4)
    |
    v
C5 forward direction + C3 -> truth lemma
```

### What needs to be built

1. **Lemma 2.6 for burgessR3**: Given BurgessR3Maximal(A, B, C) and delta not in B, produce B', D, B'' with neg(delta) in D and BurgessR3Maximal(A, B', D) and BurgessR3Maximal(D, B'', C) and B = B' intersect D intersect B''.

2. **Seed construction for burgessR3Maximal**: To build the initial g(x,y) when a new point is inserted. For the C4 hard case (Lemma 2.6), the seed comes from the splitting construction itself. For C5 (Lemma 2.4), the seed comes from the endpoint witness.

3. **Populated g-values in the omega chain**: Replace the placeholder `limit_g` with real g-values tracked through the chain.

4. **C4 hard case implementation**: Use burgessR3_gamma_not_in_B + Lemma 2.6 to construct the witness point.

5. **FUC (forward Until coherence)**: Use C5 (witness) + C3 (guard at intermediate points via g(x,y) subset f(z)).

### What is already done (sorry-free)

- burgessR3, burgessRSet, burgessRSetSince definitions
- burgessR3_absorption (Lemma 2.5)
- burgessR3Maximal_extension_exists (Zorn)
- burgessR3_gamma_not_in_B (C4 bridging)
- dcs_neg_insert_consistent (gamma.neg consistent with DCS)
- c3_interval_subset_point (g(x,z) subset f(y))
- limit_forward_G (modulo sorry in C4)
- limit_backward_H (modulo sorry in C4')
- cantor_bfmcs_restricted_buc (modulo sorry in C4)
- All MCS/DCS infrastructure

### Critical path

The shortest path to closing all 4 sorries:

```
1. Implement Lemma 2.6 for burgessR3 (splitting with BurgessR3Maximal)
2. Close C4 hard case (line 332) using burgessR3_gamma_not_in_B + Lemma 2.6
3. Close C4' hard case (line 448) by mirror
4. Close FUC (lines 615, 619) using C5 + C3 with real g-values
```

Steps 1-3 require populated g-values at finite stages. Step 4 additionally requires C3 at the limit.
