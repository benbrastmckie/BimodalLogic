# Teammate A Findings: Burgess Lemma 2.9 Generalization for Non-Adjacent C4

**Focus**: Can generalized C4 (for ALL pairs, not just adjacent) be proved at the limit, and does this resolve forward_G?

---

## 1. Burgess Lemma 2.9 Step-by-Step

Burgess's Lemma 2.9 (literature file lines 216-224) states: given a C4a counterexample (x, y, gamma, delta) for a chronicle (f, g) in F, there exists an extension (f', g') that eliminates it. The proof is by induction on n = number of domain points strictly between x and y.

### Case n = 0 (adjacent)

By C2', R(f(x), g(x,y), f(y)) holds. Apply Lemma 2.6 with delta not in g(x,y) (since delta is checked at f(y) and the counterexample means no z with ~gamma in f(z) exists between x and y). We get B', D, B'' with ~delta in D. Insert z = (x+y)/2, set f'(z) = D, g'(x,z) = B', g'(z,y) = B'', and let C3 determine all other g' values.

**Translation note**: Burgess's C4a says: ~U(gamma, delta) in f(x) and gamma in f(y), produce ~delta in f(z). His U(gamma, delta): gamma = EVENT, delta = GUARD. The codebase's `untl(gamma, delta)`: gamma = GUARD, delta = EVENT. So:

| Burgess | Codebase |
|---------|----------|
| gamma (EVENT in U(gamma,delta)) | delta (EVENT, 2nd arg of untl) |
| delta (GUARD in U(gamma,delta)) | gamma (GUARD, 1st arg of untl) |
| ~delta at f(z) | ~gamma (gamma.neg) at f(z) |
| gamma at f(y) | delta at f(y) |

The codebase C4 definition (ChronicleTypes.lean:306-311) is:
```
~(untl gamma delta) in f(x) AND delta in f(y) => exists z, gamma.neg in f(z)
```
This checks EVENT (delta) at f(y) and negates GUARD (gamma) at f(z). This matches Burgess after the variable swap. **Confirmed correct.**

### Case n = m + 1 (non-adjacent)

Let x' be the immediate successor of x in dom f (the leftmost point between x and y). Two sub-cases:

**Sub-case A**: ~U(gamma, delta) in f(x'). Then (x', y, gamma, delta) is still a C4a counterexample with only m points between x' and y. Apply induction hypothesis.

**Sub-case B**: U(gamma, delta) in f(x'). Burgess observes: "note first that we must have delta in f(x'), else x, y, gamma, delta would not be a counterexample." This needs unpacking.

