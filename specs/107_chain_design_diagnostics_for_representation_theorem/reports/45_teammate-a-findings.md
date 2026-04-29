# Teammate A Findings: Primary Approach Analysis for splitting_seed_consistent

**Task**: 107 - Burgess chronicle construction for BX representation theorem
**Role**: Teammate A (Primary Angle)
**Date**: 2026-04-29

## Key Findings

### 1. Xu Lemma 2.3 REQUIRES left_mono_until_G -- Cannot Work With Existing BX Axioms

The assignment's "Important Observation" suggests Xu 2.3 might work with existing BX axioms because the critical step `alpha AND U(gamma, beta) -> U(gamma, beta AND S(alpha, beta))` is BX13. This is **incorrect** -- while BX13 does appear in the proof, it enriches the EVENT (second argument of U in Burgess convention), not the GUARD (first argument). Xu 2.3 requires GUARD strengthening.

**Detailed trace of Xu 2.3 proof in BX terms**:

Goal: Given BurgessR3Maximal(A, B, C), show P(alpha) in B for all alpha in A.

Suppose P(alpha) not in B for some alpha in A. By R-maximality, there exist beta in B, gamma in C with `neg untl(beta AND P(alpha), gamma) in A`.

But from burgessR3: `untl(beta, gamma) in A` (since beta in B, gamma in C).

The proof needs the derivation:

```
alpha AND untl(beta, gamma) -> untl(beta AND P(alpha), gamma)
```

Step-by-step:
1. From alpha in A, by BX4: G(P(alpha)) in A
2. From G(P(alpha)): derive G(beta -> beta AND P(alpha)) (propositional reasoning under G)
3. Need: G(beta -> beta AND P(alpha)) -> untl(beta, gamma) -> untl(beta AND P(alpha), gamma)

Step 3 is **exactly** left_mono_until_G. It CANNOT be done with BX2 because BX2 requires the POINTWISE condition `(beta -> beta AND P(alpha))` at the current time. Under irreflexive semantics, P(alpha) does NOT hold at the current point (alpha holds at t, but P(alpha) = "alpha at some past time" is not guaranteed at t since t is not in its own past).

**BX13 does not help here**: BX13 gives `alpha AND untl(beta, gamma) -> untl(beta, gamma AND snce(beta, alpha))`, which enriches the EVENT from gamma to `gamma AND snce(beta, alpha)`. We need the GUARD enriched, not the event. No combination of BX13 with other existing axioms moves information from the event into the guard.

### 2. Xu Axiom (1) Decomposition: The Second Conjunct IS left_mono_until_G

Xu's axiom (1): `G(p -> q) -> (U(r, p) -> U(q, r)) AND (U(r, p) -> U(r, q))`

Convention mapping (Xu U(event, guard) = BX untl(guard, event)):

- **First conjunct**: `G(p -> q) -> untl(p, r) -> untl(r, q)` -- guard/event SWAP + right mono. **INVALID under open guard.**
- **Second conjunct**: `G(p -> q) -> untl(p, r) -> untl(q, r)` -- guard strengthening. This IS left_mono_until_G.

Xu's proof of Lemma 2.3 uses only the second conjunct plus BX13. The first conjunct is never needed for the splitting construction. So left_mono_until_G is the precise axiom fragment from Xu (1) that is both needed and sound under open-guard semantics.

### 3. Burgess/Xu Lemma 2.1 (r-relation Equivalence) Works With Existing BX Axioms

Burgess Lemma 2.3 / Xu Lemma 2.1: `r(A, beta, C)` iff `for all alpha in A, snce(beta, alpha) in C`.

