# Teammate B Findings: Lemma 2.6 Full Seed Construction and C4 Hard Cases

## 1. Burgess Lemma 2.6 -- Exact Statement and Proof

### Statement (Burgess 1982, p.162-164)

> **Lemma 2.6.** Suppose we have R(A, B, C) and delta not in B. Then there exist B', D, B'' such that ~delta in D and R(A, B', D), R(D, B'', C) and B = B' inter D inter B''.

### Proof (verbatim summary with notation clarified)

**Prerequisite ("earlier remark", line 142):** When R(A,B,C) holds and delta not in B, there exist beta_0 in B and gamma_0 in C such that ~U(gamma_0, beta_0 AND delta) in A. This follows because if every beta in B had r(A, beta AND delta, C), then B' = deductiveClosure(B union {delta}) would satisfy r(A, B', C), contradicting maximality.

**Seed:** D_0 = {S(alpha, beta) : alpha in A, beta in B} union B union {~delta} union {U(gamma, beta) : gamma in C, beta in B}

**Consistency proof:** It suffices to show every formula of the form

  zeta = S(alpha, beta) AND beta AND ~delta AND U(gamma, beta)

with alpha in A, beta in B, gamma in C is consistent.

By the earlier remark, there exist beta_0 in B, gamma_0 in C with ~U(gamma_0, beta_0 AND delta) in A. WLOG (replacing beta by beta AND beta_0, gamma by gamma AND gamma_0), ~U(gamma, beta AND delta) in A.

But U(gamma, beta) in A by hypothesis r(A,B,C). So U(gamma, beta AND U(gamma, beta)) in A by A5a (self-accumulation). Now A4a applies: U(gamma, beta) AND ~U(gamma, beta AND delta) gives U(beta AND U(gamma, beta) AND ~delta, beta) in A. By A3a: U(beta AND U(gamma,beta) AND ~delta AND S(alpha,beta), beta) in A. Consistency of zeta follows from 2.2.

