# Teammate D Findings: Burgess 1982 End-to-End Construction Trace

## Executive Summary

The codebase's C4 definition restricts to **adjacent pairs only** (line 307 of ChronicleTypes.lean: `Adjacent chi.dom x y`). Burgess's C4a applies to **ALL pairs** (`x, y in dom f and x < y`). This is the root cause of the forward_G blocker. Burgess's omega chain enumerates C4 counterexamples for ALL pairs, so the limit satisfies generalized C4 directly. The codebase's adjacent-only C4 is vacuously true at the dense limit and provides no information.

---

## 1. The Omega Chain Construction (Section 2.7-2.8)

### Conditions C0-C5

Burgess defines the class F (script-F) as the set of all pairs (f, g) satisfying (lines 194-206 of literature file):

- **(C0)**: f maps a finite subset of Q to MCSs (line 197)
- **(C0')**: dom f is finite (line 199)
- **(C1)**: g maps ordered pairs from dom f to DCSs (line 200)
- **(C2)**: r(f(x), g(x,y), f(y)) holds for x < y (line 202)
- **(C2')**: R(f(x), g(x,y), f(y)) (maximality) for ADJACENT x, y (line 204)
- **(C3)**: g(x,z) = g(x,y) intersection f(y) intersection g(y,z) for x < y < z (line 206)

Then the "total chronicle" conditions (lines 208-212):

- **(C4a)**: "Whenever x, y in dom f and **x < y** and ~U(gamma, delta) in f(x) and gamma in f(y), there is some z in dom f with x < z < y and ~delta in f(z)."  [Line 210]
- **(C5a)**: "Whenever x in dom f and U(xi, eta) in f(x), there is some y in dom f with x < y and xi in f(y) and eta in g(x,y)." [Line 212]

**CRITICAL OBSERVATION**: C4a says "x, y in dom f and x < y" -- there is NO adjacency requirement. C4a applies to ALL ordered pairs in the domain.

### How the omega chain is built

From lines 238-248 of the literature file:

> "We wish to form a sequence (f_n, g_n) of elements of F, each extending the one before, in such a way that whenever we have a counterexample to C4a or b, or C5a or b for a given (f_m, g_m), there will eventually be an (f_n, g_n) with n > m for which it is no longer a counterexample."

**Burgess enumerates counterexamples to C4a/b and C5a/b.** Since each counterexample is a tuple of rationals and formulas, and both Q and the set of formulas are countable, the set of potential counterexamples is countable and can be enumerated.

The enumeration covers ALL potential C4 counterexamples -- not just adjacent ones. A C4 counterexample is a tuple (x, y, gamma, delta) where x < y (no adjacency requirement).

### The limit

> "We now let X be the union of the sets dom f_n, and f and g the unions of the f_n and g_n respectively. Then (f, g) satisfies C0-C5."

The limit satisfies C4 for ALL pairs because every potential C4 counterexample was eventually enumerated and eliminated.

---

## 2. Lemma 2.9 (Counterexample Lemma for C4)

### Exact Statement (lines 217-218)

> "Let (f, g) in F and suppose x, y, gamma, delta constitute a counterexample to C4a for (f, g). Then there exists an extension (f', g') in F of (f, g) for which x, y, gamma, delta do not constitute a counterexample to C4a."

### The induction on n (lines 220-224)

> "What we claim is that it is possible to add a single point z lying between x and y to dom f, and extend f and g to functions f' and g' on this enlarged domain, in such a way that ~delta in f'(z), and all the conditions for membership in F are satisfied by (f', g'). We prove this by induction on the number n of elements of dom f lying between x and y."

**Key point**: n is the number of intermediate domain points between x and y. When n = 0, x and y are adjacent and the base case applies directly (Lemma 2.6). When n > 0, the lemma REDUCES to a smaller problem.

### Case n = 0 (adjacent, line 222)

> "By C2' we have R(f(x), g(x,y), f(y)) and so we can apply 2.6 to A = f(x), B = g(x,y), C = f(y) to obtain B', D, B''. Let z = (x+y)/2. Set f'(z) = D. Set g'(x,z) = B', g'(z,y) = B'', and let C3 determine the other values of g'(w,z) and g'(z,w)."

### Case n = m+1 (non-adjacent, lines 223-224)

> "Let x' immediately succeed x in dom f. If ~U(gamma, delta) in f(x'), we can reduce to the case n = m by replacing x by x'. If U(gamma, delta) in f(x'), note first that we must have delta in f(x'), else x, y, gamma, delta would not be a counterexample. Let gamma' = delta and U(gamma, delta) in f(x'). Using A3a we see ~U(gamma', delta) in f(x), so we can reduce to the case n = 0 by replacing gamma by gamma' and y by x'."

**The lemma does NOT insert a point for n > 0**. It REDUCES the problem:
- If ~U(gamma, delta) is already in f(x'), shift x rightward (n decreases by 1)
- If U(gamma, delta) in f(x'), then delta must be in f(x') (otherwise there's already a witness), and the problem reduces to n = 0 with a modified formula between x and the immediate successor x'

**This is crucial**: Lemma 2.9 handles non-adjacent C4 counterexamples by reducing to the adjacent case via formula manipulation. The codebase only implements the n=0 case.

---

## 3. The Limit Construction (Section 2.8)

### How Burgess defines the limit (lines 238-248)

> "We now let X be the union of the sets dom f_n, and f and g the unions of the f_n and g_n respectively."

The limit f is defined pointwise: for x in X, f(x) = f_n(x) for the first n where x in dom f_n. Similarly for g.

### Does the limit satisfy C4 for ALL pairs?

**Yes.** The argument is:

1. Every potential C4 counterexample (x, y, gamma, delta) with x < y (not necessarily adjacent) is enumerated
2. Lemma 2.9 eliminates it (possibly by reducing to the adjacent case internally)
3. Once eliminated at stage n, it remains eliminated at all later stages (extensions only add points and preserve f-values)
4. Therefore at the limit, no C4 counterexample exists for ANY pair

**Burgess does NOT restrict C4 to adjacent pairs in the limit.** The statement of C4a (line 210) says "x, y in dom f and x < y" with no adjacency condition.

### Does Burgess mention forward_G or g_content?

**No.** Burgess never uses the terms "forward_G" or "g_content". The G operator is handled entirely through the truth lemma (Claim 2.11) via the definition G(alpha) = ~U(~alpha, T) and the Until case of the truth lemma.

---

## 4. The Truth Lemma (Claim 2.11)

### Exact proof for the Until case (lines 244-248)

**Forward direction** (U(beta, gamma) in f(x) implies x in V(U(beta, gamma))):

> "If alpha in f(x), then by C5a there is a y in X with x < y and gamma in f(y) and beta in g(x, y). If z in X and x < z < y, then by C3 we have g(x, y) subset f(z), whence beta in f(z). By induction hypothesis y in V(gamma) and z in V(beta) for any z with x < z < y, whence x in V(alpha)."

**Backward direction** (~U(beta, gamma) in f(x) implies x not in V(U(beta, gamma))):

> "If instead ~alpha in f(x), then for any y in X with x < y and y in V(gamma), we have by induction hypothesis gamma in f(y), and hence by C4a there must be a z in X with x < z < y and ~beta in f(z), whence by induction hypothesis z not in V(beta). It follows that x not in V(alpha) as required."

### How is G handled?

Burgess does NOT give a separate case for G in the truth lemma. G(alpha) = ~F(~alpha) = ~U(~alpha, T). The truth lemma handles G through:
1. The negation case: G(alpha) in f(x) iff ~U(~alpha, T) not in f(x) ... wait, that's wrong. Let me re-read.

Actually, G(alpha) = ~F(~alpha) = ~U(T, ~alpha). Wait -- from line 22: F(alpha) = U(alpha, T), so G(alpha) = ~F(~alpha) = ~U(~alpha, T).

Hmm, but Burgess's truth lemma only handles the Until case. The G case follows because:
- G(alpha) in f(x) iff ~U(~alpha, T) in f(x) (by MCS properties and the definition)
- Wait, actually G = ~F~ and F = U(-, T), so G(alpha) = ~U(~alpha, T)

The truth lemma proves V(U(beta, gamma)) = {x : U(beta, gamma) in f(x)} for all beta, gamma. Then V(G(alpha)) = V(~U(~alpha, T)) and by the negation case of the induction, this equals {x : ~U(~alpha, T) in f(x)} = {x : G(alpha) in f(x)}.

**The truth lemma does NOT assume forward_G. It PROVES the equivalent via C4a applied to ALL pairs.**

---

## 5. THE KEY QUESTION: All Pairs vs Adjacent Only

### Burgess's C4a (line 210 of literature file)

> **(C4a)** Whenever x, y in dom f and **x < y** and ~U(gamma, delta) in f(x) and gamma in f(y), there is some z in dom f with x < z < y and ~delta in f(z).

**ALL pairs.** No adjacency restriction.

### Codebase's C4 (ChronicleTypes.lean line 306-311)

```lean
def Chronicle.c4 (chi : Chronicle) : Prop :=
  forall x y : Rat, Adjacent chi.dom x y ->
    forall (gamma delta : Formula),
      (Formula.untl gamma delta).neg in chi.f x ->
      delta in chi.f y ->
      exists z in chi.dom, x < z and z < y and gamma.neg in chi.f z
```

**Adjacent pairs only.** This is the fundamental divergence.

### Why this matters at the limit

At the limit, the domain X is dense in Q (every pair of points has a point between them). Therefore:
- **There are NO adjacent pairs** in the limit domain
- The codebase's adjacent-only C4 is **vacuously true** at the limit
- Vacuously true C4 tells us **nothing** about what happens between non-adjacent pairs

Burgess's C4 for ALL pairs is substantive at the limit. When ~U(beta, gamma) in f(x) and gamma in f(y) with x < y, there EXISTS z between x and y with ~beta in f(z). This is what makes the backward direction of the truth lemma work.

---

## 6. The Guard Convention in the Truth Lemma

In the backward direction of Claim 2.11 (line 246):

> "If instead ~alpha in f(x), then for any y in X with x < y and y in V(gamma), we have by induction hypothesis **gamma in f(y)**, and hence by C4a there must be a z in X with x < z < y and **~beta in f(z)**."

Here alpha = U(beta, gamma). So:
- ~U(beta, gamma) in f(x) -- this is the C4a premise "~U(gamma, delta) in f(x)" with Burgess's gamma = beta and Burgess's delta = gamma (confusing naming)

Wait. Let me align carefully. Burgess's C4a uses (gamma, delta) in ~U(gamma, delta). The truth lemma uses alpha = U(beta, gamma). So:
- Burgess C4a: ~U(gamma_B, delta_B) in f(x), delta_B in f(y) => ~gamma_B in f(z)
- Truth lemma: ~U(beta, gamma) in f(x), gamma in f(y) => ~beta in f(z)

Mapping: gamma_B = beta (first arg of U), delta_B = gamma (second arg of U).

**In the truth lemma's local naming**: beta = GUARD (first arg), gamma = EVENT (second arg). C4a checks EVENT (gamma) at f(y) and produces ~GUARD (~beta) at f(z).

The handoff's question about which is guard vs event: In the truth lemma context, **gamma (second arg of U) is the EVENT checked at f(y)**, and **beta (first arg of U) is the GUARD whose negation appears at f(z)**.

This matches the codebase's corrected C4 definition where delta (EVENT, second arg of untl) is checked at f(y) and gamma (GUARD, first arg of untl) is negated at f(z).

---

## 7. Does Burgess Use C4 for ALL Pairs in the Truth Lemma?

**Yes, necessarily.** From line 246:

> "for any y in X with x < y and y in V(gamma)"

The y here is ANY point in X with x < y -- not just an adjacent successor. C4a is then invoked for the pair (x, y), which may be arbitrarily far apart in the dense domain X. Since X is dense, there are no adjacent pairs at all, so adjacent-only C4 would be useless here.

---

## 8. How Does Burgess Ensure C4 for ALL Pairs at the Limit?

**Answer: (a) Burgess enumerates ALL pairs.**

The omega chain construction (line 238) says:

> "whenever we have a counterexample to C4a or b, or C5a or b for a given (f_m, g_m), there will eventually be an (f_n, g_n) with n > m for which it is no longer a counterexample"

A "counterexample to C4a" is any tuple (x, y, gamma, delta) with x, y in dom, x < y, satisfying the C4a premises but lacking a witness z. There is NO restriction to adjacent pairs in this enumeration.

Lemma 2.9 handles the elimination: given a C4 counterexample for any pair (x, y) with n intermediate points, it reduces (by induction on n) to the adjacent case and inserts a witness. The key insight is that Lemma 2.9's induction on n is INTERNAL to the elimination -- the omega chain just needs to enumerate the counterexample; the lemma handles the reduction automatically.

**There is no separate mathematical argument needed.** The limit satisfies C4 for all pairs simply because every potential counterexample was enumerated and eliminated.

### Why the codebase's approach fails

The codebase restricts C4Counterexample to adjacent pairs (line 213: `adj : Adjacent chi.dom x y`) and C4 itself to adjacent pairs (line 307). This means:

1. The omega chain only enumerates adjacent C4 counterexamples
2. At each finite stage, adjacent C4 counterexamples are eliminated (good)
3. But at the limit, the domain is dense, so there are NO adjacent pairs
4. The limit's C4 (adjacent-only) is vacuously true
5. The truth lemma needs C4 for ALL pairs, which is NOT guaranteed

### The fix

**Redefine C4 to apply to ALL pairs (remove the Adjacent restriction):**

```lean
def Chronicle.c4 (chi : Chronicle) : Prop :=
  forall x y : Rat, x in chi.dom -> y in chi.dom -> x < y ->
    forall (gamma delta : Formula),
      (Formula.untl gamma delta).neg in chi.f x ->
      delta in chi.f y ->
      exists z in chi.dom, x < z and z < y and gamma.neg in chi.f z
```

Then implement the full Lemma 2.9 with induction on intermediate points (not just the n=0 case). The C4Counterexample structure should drop the `adj` field and replace it with simple `x_lt_y : x < y`.

---

## 9. Additional Observation: C2' vs C2

Note that Burgess's C2' (R-maximality) is restricted to ADJACENT pairs (line 204), while C2 (r-relation) applies to all pairs (line 202). This is intentional: maximality is only needed for the base case of Lemma 2.9 (n=0), where adjacency gives C2' which gives the R-maximality needed for Lemma 2.6.

For n > 0 in Lemma 2.9, C2' is not used directly -- the reduction to smaller n handles non-adjacent cases by finding intermediate points where the formula situation changes.

---

## 10. Notation Alignment Summary

| Burgess C4a | Codebase C4 | Truth Lemma |
|-------------|-------------|-------------|
| U(gamma, delta) | untl(gamma, delta) | U(beta, gamma) |
| gamma = 1st arg | gamma = 1st arg = GUARD | beta = 1st arg = GUARD |
| delta = 2nd arg | delta = 2nd arg = EVENT | gamma = 2nd arg = EVENT |
| Check delta at f(y) | Check delta at f(y) | Check gamma at f(y) |
| Produce ~gamma at f(z) | Produce gamma.neg at f(z) | Produce ~beta at f(z) |

The codebase's corrected C4 definition (after the swap in handoff 25) is now **correct in its formula roles** but **wrong in its domain restriction** (adjacent only vs all pairs).

---

## 11. Concrete Resolution Path

1. **Change C4/C4' definitions** in ChronicleTypes.lean to use `x < y` instead of `Adjacent chi.dom x y`
2. **Generalize C4Counterexample** to drop the `adj` field, use `x_lt_y : x < y`
3. **Implement full Lemma 2.9** with induction on the number of intermediate points:
   - n=0 (adjacent): existing code works (Lemma 2.6 application)
   - n>0: case analysis on ~U(gamma, delta) vs U(gamma, delta) at the immediate successor x', then recursive reduction
4. **Enumerate ALL-pairs C4 counterexamples** in the omega chain (the PotentialCounterexample structure already has x,y fields -- just remove the adjacency check in the c4_forward branch)
5. **forward_G becomes provable** because at the limit, G(phi) = ~U(T, ~phi) in f(x) and ~phi in f(y) would give ~T = bot in f(z) by C4, contradicting C0. So forward_G follows from generalized C4 + C0.
6. **The truth lemma works** because C4 for all pairs gives the backward direction of the Until case directly.

**Estimated effort**: The main new work is implementing Lemma 2.9's n>0 case (formula manipulation using A3a/A5a axioms) and changing the C4 definition. The omega chain enumeration change is mechanical. Total: approximately 10-15 hours.