**Proof (forward direction)**: Assume r(A, beta, C). Suppose snce(beta, alpha) not in C for some alpha in A, i.e., neg snce(beta, alpha) in C. By r-relation: untl(beta, neg snce(beta, alpha)) in A. By BX13 with p := alpha, phi := beta, psi := neg snce(beta, alpha):
`alpha AND untl(beta, neg snce(beta, alpha)) -> untl(beta, neg snce(beta, alpha) AND snce(beta, alpha))`
The event becomes `neg snce(beta, alpha) AND snce(beta, alpha)` = bot. So untl(beta, bot) in A. By BX10: F(bot) in A. But F(bot) = neg G(top), and G(top) is a theorem, so neg G(top) not in any MCS. Contradiction.

This uses only BX13 + BX10 + propositional reasoning. No left_mono_until_G or A4a needed.

**Codebase impact**: This equivalence is NOT currently formalized in the codebase (no lemma_2_1 or burgessR_iff found). It should be formalized as it bridges between the forward (Until) and backward (Since) formulations of the r-relation.

### 4. The Codebase's Seed Mismatch With Burgess D_0

The codebase's `splitting_seed_consistent` tries to prove consistency of:
```
{beta.neg} UNION g_content(A) UNION h_content(C)
```

Burgess's original D_0 seed is:
```
{snce(beta, alpha) : alpha in A, beta in B} UNION B UNION {neg delta} UNION {untl(beta, gamma) : gamma in C, beta in B}
```

These are fundamentally different:
- Burgess includes ALL of B plus explicit r-relation formulas
- The codebase uses g_content(A) = {phi | G(phi) in A} and h_content(C) = {phi | H(phi) in C}

**g_content(A) is NOT a subset of Burgess's D_0 in general**: g_content(A) contains phi whenever G(phi) in A. Burgess's D_0 contains snce(beta, alpha) for beta in B and alpha in A. These are entirely different formula classes.

This means the A4a-based proof in the codebase CANNOT directly follow Burgess's D_0 argument. It would need a different consistency proof adapted to the g_content/h_content seed. This is the source of the "bidirectional seed consistency gap" identified in the handoff.

### 5. The Xu Path Avoids the Seed Problem Entirely

The Xu Lemma 2.4 approach has a crucial structural advantage: it never constructs a seed from g_content/h_content. Instead:

1. Take the existing B from BurgessR3Maximal(A, B, C)
2. beta not in B (from maximality failure)
3. B UNION {neg beta} is consistent (B is DCS, beta not in B)
4. Extend to MCS D
5. By Xu 2.3 (requires left_mono_until_G): P(alpha) in B for all alpha in A, F(gamma) in B for all gamma in C
6. Since B subset D: P(alpha) in D for all alpha in A
7. By Lemma 2.1 (existing BX axioms): r(A, top, D) and r(D, top, C)
8. Feed into `burgessR3Maximal_exists_from_seed(A, D, top)` and `burgessR3Maximal_exists_from_seed(D, C, top)`

Step 8 works because:
- `burgessR A top D` requires: for all delta in D, untl(top, delta) in A = F(delta) in A. This follows from r(A, top, D) via the equivalence: r(A, top, D) iff for all alpha in A, P(alpha) in D. By 2.1 the Until direction gives: for all delta in D, F(delta) in A.

Wait -- actually the directions need care. Let me re-check.

r(A, top, D) = for all delta in D, untl(top, delta) in A = for all delta in D, F(delta) in A.

The Lemma 2.1 equivalence: r(A, top, D) iff for all alpha in A, snce(top, alpha) in D = P(alpha) in D.

We have P(alpha) in D (from step 6), so by the 2.1 equivalence (backward direction), r(A, top, D) holds. This gives: for all delta in D, F(delta) in A. Good.

Similarly for the Since direction: burgessRSince(D, top, A) = for all alpha in A, snce(top, alpha) in D = P(alpha) in D. This IS what we have from step 6.

And top in A (tautology in MCS). So `burgessR3Maximal_exists_from_seed(A, D, top)` has all prerequisites.

