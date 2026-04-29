# Teammate B Findings: Alternative Approaches Bypassing g_content

**Task**: 107 - Burgess chronicle construction g_content ordering blocker
**Date**: 2026-04-28
**Focus**: Alternative approaches that BYPASS g_content entirely

## Key Findings

### 1. Burgess's Lemma 2.4 Constructs R(A,B,C) Directly -- No g_content Needed

Burgess's Lemma 2.4 (paper lines 148-152) does NOT use g_content at all. The construction is:

1. **Seed**: Given U(gamma, beta) in MCS A, form C_0 = {gamma} union {S(alpha, beta) : alpha in A}.
2. **Consistency proof**: Uses A3a to show gamma wedge S(alpha, beta) is consistent (from U(gamma wedge S(alpha, beta), beta) in A via A3a applied to U(gamma, beta) in A and alpha in A, then 2.2 gives consistency).
3. **Lindenbaum**: Extend C_0 to MCS C. Then r(A, beta, C) holds by criterion 2.3b.
4. **Zorn**: Take B maximal with beta in B and r(A, B, C). This gives R(A, B, C).

The existing formalization's `lemma_2_4` (PointInsertion.lean:150-168) takes a shortcut: it uses `{beta} union g_content(A)` as the seed instead of Burgess's `{gamma} union {S(alpha, beta) : alpha in A}`. This shortcut is what creates the dependency on g_content. But the shortcut is NOT necessary -- Burgess's original seed works differently and produces both B and C.

**However**, the formalization cannot directly replicate Burgess's A3a-based seed because A3a is invalid under strict (irreflexive/open guard) semantics (see PointInsertion.lean docstring lines 17-18). The formalization replaces A3a with BX4 (connect_future). The current seed `{beta} union g_content(A)` works precisely because BX4 gives `phi in A => G(P(phi)) in A`, so `P(phi) in g_content(A)`, which plays the role of S(alpha, beta) in Burgess's seed.

**Verdict**: Burgess's exact construction cannot be replicated under strict semantics (A3a fails). The g_content-based seed IS the correct adaptation. The problem is not in the seed -- it is in what the function returns (discards B).

### 2. The Existing lemma_2_4 DOES Internally Construct B -- But Only Implicitly

Reading PointInsertion.lean:150-168 carefully:

```lean
noncomputable def lemma_2_4 ... :
    exists C : Set Formula, SetMaximalConsistent C /\
      beta in C /\ g_content A <= C /\
      Formula.some_past (Formula.untl gamma beta) in C := by
  ...
  obtain <C, h_sup, h_C_mcs> := set_lindenbaum _ h_seed_cons
  ...
  exact <C, h_C_mcs, h_beta_C, h_g_sub, h_P_until_C>
```

The function returns C (the MCS endpoint) and the evidence that `g_content(A) <= C`. It does NOT return B (the maximal DCS interval set). But crucially, once we have C with `g_content(A) <= C`, we can construct B via `burgessR3Maximal_from_g_content_sub` (RRelation.lean:1472-1499), which takes `g_content(A) <= C` and produces `BurgessR3Maximal(A, B, C)` using top as seed.

**Key insight**: `burgessR3Maximal_from_g_content_sub` is ALREADY PROVEN and sorry-free. It does not need modification. It takes:
- `h_mcs_A : SetMaximalConsistent A`
- `h_mcs_C : SetMaximalConsistent C`
- `h_gc : g_content A <= C`

And produces: `exists B, BurgessR3Maximal A B C`.

So the C5 elimination CAN construct B by calling `burgessR3Maximal_from_g_content_sub` with the C produced by `lemma_2_4`. No modification to `lemma_2_4` itself is needed -- just use its output `h_g_sub : g_content A <= C` as input to `burgessR3Maximal_from_g_content_sub`.

### 3. C5 Seed Analysis: What Serves as Seed for Each Case

For `burgessR3Maximal_exists_from_seed`, we need eta satisfying:
- `burgessR(A, eta, C)`: for all gamma in C, U(eta, gamma) in A
- `burgessRSince(C, eta, A)`: for all alpha in A, S(eta, alpha) in C
- `eta in A`