Why must delta in f(x')? The counterexample says ~U(gamma, delta) in f(x) and gamma in f(y) [Burgess's gamma = EVENT], but no z between x and y has ~delta in f(z). Since x' is between x and y, ~delta is NOT in f(x'). By MCS: delta in f(x').

**Codebase translation**: ~(untl gamma delta) in f(x) and delta in f(y), no z between x,y with gamma.neg in f(z). Since x' is between x and y, gamma.neg is NOT in f(x'). By MCS: gamma in f(x').

Now Burgess defines gamma' = delta AND U(gamma, delta) in f(x'). [Codebase: gamma' = gamma AND untl(gamma, delta) -- wait, need to be careful.]

Actually in Burgess's notation: U(gamma, delta) in f(x') and delta in f(x'). He sets gamma' = delta AND U(gamma, delta) and shows ~U(gamma', delta) in f(x) using A3a. Then (x, x', gamma', delta) is a C4a counterexample with n=0 points between x and x' (since x' immediately succeeds x). Apply the base case.

**Codebase translation of sub-case B**: untl(gamma, delta) in f(x'). We also have gamma in f(x') (as shown above). In the codebase, let gamma' = gamma AND untl(gamma, delta). We need ~untl(gamma', delta) in f(x). Using A5a (Burgess's A5a, which in the codebase is an axiom about Until), from ~untl(gamma, delta) in f(x) we can derive ~untl(gamma', delta) in f(x). Actually, the derivation uses A3a: `p AND U(q, r) => U(q AND S(p, r), r)`. Hmm, this needs more care -- see Section 3 below.

---

## 2. Codebase C4 Elimination: Only n=0

The codebase's `eliminate_C4_counterexample` (CounterexampleElimination.lean:252-313) handles ONLY the n=0 case. It requires `adj : Adjacent chi.dom x y` as a field of `C4Counterexample`. The proof does not use Lemma 2.6 at all for the non-trivial case; instead it does a simple case split on gamma in f(x) vs gamma.neg in f(x), copying endpoint MCS values.

**Critical**: The codebase's C4 elimination does NOT use Lemma 2.6 (which involves the interval function g and R3-maximality). The "easy cases" (gamma.neg in f(x) or gamma.neg in f(y)) work by copying, but the "hard case" (gamma in both f(x) and f(y)) is sorry'd (line 280). This hard case IS the Lemma 2.6 application.

The `PotentialCounterexample` enumeration (lines 536-541) encodes C4 counterexamples with fields x, y, xi (=gamma), eta (=delta), and kind = c4_forward. At line 646-650, the elimination checks:
```
Adjacent chi.dom pc.x pc.y AND
(untl pc.xi pc.eta).neg in f(pc.x) AND
pc.eta in f(pc.y) AND
no witness z
```

**The adjacency requirement is baked into the enumeration and elimination.** Non-adjacent C4 counterexamples are never enumerated, never eliminated.

---

## 3. Does Generalized C4 Follow from Adjacent C4 + Density?

This is the critical question: at the limit, can we prove C4 for ALL pairs (x, y) in limit_dom from:
1. Adjacent C4 at each finite stage (maintained by the omega chain)
2. Density of limit_dom

### The Argument (attempting to follow Burgess's n>0 case at the limit)

Suppose x < y in limit_dom, ~untl(gamma, delta) in limit_f(x), delta in limit_f(y). We want z between x and y with gamma.neg in limit_f(z).

By density, there exists w in limit_dom with x < w < y. Two cases:

**Case A**: ~untl(gamma, delta) in limit_f(w). Then (w, y) is a "smaller" counterexample. Continue inducting.

**Case B**: untl(gamma, delta) in limit_f(w). Since the original counterexample says no z between x and y has gamma.neg in f(z), and w is between x and y, gamma.neg is NOT in limit_f(w), so gamma in limit_f(w). Now...

**THE PROBLEM**: In Burgess's proof, sub-case B constructs gamma' and reduces to n=0 (ADJACENT case) between x and x' (the immediate successor). But at the limit, x has NO immediate successor -- the domain is dense. There is no "n=0 case" to reduce to. We cannot insert a new point (the limit construction is already complete).

This is the fundamental issue: **Burgess's induction on n is for FINITE stages where adjacency is meaningful. At the dense limit, the induction template does not apply.**

### The Well-Founded Induction Alternative

Could we use well-founded induction on the "distance" between x and y (or the structure of intermediate points)?

The issue is that between x and y there are countably infinitely many limit domain points. Any attempt at induction through intermediate points encounters the same problem: each intermediate point w either has ~untl(gamma, delta) (reducing the problem to a sub-interval) or has untl(gamma, delta) (which would allow a reduction if we had adjacency, but we don't).

In sub-case B, the key move is: untl(gamma, delta) in f(w) and gamma in f(w), so gamma AND untl(gamma, delta) in f(w). Call this gamma'. Then ~untl(gamma', delta) in f(x) (provable from ~untl(gamma, delta) in f(x) using axiom A3a or similar). Now (x, w, gamma', delta) is a counterexample with fewer intermediate points.

**But wait**: "fewer intermediate points" does not apply at the limit -- there are infinitely many points between x and any w. This infinite descent does not terminate.

### Why Burgess Doesn't Need This

Burgess's proof works because he applies Lemma 2.9 at FINITE stages. He never needs generalized C4 at the limit. Instead, at Claim 2.11 (the truth lemma), he proves the Until case directly:

> If ~U(beta, gamma) in f(x), then for any y > x with gamma in f(y) [by IH: y in V(gamma)], C4a gives z between x and y with ~beta in f(z), so z not in V(beta). Hence x not in V(U(beta, gamma)).

But **C4a here is the LIMIT C4a, applied to the limit chronicle (f, g) which satisfies C0-C5**. Burgess's construction ensures C4 holds for ALL pairs at the limit, not just adjacent ones. How?

**Answer**: Burgess's construction eliminates C4 counterexamples AT FINITE STAGES for non-adjacent pairs too. Re-read Lemma 2.9 carefully: it applies to any counterexample (x, y, gamma, delta) with n intermediate points. At each finite stage, the domain is finite, so n is always finite. The omega chain processes ALL potential C4 counterexamples (for ALL pairs, not just adjacent ones), and each is eliminated by Lemma 2.9.

**This is exactly what the codebase is missing.** The codebase only enumerates C4 counterexamples for ADJACENT pairs. Burgess enumerates them for ALL pairs.

---

## 4. The Enumeration Must Change

**The current `PotentialCounterexample` enumeration must be modified to cover ALL pairs (x, y) for C4, not just adjacent pairs.**

Specifically, the `C4Counterexample` structure needs to drop the `adj : Adjacent chi.dom x y` field. The elimination function needs to implement the full Lemma 2.9 induction (not just n=0).

### What Changes Are Needed

1. **New `GeneralizedC4Counterexample` structure** (or modify existing): Drop `adj`. Just require x < y, x in dom, y in dom, ~untl(gamma, delta) in f(x), delta in f(y), no z between with gamma.neg in f(z).

2. **New `eliminate_generalized_C4_counterexample`**: Implement Burgess's full Lemma 2.9 by induction on `(chi.dom.filter (fun w => x < w && w < y)).card` (the number of domain points strictly between x and y).

   - **Base case (n=0)**: x and y are adjacent. Use Lemma 2.6 (the existing sorry'd hard case needs to be filled, but the easy cases work).

   - **Inductive case (n=m+1)**: Let x' = leftmost point between x and y (min of the filter set).
     - If ~untl(gamma, delta) in f(x'): recursion on (x', y, gamma, delta) with m intermediate points.
     - If untl(gamma, delta) in f(x'): gamma in f(x') (since no gamma.neg between x and y). Set gamma' = gamma.conj (untl gamma delta). Show ~untl(gamma', delta) in f(x). Recursion on (x, x', gamma', delta) with 0 intermediate points (adjacent).

3. **Modify `PotentialCounterexample` enum**: For c4_forward kind, remove the adjacency check in `eliminate_potential_counterexample`. The (x, y, xi, eta, c4_forward) tuple represents a GENERAL pair, not just adjacent.

4. **Modify `EliminationResult`**: Possibly add a `c4_forward_witness` field analogous to `c5_forward_witness`.

### Proving ~untl(gamma', delta) in f(x)

For sub-case B, we need: from ~untl(gamma, delta) in f(x), derive ~untl(gamma AND untl(gamma, delta), delta) in f(x).

This follows from axiom A6a (Burgess): `U(q AND U(p, q), q) => U(p, q)`. Contrapositively: `~U(p, q) => ~U(q AND U(p, q), q)`.

In the codebase, this is: `untl(guard AND untl(guard, event), guard) => untl(guard, event)`. Wait, need to be very careful with the variable correspondence.

Burgess A6a: `U(q AND U(p,q), q) => U(p,q)` where U(event, guard).

Codebase: `untl(guard, event)` where guard = 1st arg, event = 2nd arg.

Burgess's p = codebase's delta (EVENT), q = codebase's gamma (GUARD).

So A6a becomes: `untl(gamma AND untl(gamma, delta), gamma) => untl(gamma, delta)` -- but wait, that's `U(q AND U(p,q), q)` in Burgess's notation, which unpacks as: event = q AND U(p,q) = gamma AND untl(gamma, delta), guard = q = gamma.

Hmm, actually the subscript issue is getting confused. Let me redo this from scratch.

Burgess U(alpha, beta): alpha = EVENT (witnessed at endpoint), beta = GUARD (holds in between).

Codebase untl(gamma, delta): gamma = GUARD, delta = EVENT.

So Burgess U(alpha, beta) = codebase untl(beta, alpha).

Burgess A6a: `U(q AND U(p,q), q) => U(p,q)`.
Here p and q are Burgess variables, with U(p,q) meaning event=p, guard=q.

In codebase: `untl(q, q AND untl(q, p)) => untl(q, p)`.
Or equivalently: `untl(q, p AND untl(q, p)) => untl(q, p)`.

Wait, U(q AND U(p,q), q) has event = q AND U(p,q), guard = q. In codebase: untl(guard, event) = untl(q, q AND U(p,q)) = untl(q, q AND untl(q, p)).

Hmm, let me check if the codebase has BX6 or A6a.

Actually, the key derivation we need for sub-case B is simpler. Let me re-trace Burgess's argument more carefully.

In Burgess's n>0 case (sub-case B), he has:
- ~U(gamma, delta) in f(x) (Burgess notation)
- U(gamma, delta) in f(x')
- delta in f(x') (because no ~delta between x and y, and x' is between x and y)
- He sets gamma' = delta AND U(gamma, delta)
- He shows ~U(gamma', delta) in f(x) by: "Using A3a we see ~U(gamma', delta) in f(x)"

Burgess A3a: `p AND U(q, r) => U(q AND S(p, r), r)`.

Actually wait, the argument uses: from ~U(gamma, delta) in f(x), we want ~U(gamma', delta) in f(x) where gamma' = delta AND U(gamma, delta).

Since gamma' = delta AND U(gamma, delta), we have U(gamma', delta) => U(gamma, delta) (by A1a: if gamma' => gamma provably, then U(gamma', delta) => U(gamma, delta)). Wait, does gamma' => gamma? gamma' = delta AND U(gamma, delta). This does NOT imply gamma unless there's a special axiom.

Let me re-read more carefully. Burgess says "Let gamma' = delta AND U(gamma, delta) in f(x')." Then: "Using A3a we see ~U(gamma', delta) in f(x), so we can reduce to the case n = 0 by replacing gamma by gamma' and y by x'."

So the argument is: ~U(gamma, delta) in f(x), and from this derive ~U(delta AND U(gamma, delta), delta) in f(x).

Proof: Suppose for contradiction U(delta AND U(gamma, delta), delta) in f(x). By A6a: U(q AND U(p, q), q) => U(p, q). With event=p=gamma, guard=q=delta... hmm, but A6a has event = q AND U(p,q) and guard = q. That doesn't match.

Actually A6a is: `U(q AND U(p, q), q) => U(p, q)`.
Put p = gamma, q = delta: `U(delta AND U(gamma, delta), delta) => U(gamma, delta)`.
Contrapositively: `~U(gamma, delta) => ~U(delta AND U(gamma, delta), delta)`.
Since ~U(gamma, delta) in f(x) (hypothesis), we get ~U(delta AND U(gamma, delta), delta) in f(x).

And delta AND U(gamma, delta) is exactly gamma'. So ~U(gamma', delta) in f(x). This is what Burgess claims.

**Codebase translation**: From ~untl(gamma, delta) in f(x), derive ~untl(delta AND untl(gamma, delta), gamma) in f(x).

Wait, no. Burgess's U(gamma', delta) with gamma' = delta AND U(gamma, delta). In codebase, U(event, guard) = untl(guard, event). So U(gamma', delta) = untl(delta, gamma') = untl(delta, delta AND untl(delta, gamma)).

Hmm, I'm getting confused by the convention swap. Let me be very precise.

Burgess: ~U(gamma, delta) in f(x). Here gamma=EVENT, delta=GUARD.
Codebase: this is ~untl(delta, gamma) in f(x), i.e., (untl delta gamma).neg in f(x).

The codebase's C4 checks (untl xi eta).neg in f(x) and eta in f(y). So xi = delta (Burgess GUARD), eta = gamma (Burgess EVENT).

In Burgess sub-case B, f(x') has U(gamma, delta) = codebase untl(delta, gamma), AND delta = codebase xi. So codebase has: untl(xi, eta) in f(x') and xi in f(x'). Set eta' = xi AND untl(xi, eta) (codebase). Then by A6a: untl(xi, eta' AND untl(xi, eta)) => untl(xi, eta). Wait, this is getting circular.

Let me just state it cleanly in codebase terms:

- xi = GUARD (1st arg), eta = EVENT (2nd arg)
- Hypothesis: (untl xi eta).neg in f(x), eta in f(y)
- x' is leftmost between x and y
- Sub-case B: untl(xi, eta) in f(x')
- Also: xi in f(x') (because xi.neg is not in f(x'), since the counterexample says no z between x,y has xi.neg)

Wait, that's wrong too. The counterexample says: no z between x and y has **xi.neg** (= gamma.neg = negated GUARD) in f(z). So xi.neg is NOT in f(x'). By MCS, xi (GUARD) IS in f(x').

Define eta' = xi AND untl(xi, eta). [This is Burgess's gamma' in the EVENT position.]

We need: (untl xi eta').neg in f(x), i.e., ~untl(xi, xi AND untl(xi, eta)) in f(x).

By A6a (codebase version): untl(xi, xi AND untl(xi, eta)) => untl(xi, eta).
Contrapositively: (untl xi eta).neg => (untl xi (xi.conj (untl xi eta))).neg.
Since (untl xi eta).neg in f(x), we get (untl xi eta').neg in f(x).

Now (x, x', xi, eta') is a C4 counterexample with 0 intermediate points (x' is the immediate successor of x, so they are adjacent). The base case inserts z between x and x' with xi.neg in f(z). But xi.neg in f(z) with x < z < x' < y means z is between x and y with xi.neg in f(z), eliminating the original counterexample.

**This works.** The codebase needs A6a as an axiom (or derived theorem).

---

## 5. Can We Avoid Modifying the Enumeration?

**No.** The argument in Section 3 shows conclusively that at the dense limit, generalized C4 does NOT follow from adjacent C4 + density by a pure limit argument. The infinite descent through intermediate points does not terminate.

Burgess's proof works because C4 counterexamples for ALL pairs are eliminated at FINITE stages, where n is always finite. The limit inherits C4 for all pairs because every potential C4 counterexample (x, y, gamma, delta) is eventually enumerated and eliminated.

The only way to make this work is to enumerate and eliminate generalized (non-adjacent) C4 counterexamples in the omega chain.

---

## 6. The Critical Subtlety: Formula Propagation at Intermediate Points

At step n when we process a C4 counterexample (x, y, gamma, delta), the intermediate points between x and y were inserted at various earlier stages. The formulas in f(w) for these intermediate points are FIXED (f-immutability). The question is whether the inductive case analysis (sub-case A vs B) works correctly with these fixed formula assignments.

**Yes, it does.** The Lemma 2.9 induction only READS f(w) for intermediate points -- it never modifies them. It case-splits on whether ~U(gamma, delta) or U(gamma, delta) is in f(w). Since f(w) is an MCS, one of these must hold. The induction reduces the problem to either:
- A counterexample with fewer intermediate points (sub-case A), or
- An adjacent counterexample with a modified formula gamma' (sub-case B).

In both cases, the elimination inserts ONE new point and extends f and g. The existing f values are untouched.

**The only requirement** is that at the finite stage n, the domain is finite, so n (the number of intermediate points) is finite and the induction is well-founded.

---

## 7. Concrete Lean Proof Sketch

### Modified `C4Counterexample` (drop adjacency)

```lean
structure GeneralizedC4Counterexample (chi : Chronicle) where
  x : Rat
  y : Rat
  x_mem : x in chi.dom
  y_mem : y in chi.dom
  hxy : x < y
  gamma : Formula    -- GUARD (1st arg of untl)
  delta : Formula    -- EVENT (2nd arg of untl)
  neg_until_mem : (Formula.untl gamma delta).neg in chi.f x
  event_mem : delta in chi.f y
  no_witness : neg exists z in chi.dom, x < z AND z < y AND gamma.neg in chi.f z
```

### Generalized Elimination (Lemma 2.9 full)

```lean
noncomputable def eliminate_generalized_C4 {chi : Chronicle}
    (h_inv : ChronicleInvariant chi)
    (ce : GeneralizedC4Counterexample chi) :
    exists chi' : Chronicle,
      chi.dom subseteq chi'.dom AND
      (forall x in chi.dom, chi'.f x = chi.f x) AND
      ChronicleInvariant chi' AND
      (exists z in chi'.dom, ce.x < z AND z < ce.y AND ce.gamma.neg in chi'.f z) AND
      chi.dom subset chi'.dom := by
  -- Induction on n = (chi.dom.filter (fun w => ce.x < w AND w < ce.y)).card
  -- Base case: n = 0 (adjacent) -> Lemma 2.6
  -- Inductive case: find leftmost x', case split on untl membership
  sorry -- to be implemented
```

### Key Axiom Needed

```lean
-- A6a (Burgess): U(q AND U(p,q), q) => U(p,q)
-- Codebase: untl(xi, xi AND untl(xi, eta)) => untl(xi, eta)
-- Contrapositive: ~untl(xi, eta) => ~untl(xi, xi AND untl(xi, eta))
theorem a6a_contrapositive (xi eta : Formula) :
    DerivationTree [] ((Formula.untl xi eta).neg.imp
      (Formula.untl xi (xi.conj (Formula.untl xi eta))).neg)
```

### Modified Omega Chain Enumeration

The `PotentialCounterexample` type already has fields (x, y, xi, eta, kind). For `c4_forward`, the elimination currently checks `Adjacent chi.dom pc.x pc.y`. This check must be REMOVED. Instead, check only:
- `pc.x in chi.dom AND pc.y in chi.dom`
- `pc.x < pc.y`
- `(untl pc.xi pc.eta).neg in chi.f pc.x`
- `pc.eta in chi.f pc.y`
- No witness z between pc.x and pc.y with pc.xi.neg in chi.f z

### Why This Resolves forward_G

Once the omega chain eliminates generalized C4 counterexamples for ALL pairs, the limit chronicle satisfies C4 for ALL pairs (x, y), not just adjacent ones. Then:

G(phi) = ~(untl top (phi.neg)) (where top = bot.imp bot).

Suppose G(phi) in limit_f(x) and x < y. Then (untl top (phi.neg)).neg in limit_f(x). If phi.neg in limit_f(y) (i.e., phi not in limit_f(y)), then (x, y, top, phi.neg) is a C4 counterexample. By limit C4, there exists z between x and y with top.neg = bot in limit_f(z). But limit_c0 says f(z) is an MCS, which cannot contain bot. Contradiction. Therefore phi in limit_f(y).

**This is exactly the C4 + C0 argument**, now valid for ALL pairs because generalized C4 holds at the limit.

---

## 8. Implementation Effort Estimate

1. **A6a axiom or derived theorem** (contrapositive form): 1-2 hours. Need to verify this axiom exists in the codebase's axiom set or derive it from existing axioms.

2. **Generalized C4 elimination** (Lemma 2.9 full): 5-8 hours.
   - The base case (n=0, adjacent) requires Lemma 2.6, which has a sorry at PointInsertion.lean:762. This is the existing `lemma_2_6_full` sorry.
   - The inductive case is mostly formula manipulation + calling the base case.

3. **Modify enumeration and elimination dispatch**: 2-3 hours.
   - Drop adjacency from C4 counterexample check
   - Update `EliminationResult` if needed

4. **Prove limit generalized C4**: 2-3 hours.
   - Same pattern as `limit_satisfies_c5_weak` but for C4

5. **Close forward_G and backward_H**: 1-2 hours.
   - Direct from generalized C4 + C0 as sketched above

**Total: 11-18 hours**, with the critical dependency being `lemma_2_6_full` (the Lemma 2.6 sorry).

---

## 9. Summary of Key Findings

1. **Burgess's Lemma 2.9 handles non-adjacent C4 by induction on n** (intermediate point count). The base case uses Lemma 2.6; the inductive case uses axiom A6a (contrapositive) to reduce to the base case or a smaller instance.

2. **The codebase only implements n=0** (adjacent C4). Non-adjacent C4 counterexamples are never enumerated or eliminated.

3. **Generalized C4 at the dense limit does NOT follow from adjacent C4 + density.** The infinite descent through intermediate points does not terminate at the limit. This is a fundamental impossibility, not a proof technique gap.

4. **The fix is clear**: enumerate C4 counterexamples for ALL pairs (x, y) in the omega chain, and implement the full Lemma 2.9 induction to eliminate them at finite stages where n is always finite.

5. **Once generalized C4 holds at the limit**, forward_G follows immediately from the C4 + C0 argument (G(phi) = ~(top U ~phi), C4 gives bot in some f(z), contradicting C0).

6. **Critical dependency**: `lemma_2_6_full` (PointInsertion.lean:762) must be filled for the n=0 base case of the generalized elimination.

7. **The g_prop_forward/backward and density counterexample kinds become redundant** once generalized C4 is implemented, since forward_G/backward_H follow from C4 + C0 directly. However, density counterexamples may still be useful for making the limit domain dense (needed for the Cantor isomorphism if used).