For the D-to-C direction:
- F(gamma) in D for all gamma in C (from step 5, F(gamma) in B subset D)
- r(D, top, C) = for all gamma in C, untl(top, gamma) in D = F(gamma) in D. Check.
- burgessRSince(C, top, D) = for all delta in D, snce(top, delta) in C = P(delta) in C. By 2.1 equivalence from r(D, top, C).

Wait, the 2.1 equivalence gives: r(D, top, C) iff for all delta in D, P(delta) in C. We need the forward direction this time: from r(D, top, C) (which we have), conclude for all delta in D, P(delta) in C.

Hmm actually, the Burgess 2.3 equivalence states: r(A, beta, C) iff for all alpha in A, S(alpha, beta) in C. In our direction: r(D, top, C) iff for all delta in D, snce(top, delta) in C = P(delta) in C. So from r(D, top, C) we get P(delta) in C for all delta in D. And burgessRSince(C, top, D) = for all delta in D, snce(top, delta) in C = P(delta) in C. Same thing. Good.

And top in D (tautology). So `burgessR3Maximal_exists_from_seed(D, C, top)` works.

**Crucially**: The Burgess 2.1/2.3 equivalence (which converts between forward and backward r-relations) requires only BX13, not left_mono_until_G. So the only place left_mono_until_G is needed is in Xu Lemma 2.3 itself.

### 6. A4a Path: Can Burgess's Original D_0 Seed Be Used?

An alternative to the Xu path: abandon the codebase's g_content/h_content seed and use Burgess's original D_0 seed with A4a.