For the C5 case with `U(xi, beta) in f(x)`:
- `lemma_2_4` produces C with `g_content(f(x)) <= C`
- `burgessR3Maximal_from_g_content_sub` uses `top` (= bot -> bot) as seed
- `burgessR(A, top, C)` holds because: for gamma in C, need U(top, gamma) in A, which is F(gamma) in A (by BX12: F_until_equiv), which holds because G(neg gamma) not in A (else neg gamma in g_content(A) <= C, contradicting gamma in C and C being MCS)
- `burgessRSince(C, top, A)` holds because: for alpha in A, need S(top, alpha) in C, which is P(alpha) in C (by BX12': P_since_equiv), which holds because BX4 gives G(P(alpha)) in A, so P(alpha) in g_content(A) <= C
- `top in A` holds trivially (theorem in MCS)

This is exactly the proof in `burgessR3Maximal_from_g_content_sub`. **The seed top works for C5 without any new infrastructure.**

### 4. Density Self-Pair: BurgessR3Maximal(f(x), B, f(x)) IS Possible Under Irreflexive Semantics

The density case needs `BurgessR3Maximal(f(x), B, f(x))` where both endpoints are the SAME MCS. Let me analyze what `burgessR3(f(x), B, f(x))` requires:

- **burgessRSet(f(x), B, f(x))**: for all beta in B, for all gamma in f(x), U(beta, gamma) in f(x)
- **burgessRSetSince(f(x), B, f(x))**: for all beta in B, for all alpha in f(x), S(beta, alpha) in f(x)

For the seed approach with eta = top:
- Need: for all gamma in f(x), U(top, gamma) in f(x), i.e., F(gamma) in f(x)
- This requires: for all gamma in f(x), F(gamma) in f(x)
- This is equivalent to: g_content(f(x)) <= f(x)

**Does g_content(f(x)) <= f(x) hold for an arbitrary MCS?** This means: if G(phi) in f(x), then phi in f(x). This is exactly the T-axiom (reflexivity): G(phi) -> phi. Under irreflexive semantics, the T-axiom is INVALID.

**So g_content(f(x)) <= f(x) does NOT hold in general.** The `burgessR3Maximal_from_g_content_sub` approach fails for the density self-pair case.

**However**, the question is whether `burgessR3(f(x), B, f(x))` is possible for SOME B (not necessarily via the top seed). For any beta in B: we need U(beta, gamma) in f(x) for all gamma in f(x), and S(beta, alpha) in f(x) for all alpha in f(x). The second condition says: for all alpha in f(x), S(beta, alpha) in f(x). Since f(x) is an MCS, this means: the Since formula must be consistent with everything in f(x).

Actually, `B = {top}` (deductive closure) might work trivially if U(top, gamma) in f(x) for all gamma in f(x). But U(top, gamma) = F(gamma) in f(x) requires F(gamma) for ALL gamma in f(x), including gamma = G(neg p) for some p. Then F(G(neg p)) needs to be in f(x), which is not guaranteed.

**The density self-pair is mathematically problematic under irreflexive semantics.** The fundamental issue: Burgess never duplicates f-values. In his construction, the density counterexample between x and y has f(x) different from f(y), so R(f(x), g(x,y), f(y)) with f(x) != f(y). The self-pair f(z) = f(x) is an artifact of the formalization's density elimination strategy (line 1046: `if q = z then chi.f pc.x else chi.f q`).

### 5. The Density Elimination Does NOT Need c2' for Self-Pairs

Reading the density elimination (lines 1033-1196) carefully:

The density elimination inserts z = (x+y)/2 between adjacent x and y, with `f'(z) = f(x)` and `g'(x,z) = g'(z,y) = chi.g(x,y)` (the old g-value reused). The sorry at line 1130 is:

```
-- This is the self-pair case. We have burgessR3(chi.f pc.x, chi.g pc.x pc.y, chi.f pc.y)
-- from h_c2'. But we need it with chi.f pc.x on the right instead of chi.f pc.y.
-- This does NOT follow in general. Use sorry for now.
sorry
```

The issue: we need `DCS(g(x,y)) AND burgessR3(f(x), g(x,y), f(x))` (self-pair with g reused), but we only have `burgessR3(f(x), g(x,y), f(y))`.

**Alternative approach**: Do NOT reuse the old g for both new pairs. Instead:

- For `g'(x, z)`: Use `burgessR3Maximal_from_g_content_sub` with A = f(x), C = f(z) = f(x). But this fails as shown above (needs T-axiom).
- For `g'(z, y)`: Use old g(x,y), which works since f(z) = f(x) and we have burgessR3(f(x), g(x,y), f(y)).

So the (x,z) pair is the problem. The (z,y) pair works fine by reusing old g.

**Better alternative**: Construct an INTERMEDIATE MCS D (not equal to f(x)) for the midpoint z, rather than copying f(x). If we can find D with g_content(f(x)) <= D AND g_content(D) <= f(y) (i.e., f(x) <= D <= f(y) in the g_content ordering), then:
- `g'(x,z)` comes from `burgessR3Maximal_from_g_content_sub(f(x), D)` -- works because g_content(f(x)) <= D
- `g'(z,y)` comes from `burgessR3Maximal_from_g_content_sub(D, f(y))` -- works because g_content(D) <= f(y)

Such a D exists: take `D_0 = g_content(f(x)) union g_content_inverse(f(y))` (combining forward and backward requirements), extend to MCS. The g_content ordering is transitive (lemma_2_5b), so any MCS between f(x) and f(y) works.

In fact, it is even simpler: since we have `g_content(f(x)) <= f(y)` from the existing c2' (this follows from BurgessR3Maximal(f(x), g(x,y), f(y))), we can use `burgessR3Maximal_from_g_content_sub` with A = f(x), C = f(y) to get ANOTHER B' for the new (x,z) pair. The key realization: g-value construction for (x,z) uses the SAME endpoints f(x) and f(y) -- wait, no, (x,z) has endpoints f(x) and f(z) = f(x).

**The real fix for density**: Do not set f(z) = f(x). Instead, use `lemma_2_4` or a similar construction to produce a DISTINCT MCS for z. Specifically:
- We have BurgessR3Maximal(f(x), g(x,y), f(y)). By burgessR3, g(x,y) <= f(x) intersect f(y) (in some sense). We just need ANY MCS D between f(x) and f(y) in the g_content ordering.
- Use the seed `g_content(f(x)) union h_content(f(y))` (combining forward propagation from f(x) with backward propagation from f(y)), extend to MCS D. Then g_content(f(x)) <= D and h_content(f(y)) <= D. From h_content(f(y)) <= D, we may derive g_content(D) <= f(y) -- but this is NOT automatic. The h_content and g_content orderings go in opposite directions.

Actually, let me reconsider the simplest possible approach.

### 6. Simplest Fix for Density: Don't Need an Intermediate MCS at All

The density case just needs to break adjacency. At the limit, the domain becomes dense and c2' is vacuously true (no adjacent pairs). So we need c2' to hold at each FINITE step, but for density, we're just inserting a point to break adjacency.

**Key question**: Does the density elimination ACTUALLY need c2' at the inserted point?

Looking at the code: the `EliminationResult` structure (line 773) requires `c2' : val.c2'` -- i.e., c2' must hold for ALL adjacent pairs in the new chronicle, including the two new adjacent pairs (x,z) and (z,y) created by the insertion.

But wait: the C4 and C5 elimination functions ALSO produce new adjacent pairs, and THEY also have sorry for c2'. So the density case is not special -- ALL elimination functions have the same sorry pattern for c2' on new adjacent pairs.

The plan v26 (report 42) correctly identifies that the fix is to construct g-values for ALL new adjacent pairs in ALL elimination functions. The density case is just one of them.

For density specifically, the plan says (line 68): "Density: g'(x,z) via Lemma 2.4 on f(x),f(x) -- Self-pair". But this is wrong because Lemma 2.4 requires U(gamma, beta) in A, which is about a SPECIFIC until formula, not about self-pairs.

**The correct approach for density**: Don't use f(z) = f(x). Instead, produce f(z) as a fresh MCS with proper g_content relationships. Specifically:

The seed for f(z) should be `g_content(f(x)) union h_content(f(y))`. This gives:
- g_content(f(x)) <= f(z): enables g'(x,z) via `burgessR3Maximal_from_g_content_sub`
- h_content(f(y)) <= f(z): enables g'(z,y) via the mirror `burgessR3Maximal_from_h_content_sub` (Since direction)

**Consistency of the seed**: Need to show `g_content(f(x)) union h_content(f(y))` is consistent. Since we have `BurgessR3Maximal(f(x), g(x,y), f(y))`, we know `g(x,y) <= f(x) intersect f(y)` (from the DCS inclusion). Elements of g_content(f(x)) are phi with G(phi) in f(x); these are in g(x,y) by... hmm, not necessarily.

Actually, this seed consistency is not trivial. Let me think about what we actually have.

From `BurgessR3Maximal(f(x), g(x,y), f(y))`:
- `burgessRSet(f(x), g(x,y), f(y))`: for beta in g(x,y), for gamma in f(y), U(beta, gamma) in f(x)
- `burgessRSetSince(f(y), g(x,y), f(x))`: for beta in g(x,y), for alpha in f(x), S(beta, alpha) in f(y)

This tells us about g(x,y), but NOT directly about g_content(f(x)) or h_content(f(y)).

**However**, we have `burgessR3Maximal_from_g_content_sub` which only needs `g_content(A) <= C`. Do we know `g_content(f(x)) <= f(y)` from BurgessR3Maximal(f(x), g(x,y), f(y))?

No! g_content(f(x)) = {phi : G(phi) in f(x)}. This is NOT contained in g(x,y) in general. And it is NOT contained in f(y) in general either. BurgessR3Maximal tells us about formulas INSIDE g(x,y), not about g_content.

But the chronicle invariant includes C2 at the limit (all pairs, not just adjacent), which uses g_content ordering. At finite stages, we only have C2' (adjacent). The g_content ordering between f(x) and f(y) when x < y with intermediate points is derived from C3 + C2' at the limit.

**Bottom line for density**: The self-pair problem is genuine and cannot be solved by `burgessR3Maximal_from_g_content_sub`. A different approach is needed.

### 7. The Correct Density Fix: Don't Require c2' for Density-Inserted Points

Since density points exist ONLY to break adjacency (ensuring the limit domain is dense), and at the limit c2' is vacuously true, the density elimination should NOT be required to satisfy c2' for the new pairs.

**Proposed approach**: Change the `EliminationResult` structure to NOT require c2' for density-type eliminations. Instead, have a weaker invariant: c2' holds for all adjacent pairs EXCEPT those involving the density-inserted point. Then require that subsequent C4/C5 eliminations on those pairs (which will eventually happen as the omega chain processes all counterexamples) will insert proper g-values.

Alternatively: maintain the g-value as chi.g(x,y) for the (z,y) pair only, mark the (x,z) pair as pending. Since (x,z) is a self-pair (f(x), f(x)), it will need a C5 or C4 counterexample to trigger proper g-construction.

But this is a significant redesign of the invariant. The simpler fix:

### 8. Actually Simplest Fix: Reuse Old g for Both Pairs (z,y) Only; Leave (x,z) with c0 Only

The density elimination at line 1130 has sorry for `burgessR3(f(x), g(x,y), f(x))`. The (z,y) pair works (line 1098-1103) because burgessR3(f(x), g(x,y), f(y)) holds directly.

For the (x,z) pair: we need BurgessR3Maximal(f(x), g'(x,z), f(z)) where f(z) = f(x). This is BurgessR3Maximal(f(x), g'(x,z), f(x)).

One option: set g'(x,z) = f(x) itself (the MCS). Then burgessRSet(f(x), f(x), f(x)): for beta in f(x), for gamma in f(x), U(beta, gamma) in f(x). This requires U(beta, gamma) in f(x) for ALL beta, gamma in f(x), which is certainly false in general.

Another option: find the largest subset of g(x,y) that satisfies burgessR3(f(x), -, f(x)). Since burgessR3 is anti-monotone in B, the empty DCS trivially satisfies burgessR3 (vacuously). But the empty set is not a DCS (DCS requires consistency, and the empty set might be okay... actually the empty set of formulas IS consistent since no finite subset derives bot). So BurgessR3Maximal(f(x), B, f(x)) with B = maximal DCS for (f(x), -, f(x)) exists by Zorn via `burgessR3Maximal_extension_exists`. The question is just: what seed?

**The empty DCS seed works**! The deductive closure of the empty set is the set of theorems, which is a DCS. And burgessR3(f(x), theorems, f(x)):
- burgessRSet: for beta in theorems, for gamma in f(x), need U(beta, gamma) in f(x). Since beta is a theorem, G(beta) is a theorem (by TG), so G(beta) in f(x) (theorem in MCS). Now need: from G(beta) in f(x) and gamma in f(x), derive U(beta, gamma) in f(x).
  - G(beta) -> beta (T-axiom, INVALID under irreflexive semantics). So we can't even get beta in f(x).
  - Actually, U(beta, gamma) requires a FUTURE witness. From G(beta) alone, without seriality or the T-axiom bridge, we can't derive U(beta, gamma).

Hmm. What about the empty set as seed (not the theorems)? Empty DCS has no elements, so burgessR3 holds vacuously: burgessRSet(f(x), empty, f(x)) requires for all beta in empty, ..., which is vacuously true. So:

- `burgessR3Maximal_extension_exists` with S = empty DCS gives BurgessR3Maximal(f(x), B, f(x)) for some B.

Wait, is the empty set a DCS? A DCS requires consistency (no finite subset derives bot) AND closure under derivation. The empty set: no finite subset derives bot (trivially, since no finite subset exists... actually the empty list [] derives tautologies, so tautologies should be in the DCS). Hmm, the empty set is NOT closed under derivation because [] derives top but top is not in the empty set.

The deductive closure of the empty set = set of all theorems. This IS a DCS. And for burgessR3(f(x), theorems, f(x)):
- Need U(beta, gamma) in f(x) for all theorems beta and all gamma in f(x)
- This requires F(gamma) in f(x) (since for theorem beta, U(beta, gamma) is equivalent to F(gamma) by A2a + beta being a theorem)

Wait: if beta is a theorem then G(beta) is a theorem, so `G(beta -> gamma)` is equivalent to `G(gamma)` modulo beta being a theorem... Actually A2a says G(p -> q) -> (U(r,p) -> U(r,q)). From beta being a theorem: G(beta) is a theorem... but that doesn't directly give U(beta, gamma).

Actually, `U(beta, gamma)` with beta a theorem: by BX3 (untl_left_mono): if beta' -> beta is a theorem and U(beta', gamma) in A, then U(beta, gamma) in A. So we need U(beta', gamma) in A for SOME beta' with beta' -> beta a theorem. With beta' = top: U(top, gamma) = F(gamma). So U(beta, gamma) in f(x) follows from F(gamma) in f(x) and beta being a theorem (via BX3 monotonicity).

So burgessRSet(f(x), theorems, f(x)) holds iff F(gamma) in f(x) for all gamma in f(x). This is NOT true in general.

**Conclusion: The density self-pair case is genuinely hard.** The set of theorems is too large; we need a smaller seed. But we need SOME DCS, and any non-vacuous DCS will impose conditions.

## Recommended Approach

**For C5 elimination (Priority 1)**: The existing infrastructure suffices. After `lemma_2_4` produces C with `g_content(f(x_max)) <= C`, call `burgessR3Maximal_from_g_content_sub(f(x_max), C)` to get B. Set `g'(x_max, y) = B`. This produces `BurgessR3Maximal(f(x_max), B, C)` with no new lemmas needed. The for the (z, y) pair where z is between x_max and y, the (x_max, z) pair gets B, and (z, y) needs further analysis depending on what other points are between.

**For C4 elimination (Priority 2)**: Use Lemma 2.6 splitting. The existing c2' at the adjacent pair gives BurgessR3Maximal(f(w), g(w, w_next), f(w_next)). The C4 elimination finds D with gamma.neg in D via the existing DCS bridging. Then:
- g'(w, z) from burgessR3Maximal_from_g_content_sub or via a splitting lemma
- g'(z, w_next) similarly

**For density (Priority 3)**: This is the hardest case. Three options in decreasing preference:

1. **Defer density c2' to subsequent eliminations**: Change `EliminationResult` so density cases provide c0 and domain extension but NOT c2' for the new self-pairs. Subsequent C4/C5 eliminations on the self-pair will provide proper g-values. This requires restructuring the invariant.

2. **Construct a fresh MCS for density midpoints**: Instead of f(z) = f(x), construct f(z) as an MCS extending g_content(f(x)). This is consistent (g_content of an MCS is consistent). Then g_content(f(x)) <= f(z), enabling `burgessR3Maximal_from_g_content_sub`. But we also need g_content(f(z)) <= f(y) or similar for the (z,y) pair, which is not automatic.

3. **Accept the sorry and document it as a known open problem**: If the density self-pair is provably impossible under irreflexive semantics, this is a genuine mathematical obstacle. But this seems unlikely given that Burgess's construction works for all linear orders.

## Evidence/Examples

- `burgessR3Maximal_from_g_content_sub` at RRelation.lean:1472-1499 is sorry-free and works for C5
- `lemma_2_4` at PointInsertion.lean:150-168 returns `g_content(A) <= C`, which is exactly what `burgessR3Maximal_from_g_content_sub` needs
- The density sorry at CounterexampleElimination.lean:1130 is a genuine self-pair problem where A = C
- Burgess never creates self-pairs (his construction always has f(x) != f(y) for x != y)

## Confidence Level

- **C5 g-value construction via existing infrastructure**: HIGH (95%). The `burgessR3Maximal_from_g_content_sub` theorem is already proven and provides exactly what's needed.
- **C4 g-value construction**: MEDIUM-HIGH (75%). Needs Lemma 2.6 splitting, which is new code but follows Burgess's pattern closely.
- **Density self-pair resolution**: LOW (30%). The mathematical structure under irreflexive semantics genuinely blocks the naive approach. The invariant may need restructuring to avoid requiring c2' for density-inserted self-pairs.
