# Teammate A Findings: The g_content Chain -- Does C2+C3 Give g_content(f(x)) <= f(y)?

**Task**: 107 -- Burgess chronicle construction for BX representation theorem
**Focus**: Whether C2 and C3 together imply g_content(f(x)) <= f(y) for adjacent domain points
**Date**: 2026-04-24

## Executive Summary

**The chronicle does NOT give g_content(f(x)) <= f(y) for adjacent x < y.** C3 gives g_content(f(x)) <= g(x,y), and C2 gives r(f(x), g(x,y)), but there is NO condition in the chronicle axioms that forces g(x,y) <= f(y). The g function is an interval set (DCS) that describes formulas holding *throughout the open interval (x,y)*, not a stepping-stone from f(x) to f(y). This is a fundamental structural difference from the Int chain.

However, **the chronicle does NOT need g_content(f(x)) <= f(y) to prove forward_G**. The proof follows a different path than the Int chain, and the correct approach has been identified below.

## 1. Exact Definitions of C2 and C3

### C3: g_content propagation to interval

```lean
def Chronicle.c3 (chi : Chronicle) : Prop :=
  forall x y : Rat, Adjacent chi.dom x y -> g_content (chi.f x) <= chi.g x y
```

**Meaning**: For adjacent x < y, every formula phi with G(phi) in f(x) is also in g(x,y). The interval set g(x,y) contains at least the "universally future" content of the left endpoint.

### C2: r-relation between point and interval

```lean
def Chronicle.c2 (chi : Chronicle) : Prop :=
  forall x y : Rat, Adjacent chi.dom x y -> rRelation (chi.f x) (chi.g x y)
```

Where `rRelation A B` means:
```lean
def rRelation (A B : Set Formula) : Prop :=
  forall (gamma delta : Formula),
    Formula.untl gamma delta in A ->
    delta in B or (gamma in B and Formula.untl gamma delta in B)
```

**Meaning**: For adjacent x < y, the interval g(x,y) correctly continues all Until obligations from f(x). Either the eventuality delta is resolved (delta in g(x,y)) or the guard continues (gamma in g(x,y) and the Until persists in g(x,y)).

### C2': R-maximality (strengthened C2)

```lean
def Chronicle.c2' (chi : Chronicle) : Prop :=
  forall x y : Rat, Adjacent chi.dom x y -> rMaximal (chi.f x) (chi.g x y)
```

R-maximality means g(x,y) is a *maximal* DCS satisfying r(f(x), g(x,y)). No proper DCS extension of g(x,y) still satisfies the r-relation with f(x).

## 2. Analysis: Does g_content(f(x)) <= f(y) Follow from C2+C3?

**No.** Here is the chain of what we CAN derive:

- C3 gives: `g_content(f(x)) <= g(x,y)` -- YES
- C2 gives: `rRelation(f(x), g(x,y))` -- about Until propagation, NOT about set inclusion g(x,y) <= f(y)
- C1 gives: `SetDeductivelyClosed(g(x,y))` -- g is a DCS, not an MCS

**Missing link**: There is NO chronicle condition that says `g(x,y) <= f(y)`. The interval function g(x,y) describes the *open interval (x,y)*, not the right endpoint y. The conditions C0-C5 do not include any axiom like "the interval set is included in the right endpoint".

**Why the Int chain is different**: In the Int chain (CanonicalModel.lean), the key property `g_content(chain(t)) <= chain(t+1)` holds **by construction**: chain(t+1) is a Lindenbaum extension of `{psi} union g_content(chain(t))` (or just `g_content(chain(t))` if no F-formula is targeted). This is definitional -- there is no intermediate g function.

## 3. The r-Relation Does NOT Give g(x,y) <= f(y)

The r-relation `rRelation(f(x), g(x,y))` says nothing about f(y). It constrains how Until formulas from f(x) propagate into g(x,y). There is no axiom relating g(x,y) to f(y) at all.

One might hope for a "right endpoint" condition like:
- `g(x,y) <= f(y)` or
- `g_content(g(x,y)) <= f(y)` or
- `rRelation(g(x,y), f(y))`