Then let D be any MCS extending D_0. Let B' be maximal with B subset B' and r(A, B', D), and B'' be maximal with B subset B'' and r(D, B'', C). By Lemma 2.5, B = B' inter D inter B''.

### Key axioms used:
- **A3a**: p AND U(q, r) -> U(q AND S(p, r), r)
- **A4a**: U(p, q) AND ~U(p, r) -> U(q AND ~r, q)
- **A5a**: U(p, q) -> U(p, q AND U(p, q))

## 2. Translation to BX Strict Semantics

**Critical issue:** Burgess uses A3a and A4a which are **NOT VALID** under strict (irreflexive) semantics (as noted in PointInsertion.lean lines 16-22). The codebase documentation states:
- A3a's role is replaced by BX4 (connect_future) + BX5 (self_accum_until)
- A4a's role is replaced by BX5 + BX6 (absorb_until) + BX7 (linear_until)

The Lemma 2.6 proof CRITICALLY depends on A4a. This is the formula:

  A4a: U(p,q) AND ~U(p,r) -> U(q AND ~r, q)

Under strict semantics, this fails. A4a says: if "p until q" holds but "p until r" doesn't, then "q AND ~r until q" holds. Under half-open guard semantics, the guard covers [t,s) but the witness s has only the event, so the conjunctive manipulation at the witness point breaks.

**Implication:** Burgess's Lemma 2.6 proof cannot be directly translated. A new proof strategy using BX5/BX6/BX7 is needed.

## 3. Codebase's `lemma_2_6_full` Signature (PointInsertion.lean:736-762)

```
noncomputable def lemma_2_6_full
    {A C : Set Formula}
    (h_mcs_A : SetMaximalConsistent A)
    (h_mcs_C : SetMaximalConsistent C)
    {B : Set Formula}
    (h_R3 : R3Maximal A B C)
    (delta : Formula)
    (h_delta_not_B : delta not in B) :
    exists (D B' B'' : Set Formula),
      SetMaximalConsistent D AND
      delta.neg in D AND
      B subset D AND
      B subset B' AND
      B subset B'' AND
      R3Maximal A B' D AND
      R3Maximal D B'' C
```

**Inputs:** MCS endpoints A, C; R3Maximal interval set B; formula delta not in B.

**Outputs:** MCS D with ~delta, plus R3Maximal decompositions B' and B'' with B subset each.

**Note:** The output guarantees B subset D (not in Burgess's statement but follows from D_0 containing B). Also uses `R3Maximal` (codebase's r3Relation-based) rather than Burgess's R.

## 4. Analysis of `r3Maximal_neg_of_not_mem` (PointInsertion.lean:676-699)

This theorem is sorry-free and proves:

> R3Maximal(A,B,C) and delta not in B implies delta.neg in B.

The proof works by contrapositive: if delta.neg not in B either, then {delta.neg} union B is consistent (via `dcs_neg_union_consistent`), and deductiveClosure({delta.neg} union B) properly extends B while preserving r3Relation (via `r3Relation_subset` monotonicity), contradicting R3Maximality.

**Relationship to Lemma 2.6:** This gives delta.neg in B (the interval set), NOT in a new MCS D. Lemma 2.6 needs delta.neg in a new *point* MCS D between A and C, which is much stronger.

## 5. The C4 Hard Case Analysis

### What the C4 counterexample says (CounterexampleElimination.lean:254-264):
- neg(untl(gamma, delta)) in f(x) -- the Until is denied at x
- delta in f(y) -- the EVENT occurs at y
- No z between x and y with gamma.neg in f(z) -- no negated GUARD witness
- Need to INSERT z with gamma.neg in f(z)

### The easy cases (sorry-free):
- If gamma.neg in f(x): use D = f(x), done
- If gamma in f(x) but gamma.neg in f(y): use D = f(y), done

### The hard case (sorry at line 319):
- gamma in f(x) AND gamma in f(y)
- Both endpoints contain the GUARD -- we need a DIFFERENT MCS D with gamma.neg

### Critical gap: `eliminate_C4_counterexample` only takes `h_c0` (C0 invariant)

The function signature is:
```
noncomputable def eliminate_C4_counterexample {chi : Chronicle}
    (h_c0 : chi.c0) (ce : C4Counterexample chi) : ...
```

It has **no access to g-values or C2'/C3** invariants. For the hard case, Lemma 2.6 needs:
- R3Maximal(f(x), g(x,y), f(y)) -- requires C2' for adjacent pairs
- gamma not in g(x,y) -- to apply Lemma 2.6 with delta := gamma

**Question: Can we prove gamma not in g(x,y)?**

From `r3Maximal_neg_of_not_mem`: if gamma not in g(x,y), then gamma.neg in g(x,y), and by C3: gamma.neg in f(z) for any intermediate z. But we don't know gamma is not in g(x,y) a priori.

From the C4 counterexample: neg(untl(gamma, delta)) in f(x). This means "not (gamma until delta)" at x. Can we derive gamma not in g(x,y) from this?

By rRelation propagation: for all U(phi,psi) in f(x), either psi in g(x,y) or (phi in g(x,y) and U(phi,psi) in g(x,y)). We have neg(untl(gamma,delta)) in f(x), but rRelation talks about untl formulas IN f(x), not their negations.

**Alternative approach:** From `r3Maximal_neg_of_not_mem`, either gamma in g(x,y) or gamma.neg in g(x,y). If gamma.neg in g(x,y), we're done -- by C3, gamma.neg in any intermediate f(z), and we can just insert z with f(z) = any existing MCS containing the g-value content.

If gamma in g(x,y): Then gamma.neg not in g(x,y). We need Lemma 2.6 with delta := gamma to get D with gamma.neg in D and R3Maximal(f(x), B', D), R3Maximal(D, B'', f(y)).

### Does the hard case actually exist?

Consider: neg(untl(gamma,delta)) in f(x), gamma in f(x), gamma in f(y), gamma in g(x,y).

By the r-relation from f(x): U(gamma,delta) is NOT in f(x) (its negation is). The rRelation says for all U(phi,psi) in f(x), B propagates them. Since U(gamma,delta) is NOT in f(x), the r-relation says nothing about gamma and delta.

So the hard case genuinely requires Lemma 2.6: gamma in g(x,y), and we apply Lemma 2.6 to get D with gamma.neg in D.

## 6. Seed Construction Under Strict Semantics

Since A4a is unavailable, the Burgess seed consistency proof must be restructured. Here is a proposed approach:

### Proposed BX-compatible seed

Following Burgess's structure but using BX axioms:

D_0 = B union {delta.neg} union {S(alpha, beta) : alpha in A, beta in B} union {U(gamma, beta) : gamma in C, beta in B}

The S(...) terms ensure r(A, B', D) for the left decomposition. The U(...) terms ensure r(D, B'', C) for the right decomposition. B subset D_0 ensures B subset D.

### Consistency proof strategy

Must show every finite conjunction from D_0 is consistent. The critical formula is:

  zeta = S(alpha, beta) AND beta AND delta.neg AND U(gamma, beta)

for alpha in A, beta in B, gamma in C.

**Using BX axioms instead of A4a:**

1. From R3Maximal(A,B,C) and delta not in B: by the "earlier remark" (translated to BX), there exist beta_0 in B, gamma_0 in C with ~(beta_0 AND delta) U gamma_0 not in A (in codebase notation: neg(untl(beta_0 AND delta, gamma_0)) in A, since A is MCS).

2. WLOG, beta = beta AND beta_0, gamma = gamma AND gamma_0.

3. From r3Relation(A,B,C) and beta in B, gamma in C: untl(beta, gamma) in A (by burgessR).

Wait -- the codebase uses TWO different r-relations:
- `rRelation` (obligation propagation): for all U(phi,psi) in A, propagation to B
- `burgessR` (content relation): for all gamma in C, (beta U gamma) in A

These are NOT the same. R3Maximal uses `r3Relation` (based on `rRelation`), while Burgess's R uses `burgessR`.

**This is the fundamental gap.** Burgess's proof of Lemma 2.6 uses r(A,B,C) in the sense that for all beta in B, gamma in C, U(gamma, beta) in A (Burgess notation). The codebase's R3Maximal is based on rRelation, which is the obligation-propagation version.

### Are they equivalent?

If B is a DCS with R3Maximal(A,B,C) under the rRelation definition, does burgessRSet(A,B,C) also hold?

Not obviously. rRelation says: for all U(phi,psi) in A, either psi in B or (phi in B and U(phi,psi) in B). This doesn't directly give: for all beta in B, gamma in C, (beta U gamma) in A.

The equivalence might hold under maximality + DCS closure, but it is not proved in the codebase and represents a significant gap.

## 7. BX Axioms Required

For the Lemma 2.6 proof under strict semantics:

| Burgess Axiom | BX Replacement | Status in Codebase |
|---|---|---|
| A3a: p AND U(q,r) -> U(q AND S(p,r), r) | BX4 (connect_future) + BX5 (self_accum) | Available |
| A4a: U(p,q) AND ~U(p,r) -> U(q AND ~r, q) | BX5 + BX6 + BX7 (linear) | Available but proof not written |
| A5a: U(p,q) -> U(p, q AND U(p,q)) | BX5 (self_accum_until) | Available, sorry-free in MCS form |
| A6a: U(q AND U(p,q), q) -> U(p,q) | BX6 (absorb_until) | Available |
| Lemma 2.5 absorption | burgessR3_absorption | Sorry-free |

The A4a replacement is the hardest. BX7 (linear_until) gives:

  U(p,q) AND U(r,s) -> U(p AND r, q AND s) OR U(p AND r, q AND r) OR U(p AND r, p AND s)

This needs to be combined with BX5 and BX6 to recover A4a's power in the specific context of Lemma 2.6.

## 8. Concrete Implementation Plan

### Step 0: Fix the function signature gap

`eliminate_C4_counterexample` needs additional hypotheses:
- The full ChronicleInvariant (or at least C2' + C1 + C3)
- OR: a proof of R3Maximal(f(x), g(x,y), f(y)) for the specific pair

**Recommended:** Add `h_inv : ChronicleInvariant chi` parameter, or at minimum `h_c2' : chi.c2'` and `h_c1 : chi.c1`.

The hard case then:
1. Extracts R3Maximal(f(x), g(x,y), f(y)) from C2' (since in the omega chain, x and y may or may not be adjacent -- but C4 counterexamples enumerate ALL pairs x < y, and for non-adjacent pairs, the R3Maximal might not hold directly from C2')

**PROBLEM:** C2' only gives R3Maximal for *adjacent* pairs. For non-adjacent x < y, the g(x,y) is defined by C3 as intersection, and R3Maximal may not hold.

**Resolution:** At finite stages, the omega chain processes ALL (x,y) pairs with x < y. If x and y are adjacent, C2' gives R3Maximal. If not adjacent, there exists intermediate z, and gamma.neg could potentially be found at f(z). But the C4Counterexample says no such z exists with gamma.neg in f(z). However, the "no_witness" field only checks domain points, not all intermediate points.

Actually, re-reading the C4 condition: it checks neg(untl(gamma,delta)) in f(x) and delta in f(y) with x < y (any pair, not just adjacent). The hard case gamma in f(x) AND gamma in f(y) can occur for non-adjacent pairs too. In that case, there might already be intermediate domain points z between x and y.

For non-adjacent x,y with intermediate z in dom: C3 gives g(x,y) = g(x,z) inter f(z) inter g(z,y). If gamma.neg in g(x,y), then gamma.neg in f(z) by C3, contradicting "no_witness". So gamma in g(x,y) in this case too, and we still need Lemma 2.6.

But for non-adjacent pairs, we don't have R3Maximal from C2'. We'd need to prove R3Maximal from the C3 intersection + C2' for adjacent sub-intervals. This is Lemma 2.5 in reverse -- not trivially available.

### Alternative approach: Only handle adjacent case

The omega chain processes ALL pairs (x,y). For non-adjacent x,y, there exists w between them. If gamma.neg not in f(w) for any intermediate w, the counterexample persists. But the omega chain will eventually process the pair (x,w) and (w,y) too, inserting points. Eventually, it reduces to the adjacent case.

**Wait** -- at any FINITE stage, x and y might be adjacent in the current domain. The C4 counterexample at stage n might have x,y adjacent. At stage n+1, after processing, they get a point between them. At stage n+k, the pair is no longer adjacent.

But the eliminate_C4_counterexample function runs at a single stage. At that stage, if x,y are adjacent, C2' applies. If not, there already IS an intermediate domain point z, and by the "no_witness" condition, gamma.neg not in f(z) for all such z.

**For non-adjacent x,y:** The C4Counterexample has no z in dom with gamma.neg in f(z). But there ARE domain points between x and y. So gamma in f(z) for all intermediate z. The g-values give gamma in g(x,y) = g(x,z) inter f(z) inter g(z,y) (by MCS negation completeness of f(z), gamma in f(z) implies gamma.neg not in f(z), which is compatible but gamma itself is in f(z)). So gamma in g(x,y) doesn't follow from gamma in f(z) alone -- gamma needs to be in g(x,z) and g(z,y) too.

**This analysis is getting complex.** The key insight is:

### Recommended sub-lemmas

1. **`r_relation_equiv_burgessR` (new):** Under R3Maximal, the codebase's r3Relation implies burgessR3 (or prove the specific properties needed for the seed). This bridges the two formulations.

2. **`lemma_2_6_seed_consistent` (new):** The seed D_0 = B union {delta.neg} union {S(alpha,beta) : alpha in A, beta in B} union {U(gamma,beta) : gamma in C, beta in B} is consistent. This is the core of Lemma 2.6. Under strict semantics, this needs a new proof using BX5+BX6+BX7 instead of A4a.

3. **`lemma_2_6_r3maximal_extensions` (likely exists or easy):** Given MCS D with B subset D and r3Relation(A, D, C) (or weaker), construct R3Maximal B', B'' by Zorn's lemma. The `zorn_r3Maximal` infrastructure likely already exists.

4. **`c4_hard_case_adjacent` (new):** For adjacent x,y with gamma in f(x), gamma in f(y), and the C4 counterexample conditions, apply Lemma 2.6 with delta := gamma to get D with gamma.neg in D.

5. **`c4_hard_case_needs_invariant` (signature fix):** The `eliminate_C4_counterexample` function needs the ChronicleInvariant (or at least C2') as input, not just C0. This requires updating the function signature and the `eliminate_potential_counterexample` wrapper.

### Priority ordering

1. First: Determine if the signature change is needed and propagate it through the omega chain
2. Second: Prove the seed consistency under BX axioms (the mathematical core)
3. Third: Wire up the R3Maximal extensions
4. Fourth: Connect to the C4 hard case

## 9. Summary of Blockers

| Blocker | Severity | Description |
|---|---|---|
| A4a unavailable | HIGH | Burgess's Lemma 2.6 seed consistency proof uses A4a which is not sound under strict semantics. Must find BX5+BX6+BX7 replacement. |
| Two r-relation formulations | MEDIUM | Codebase uses `rRelation` (obligation propagation) while Burgess uses `burgessR` (content relation). Need equivalence or adaptation. |
| Missing invariant in C4 | MEDIUM | `eliminate_C4_counterexample` lacks access to g-values and C2'. Function signature must change. |
| Adjacent vs non-adjacent | LOW | For non-adjacent pairs, R3Maximal doesn't follow from C2'. May need separate handling or reduction to adjacent case. |

## 10. The A4a Replacement: Detailed Analysis

A4a: U(p,q) AND ~U(p,r) -> U(q AND ~r, q)

In the Lemma 2.6 proof context, A4a is applied with:
- p = gamma (event formula from C)
- q = beta (guard from B)
- r = beta AND delta

So: U(gamma, beta) AND ~U(gamma, beta AND delta) -> U(beta AND ~(beta AND delta), beta)

Since ~(beta AND delta) is equivalent to (~beta OR ~delta), and beta AND (~beta OR ~delta) is equivalent to beta AND ~delta (since beta AND ~beta is absurd):

U(gamma, beta) AND ~U(gamma, beta AND delta) -> U(beta AND ~delta, beta)

Under BX axioms, we need to derive something equivalent. Using BX7 (linear_until) with:
- U(gamma, beta) and U(gamma, beta AND delta)

BX7 would give a three-way case split. But we have ~U(gamma, beta AND delta), not U(gamma, beta AND delta). So BX7 doesn't directly apply.

**Alternative using BX5 + contrapositive reasoning:**

From U(gamma, beta) in A (MCS):
1. BX5: U(gamma, beta AND U(gamma,beta)) in A
2. We want to derive U(beta AND ~delta AND ..., beta) in A

This seems to require a different proof structure than Burgess's. The key question is whether the seed consistency can be proved by a fundamentally different argument under BX axioms, perhaps working directly with the rRelation formulation rather than Burgess's content-based r-relation.

**Possible shortcut:** If we can prove that R3Maximal under `r3Relation` implies the "earlier remark" reformulated as: there exists beta_0 in B such that NOT(for all U(phi,psi) in A with psi = beta_0 AND delta, the propagation still works), then the seed consistency might follow from the structure of rRelation directly.

This requires further mathematical investigation and is the PRIMARY BLOCKER for closing the Lemma 2.6 sorry.