This would require:
1. Formalize D_0 = {snce(beta, alpha) : alpha in A, beta in B} UNION B UNION {neg delta} UNION {untl(beta, gamma) : gamma in C, beta in B}
2. Prove D_0 consistent using Burgess's original A4a argument (already in Axioms.lean)
3. Extend D_0 to MCS D
4. Show r(A, B', D) and r(D, B'', C) from D_0's structure

The advantage: follows Burgess's published proof exactly. No new axiom beyond A4a needed.
The disadvantage: requires significant refactoring since the codebase's `lemma_2_6_splitting` and downstream code expect g_content(A) subset D, not Burgess's r-relation structure. The `burgessR3Maximal_from_g_content_sub` infrastructure would need to be replaced or supplemented.

After Lindenbaum on Burgess's D_0, we get MCS D with B subset D and all the r-relation formulas. From B subset D and r(A, B, C) holding by hypothesis, we get r(A, B, D) (since D extends B while the r-relation is "for all gamma in endpoint, untl(beta, gamma) in A"). But wait -- r(A, B, D) means for all beta in B, for all delta in D, untl(beta, delta) in A. The gamma ranges over D now, not C. So this does NOT follow from r(A, B, C) -- we'd need the Until formulas with new delta in D.

However, Burgess's D_0 contains untl(beta, gamma) for gamma in C, beta in B. From these in D, and from the r(A, B, C) properties, we can build the needed structure. The proof is exactly Burgess's original argument (Lemma 2.6 in the paper), which uses A5a (BX5), A4a (BX14), and A3a (BX13) in sequence. This IS the standard published proof.

The codebase would need a new function that takes Burgess's D_0 and establishes BurgessR3Maximal, bypassing the g_content pathway. This is doable but involves more code changes.

## Recommended Approach

**Add left_mono_until_G and follow the Xu path.** Reasons:

1. **Structural simplicity**: The Xu approach avoids constructing any seed. It extends an existing DCS (B) by a single negated formula. Consistency is trivial.

2. **Direct infrastructure fit**: The existing `burgessR3Maximal_exists_from_seed` handles the Xu approach naturally once Lemma 2.1 (r-relation equivalence) and Lemma 2.3 (P/F in B) are formalized.

3. **Semantic naturalness**: left_mono_until_G captures the exact semantic fact about open-guard intervals -- G-information covers the guard interval because (t,s) subset (t, infinity). This is the foundational principle of open-guard reasoning.

4. **Lower risk**: No open questions. The A4a path has the identified seed mismatch (codebase uses g_content/h_content seed, Burgess uses r-relation D_0 seed) which creates an additional proof burden.

5. **Axiom system improvement**: left_mono_until_G subsumes BX2 (making the pointwise conjunct redundant), which simplifies the axiom system for open-guard semantics.

**Implementation sequence**:
1. Formalize Burgess Lemma 2.1 (r-relation equivalence) -- uses only existing BX axioms
2. Add left_mono_until_G axiom + soundness proof (~30 lines total)
3. Formalize Xu Lemma 2.3 using left_mono_until_G + BX13 (~40-60 lines)
4. Replace `splitting_seed_consistent` with Xu's DCS extension argument (~20-30 lines)
5. A4a can optionally be retained (it is sound) or removed (not needed)

## Evidence/Examples

### Semantic Validity of left_mono_until_G (Open Guard)

Given: `G(phi -> chi)` at t, `untl(phi, psi)` at t.

From untl(phi, psi): exists s > t with psi(s) and phi(u) for all u in (t,s).
From G(phi -> chi): (phi -> chi)(u) for all u > t.
For any u in (t,s): u > t, so (phi -> chi)(u). Combined with phi(u): chi(u).
Therefore chi(u) for all u in (t,s), psi(s). So untl(chi, psi) at t.

### Invalidity of Xu Axiom (1) First Conjunct Under Open Guard

`G(p -> q) -> untl(p, r) -> untl(r, q)` (guard/event swap).

Counterexample: Linear order (0, 1, 2) with p = {0,1}, q = {0,1,2}, r = {2}.
At t=0: G(p -> q) holds (trivially, p -> q at all future points since p implies q).
untl(p, r) at 0: witness 2, event r(2) check, guard p on (0,2) = {1}, p(1) check.
untl(r, q) at 0 would need: witness s with q(s) and r on (0,s). r = {2}, so r on (0,s) requires all points in (0,s) to be in r = {2}. For s=1: r on (0,1) = empty, ok. But q(1) = true. So untl(r,q) at 0 with witness 1: r on (0,1) = empty (vacuously true), q(1) = true. Actually this holds...

Let me find a proper counterexample. Take (0, 1, 2, 3) with p = {1}, q = {1,2,3}, r = {3}.
At 0: G(p->q) holds since p subset q. untl(p, r) at 0: witness 3 with r(3), guard p on (0,3) = {1,2}. p(1) = true, p(2) = false. Fails. So untl(p,r) at 0 is false.

Hmm, the counterexample needs more care. The key issue is: the first conjunct swaps which argument is the event and which is the guard. In many concrete cases on finite orders it might still hold. The invalidity is structural -- knowing r at the endpoint s does not give r throughout an interval (t,s'). But finding a clean finite counterexample requires the right setup.

The critical point is: the first conjunct is NOT needed for the Xu 2.3 proof. Only the second conjunct (left_mono_until_G) is used.

## Confidence Level

**HIGH**

The analysis is based on:
- Line-by-line tracing of Xu 2.3 proof against BX axioms
- Verification that BX13 enriches events not guards
- Verification that Burgess 2.1 equivalence works with existing axioms
- Identification of the precise gap (left_mono_until_G) and its semantic validity
- Confirmation that the codebase infrastructure (`burgessR3Maximal_exists_from_seed`) supports the Xu approach
- Cross-validation against the handoff document's findings (confirming the BX2 pointwise gap)

The one area of moderate confidence is whether `burgessR3Maximal_exists_from_seed` can be called with both endpoints (A and D, D and C) using seed top. The prerequisites (burgessR, burgessRSince, seed in first MCS) all check out via the Lemma 2.1 equivalence, but the formalization details may require adapting the existing proof slightly (e.g., the seed_in_A condition: top in A is trivial, but top in D also needs to be verified -- it is, since D is an MCS and top is a theorem).