But none of these appear in the ValidChronicle structure (lines 275-293 of ChronicleTypes.lean).

## 4. How PointInsertion Constructs New Points

Reading PointInsertion.lean:

### lemma_2_4 (Until witness endpoint)
Given MCS A with U(gamma, beta) in A, constructs MCS C with:
- beta in C
- **g_content(A) <= C** (by Lindenbaum extension of {beta} union g_content(A))
- P(U(gamma, beta)) in C

So when a NEW witness point is added, it DOES satisfy `g_content(A) <= C`. But this is `g_content(f(x)) <= f(y_new)` only for the specific pair (x, y_new) where y_new was just inserted as a witness for x.

### lemma_2_6 (Counterexample insertion)
Given MCS A and C with g_content(A) <= C, if delta not in C, constructs MCS D with:
- neg_delta in D
- **g_content(A) <= D**

Again, the new point D satisfies g_content(A) <= D.

### lemma_2_5b (g_content transitivity)
```lean
theorem lemma_2_5b {A D C : Set Formula}
    (h_mcs_A : SetMaximalConsistent A)
    (h_AD : g_content A <= D) (h_DC : g_content D <= C) :
    g_content A <= C
```

This is the crucial composition lemma. If g_content(A) <= D and g_content(D) <= C, then g_content(A) <= C. Uses temp_4 (G -> GG).

## 5. The Omega-Chain Construction

Reading ChronicleConstruction.lean:

The omega-chain at step n+1 takes the previous chronicle and eliminates one counterexample. The `eliminate_potential_counterexample` function returns an `EliminationResult` with:
- `dom_sub`: old domain is subset of new domain
- `c0`: new chronicle satisfies C0 (all points map to MCS)
- `f_agrees`: f values unchanged on old domain points
- `c5_forward_witness`/`c5_backward_witness`: Until/Since witnesses exist

**Key observation**: The omega-chain does NOT track C3 as an invariant. It only maintains C0 (points are MCS). The conditions C1, C2, C2', C3, C4 are NOT part of the `EliminationResult` structure.

The g function is `chi.g` which is unchanged from the previous step (the elimination just copies it). In fact, the singleton chronicle starts with `g := fun _ _ => empty`, and the elimination functions carry `chi.g` forward unchanged.

**This means the g function is essentially undefined/empty throughout the omega-chain construction.** The g function would need to be reconstructed AFTER the omega-chain reaches its limit, or tracked as an invariant during construction.

## 6. Does lemma_2_5b Give Transitivity for Domain Points?

Yes, but only if we can establish the chain: for domain points x0 < x1 < ... < xn:
- g_content(f(x0)) <= f(x1) (if x1 was inserted as witness for x0)
- g_content(f(x1)) <= f(x2) (if x2 was inserted as witness for x1)
- etc.

Then by lemma_2_5b, g_content(f(x0)) <= f(xn).

But this is NOT what happens in the chronicle. Points are inserted one at a time to resolve C5 counterexamples, and a point y inserted for x satisfies g_content(f(x)) <= f(y), but the next insertion z for some other point w may not maintain any relationship between f(y) and f(z).

## 7. The Correct Proof Strategy for forward_G

The forward_G property for the chronicle is:
```
G(phi) in limit_f(t) and t < t' ==> phi in limit_f(t')
```

The proof DOES NOT go through g_content(f(x)) <= f(y) for adjacent points. Instead:

### Strategy A: Direct from limit_f definition

For domain points t and t', where t enters at step n0 and t' enters at step n1:
1. G(phi) in limit_f(t) = f_n0(t)
2. At step max(n0, n1), both t and t' are in the domain
3. f_max(t) = f_n0(t) (by f-agreement) so G(phi) in f_max(t)
4. G(G(phi)) in f_max(t) (by temp_4, since f_max(t) is MCS)
5. Now we need phi in f_max(t'), but this requires knowing the relationship between f_max(t) and f_max(t')

**This is exactly the gap.** Steps 1-4 are straightforward. Step 5 requires some form of g_content propagation between domain points.

### Strategy B: Through the elimination construction

When a point y is inserted as an Until witness for x, we get g_content(f(x)) <= f(y). If t < y < t', and y was inserted for t, then:
- g_content(f(t)) <= f(y)
- If t' was inserted for y: g_content(f(y)) <= f(t')
- By lemma_2_5b: g_content(f(t)) <= f(t')

But this only works if the chain of insertions forms a path from t to t'. In general, points are inserted in arbitrary order based on the counterexample enumeration.

### Strategy C: The non-domain extension (current approach)

The current `extended_limit_f` assigns A (the root MCS) to non-domain points. For domain-to-domain transitions, the sorry in `chronicle_fmcs.forward_G` would need the domain g_content chain. For transitions involving non-domain points (where mcs = A), properties of A would be used.

### Strategy D: Bypass -- Use the Int chain for G/H, Chronicle for Until/Since

The existing Int chain (CanonicalModel.lean) already has a sorry-free proof of forward_G and backward_H. The chronicle's value-add is C5/C5' (Until/Since witnesses).

**Key insight**: Could we build a hybrid FMCS that uses the Int chain's MCS assignments for G/H coherence, but leverages the chronicle's domain points for Until/Since witnesses? This would avoid needing g_content propagation in the chronicle entirely.

However, this would require the Int chain and chronicle to share the same MCS at common points, which is architecturally complex.

### Strategy E: Strengthen the omega-chain invariant

Track g_content(f(x)) <= f(y) as an invariant of the omega-chain construction:
- When inserting a new point y for Until witness of x: g_content(f(x)) <= f(y) holds by construction (lemma_2_4)
- For existing adjacent pairs that become non-adjacent after insertion: the invariant is preserved because f values don't change on old points

**This is the most promising path.** Define: "the omega-chain at step n is g_content-ordered" meaning for all x, y in dom(n) with x < y, g_content(f_n(x)) <= f_n(y). Then:
1. Base case (singleton {0}): vacuously true (no pairs with x < y both in {0}).
2. Inductive step: When inserting y for x:
   - g_content(f(x)) <= f(y) -- by lemma_2_4
   - For old pairs (a, b) with a < b: g_content(f(a)) <= f(b) -- by IH (f unchanged on old points)
   - For new pairs (a, y) with a < y and a != x: need g_content(f(a)) <= f(y). This requires g_content(f(a)) <= f(x) (by IH if a < x) and g_content(f(x)) <= f(y) (by construction), composed via lemma_2_5b.
   - For new pairs (y, b) with y < b: need g_content(f(y)) <= f(b). **This is NOT guaranteed by the construction.** lemma_2_4 gives g_content(f(x)) <= f(y), not g_content(f(y)) <= f(b).

**The gap in Strategy E**: When a new point y is inserted, we know g_content(f(x)) <= f(y), but we do NOT know g_content(f(y)) <= f(b) for domain points b > y. This would require G(phi) in f(y) implies phi in f(b), but f(y) is a Lindenbaum extension of {beta} union g_content(f(x)), and it may contain G-formulas NOT from g_content(f(x)).

Specifically: f(y) is MCS, so it contains formulas like G(psi) for various psi (by negation completeness, either G(psi) or neg G(psi) is in f(y)). Some of these G(psi) may NOT have G(G(psi)) in f(x), so psi may not be in g_content(f(x)), and hence psi may not be in f(b).

**This gap is real and fundamental.** The Lindenbaum extension adds "random" G-formulas that don't propagate forward.

### Strategy F: Redefine limit_f to use the Int chain

Since `int_chain M h_mcs` already satisfies forward_G sorry-free, one could:
1. Use the chronicle for domain structure (which points exist, Until witnesses)
2. Use the Int chain for MCS assignment (what formulas are at each point)

But this requires mapping between Rat domain points and Int chain indices, which is non-trivial.

### Strategy G: The actual Burgess approach

In Burgess 1982, the chronicle conditions C0-C5 are maintained at each step, and the g function is updated alongside f. The key is:

1. Start with singleton chronicle
2. At each step, insert a point AND update g to maintain all conditions
3. The g function tracks what holds "between" points
4. C3 (g_content(f(x)) <= g(x,y)) + some right-endpoint condition gives the chain

**What's missing in the current Lean code**: The omega-chain construction only maintains C0, not the full set of conditions. The g function is never properly constructed. This is the root cause of the forward_G sorry.

## 8. Synthesis: The Critical Gap and Recommended Path

### The Gap
The chronicle construction as currently implemented does not maintain g_content ordering between domain points. The g function is essentially empty/placeholder throughout the omega-chain. Without g_content(f(x)) <= f(y), forward_G cannot be proven for domain-to-domain transitions.

### Why g_content(f(x)) <= f(y) Fails
Even if we try to prove it inductively, newly inserted points f(y) are Lindenbaum extensions that may contain G-formulas not derivable from the parent's g_content. There is no mechanism to prevent "wild" G-formulas in f(y).

### Recommended Approach

**Option 1 (Rebuild g properly)**: Reconstruct the g function in the limit. For each adjacent pair (x,y) in limit_dom, define g(x,y) = deductive closure of g_content(limit_f(x)), then prove r-relation and maximality. This approach requires significant new work but follows Burgess most closely.

**Option 2 (Strengthen insertion)**: When inserting a new point y, construct f(y) not just as a Lindenbaum extension of {beta} union g_content(f(x)), but as one that also satisfies g_content(f(y)) <= f(b) for all existing b > y. This would require building f(y) as an extension of {beta} union g_content(f(x)) union h_content(f(b)), which may not be consistent.

**Option 3 (Use extended_limit_f = A for non-domain, prove for domain points differently)**: The current architecture assigns A to non-domain points. For the forward_G sorry:
- Case t in domain, t' in domain: This is the hard case requiring g_content chain
- Case t in domain, t' not in domain: extended_limit_f(t') = A, and G(phi) in f(t) should give phi in A via... this doesn't obviously hold either.
- Case t not in domain: extended_limit_f(t) = A, so G(phi) in A, and phi in A requires Gp -> p which is the T-axiom (FAILS for strict semantics).

**This reveals a deeper problem**: `extended_limit_f(t) = A` for non-domain t means G(phi) in extended_limit_f(t) = G(phi) in A, but phi in extended_limit_f(t') = phi in A requires the T-axiom. Under strict (irreflexive) semantics, G(phi) does NOT imply phi at the same point.

**Option 4 (Rethink the non-domain extension)**: Instead of assigning A to non-domain points, assign a Lindenbaum extension of g_content(A) to every non-domain rational. Then G(phi) in ext(t) gives G(G(phi)) in A (via BX4-like reasoning? No...). This doesn't obviously help.

**Option 5 (Use the Int chain entirely, transplant Until/Since from chronicle)**: This may be the pragmatic path. The Int chain has sorry-free G/H. The chronicle has sorry-free C5/C5'. Combine them. This requires careful architectural work but avoids the fundamental g_content gap.

## Appendix: Key Observations

1. **g_content(M) = {phi | G(phi) in M}** -- this is a set operation on the MCS, not dependent on the chronicle structure.

2. **temp_4 gives G -> GG**: If G(phi) in M (MCS), then G(G(phi)) in M. This means g_content is "self-reinforcing" within a single MCS: phi in g_content(M) implies G(phi) in g_content(M) (since G(G(phi)) in M).

3. **Lindenbaum extensions are non-constructive**: When we extend {beta} union g_content(A) to an MCS C, C may contain formulas NOT in A or derivable from A. This is why g_content(C) is not controlled.

4. **The Int chain succeeds because it's deterministic**: chain(t+1) = fwd_succ(chain(t), psi), so g_content(chain(t)) <= chain(t+1) is guaranteed by construction. The chronicle's non-deterministic Lindenbaum extensions break this.

5. **The 2 sorry sites in forward_G/backward_H are the hardest remaining obstacles** for the chronicle path. The other sorries (restricted coherence conditions, box stability) depend on these.
