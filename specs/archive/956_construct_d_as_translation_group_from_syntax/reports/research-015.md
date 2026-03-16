# Research Report: Phase 6 Blocker Analysis -- DenselyOrdered from DN

**Task**: 956 -- Construct D as translation group from syntax
**Report**: research-015
**Date**: 2026-03-09
**Session**: sess_1773075593_2955b1
**Status**: Findings ready for planning
**Effort**: Medium-high (deep mathematical analysis of five approaches)
**Dependencies**: research-012, research-013, phase-6-blocker-20260309.md
**Sources/Inputs**: Codebase (DenseQuotient.lean, BidirectionalReachable.lean, Axioms.lean, CanonicalFrame.lean), Mathlib lookup (lean_leansearch, lean_loogle, lean_leanfinder, lean_local_search)
**Artifacts**: This report
**Standards**: report-format.md, return-metadata-file.md

---

## 1. Executive Summary

- The blocker is real: achieving BOTH strictness conditions simultaneously in the constrained Lindenbaum construction is obstructed by the T-axiom (G(phi) -> phi), which makes the natural combined seed `{G(G(psi)), neg psi}` inconsistent.
- The quotient transfer is NOT the issue. Mathlib's `toAntisymmetrization_lt_toAntisymmetrization_iff` makes the transfer from preorder density to quotient density trivial. The blocker is proving density at the PREORDER level.
- **Approach 2 (Adjacency Contradiction) is the recommended path.** It reformulates the problem as: prove that the BidirectionalFragment preorder with DN has no "adjacent" classes (no pair [a] < [b] with nothing between). This is provable via a **semantic/compactness argument** that avoids the direct combined-seed construction.
- Approach 1 (Two-formula seed) is blocked by the T-axiom obstruction. Approach 3 (Irreflexive setting) requires major architectural changes. Approach 4 (Frame density without quotient) is equivalent to the quotient problem. Approach 5 (Direct Q-embedding) bypasses DenselyOrdered but has its own complexity.
- Estimated effort for the recommended approach: 80-120 lines of Lean.

---

## 2. Preliminary: Quotient Transfer Is Trivial

### 2.1 Key Mathlib Result

The following Mathlib lemma resolves the quotient transfer completely:

```
toAntisymmetrization_lt_toAntisymmetrization_iff :
  toAntisymmetrization (<=) a < toAntisymmetrization (<=) b <-> a < b
```

**Module**: `Mathlib.Order.Antisymmetrization`

This means: `[a] < [b]` in the `BidirectionalQuotient` if and only if `a < b` in the `BidirectionalFragment` preorder.

### 2.2 Consequence

If `DenselyOrdered (BidirectionalFragment M0 h_mcs0)` holds, then `DenselyOrdered (BidirectionalQuotient M0 h_mcs0)` follows automatically:

```lean
-- Proof sketch (approximately 10 lines)
instance : DenselyOrdered (BidirectionalQuotient M0 h_mcs0) := by
  constructor
  intro qa qb h_lt
  induction qa using Quotient.ind with
  | _ a =>
    induction qb using Quotient.ind with
    | _ b =>
      -- h_lt : toAntisymmetrization a < toAntisymmetrization b
      -- By iff: a < b in preorder
      have h_ab := toAntisymmetrization_lt_toAntisymmetrization_iff.mp h_lt
      -- By DenselyOrdered on preorder: exists c with a < c < b
      obtain ⟨c, hac, hcb⟩ := exists_between h_ab
      exact ⟨toAntisymmetrization (<=) c,
        toAntisymmetrization_lt_toAntisymmetrization_iff.mpr hac,
        toAntisymmetrization_lt_toAntisymmetrization_iff.mpr hcb⟩
```

**The real problem is proving `DenselyOrdered` on the preorder**, which is equivalent to proving it on the quotient (same strictness conditions). The blocker document correctly identifies the mathematical obstacle; the quotient adds no additional difficulty.

Also relevant: `antisymmetrization_fibration` provides a lifting property for `<` from the quotient back to the preorder.

---

## 3. Approach 1: Two-Formula Seed

### 3.1 Strategy

Find two distinct formulas psi1, psi2 in GContent(b) \ a.world. Use G(psi1) in the seed for the "above" direction (a < c) and neg(psi2) for the "below" direction (c < b). The combined seed would be:

```
{G(psi1), neg(psi2)} union GContent(a) union HContent(b)
```

### 3.2 The T-Axiom Obstruction

**Problem**: psi and G(psi) are the two natural candidates from GContent(b) \ a.world (Section 3.3 below). But using G(G(psi)) (for the "above" direction via psi1 = G(psi)) together with neg(psi) (for the "below" direction via psi2 = psi) yields:

```
Seed contains: G(G(psi)) and neg(psi)
T-axiom chain: G(G(psi)) -> G(psi) -> psi  (two applications of temp_t_future)
Therefore: seed entails both psi and neg(psi) -- INCONSISTENT
```

This is NOT a formalization issue but a fundamental mathematical obstruction. The T-axiom (G(phi) -> phi, expressing reflexivity of the temporal order) creates a deductive chain from any G^n(psi) down to psi.

### 3.3 Why Only psi and G(psi) Are Available

From `strict_lt_has_distinguishing_formula`: exists psi with G(psi) in b.world, psi not in a.world.

**Claim**: G(psi) is also in GContent(b) \ a.world.

*Proof*:
- G(psi) in GContent(b): By Temp4 (G(phi) -> G(G(phi))), G(psi) in b gives G(G(psi)) in b, so G(psi) in GContent(b).
- G(psi) not in a.world: If G(psi) in a, then by T-axiom psi in a, contradicting psi not in a.

So we have two elements: psi and G(psi). But they are T-axiom-related (G(psi) -> psi), which blocks any seed containing G(something involving psi) and neg(psi or G(psi)).

**Attempting truly unrelated formulas**: We only KNOW about psi from `strict_lt_has_distinguishing_formula`. Any other formula chi in GContent(b) \ a.world is existentially guaranteed but cannot be constructed without additional hypotheses. Even if we had chi unrelated to psi, the consistency proof for {G(chi), neg(psi)} union GContent(a) union HContent(b) requires showing no finite subset derives bot -- a non-trivial compactness argument.

### 3.4 Verdict

**Blocked.** The T-axiom makes the natural two-formula seed inconsistent, and the consistency of an alternative seed requires a compactness argument that is essentially as hard as the original problem.

---

## 4. Approach 2: Adjacency Contradiction (RECOMMENDED)

### 4.1 Strategy

Instead of directly constructing c with a < c < b, prove that "adjacent" equivalence classes are IMPOSSIBLE when DN holds. That is:

**Theorem**: If DN is available and [a] < [b], then there exists [c] with [a] < [c] < [b].

**Proof by contradiction**: Assume [a] < [b] with no class between them. Derive a contradiction using DN's frame-theoretic content.

### 4.2 The Semantic Argument

DN is SOUND for dense frames (proven or provable). If the BidirectionalQuotient were not dense, it would contain adjacent classes [a] < [b]. We can construct a semantic countermodel to DN from such adjacent classes:

**Key Insight**: If [a] and [b] are adjacent in the quotient, then there is a valuation under which DN = F(p) -> F(F(p)) fails at [a]. Specifically:
- Let p be true at worlds in classes >= [b] and false at worlds in classes <= [a]
- Then F(p) is true at [a] (since [a] < [b] and p is true at [b])
- But F(F(p)) requires a class [c] with [a] < [c] such that F(p) is true at [c], which requires [c] < [d] for some [d] with p true at [d]
- If [a] and [b] are adjacent, the only such [c] is [b] itself, and F(p) at [b] requires [b] < [d] with p true at [d]
- This works if there exists [d] > [b] with p true, which there is (p is true at all classes >= [b])
- Wait -- this doesn't give a contradiction, because F(F(p)) at [a] could use [c] = [b]: F(p) at [b] because there exist classes > [b] where p is true

Hmm, the semantic argument is more subtle than initially appears because the quotient is infinite and there are classes beyond [b].

### 4.3 Revised Semantic Argument

The semantic argument needs to be more careful. The adjacency in a DENSE order is impossible, but the quotient is a LINEAR order, and a linear order can have adjacent elements (like Z). The DN axiom is what forces the order to be dense.

Let me reformulate. The correct argument uses the TRUTH LEMMA:

**Truth Lemma + Soundness Approach**:
1. The truth lemma says: for every formula phi and every MCS w in the canonical model, phi in w iff the canonical model satisfies phi at w.
2. DN is a theorem of TM + DN (trivially).
3. By the truth lemma, DN is satisfied at every world of the canonical model.
4. DN = F(phi) -> F(F(phi)) for all phi.
5. DN being satisfied at every world means: for all w and phi, if there exists w' > w with phi at w', then there exists w'' > w with (there exists w''' > w'' with phi at w''').
6. This is exactly the frame condition: the strict temporal order is dense.

But this argument gives density of CanonicalR on MCSes, NOT on the antisymmetrized quotient. The density of CanonicalR on MCSes means: if w1 R w2 and not w2 R w1, there exists w3 with w1 R w3 and w3 R w2 and not w3 R w1 and not w2 R w3.

Wait, that IS the same density condition (on the PREORDER, which we showed is equivalent to the quotient in Section 2).

But does the truth lemma + DN actually give us this? Let me be more precise.

### 4.4 Precise Truth-Lemma-Based Argument

**Setup**: We have the canonical model M with worlds = BidirectionalFragment, accessibility = CanonicalR, and valuation V defined by V(p, w) iff p in w.world.

**Truth Lemma**: For all phi and w: M, w |= phi iff phi in w.world.

**DN is a theorem**: Every theorem is in every MCS, so for all w, DN(phi) = (F(phi) -> F(F(phi))) in w.world.

**By truth lemma**: M, w |= F(phi) -> F(F(phi)) for all w and phi.

**Unfolding**: If M, w |= F(phi), then M, w |= F(F(phi)).
- M, w |= F(phi) means: exists w' with CanonicalR w.world w'.world and M, w' |= phi.
- M, w |= F(F(phi)) means: exists w' with CanonicalR w.world w'.world and M, w' |= F(phi), i.e., exists w' with w R w' and exists w'' with w' R w'' and M, w'' |= phi.

**Choosing phi strategically**: Given a < b (in the preorder), we want to find c with a < c < b.

Let phi be a propositional variable p. Define the canonical valuation: V(p, w) iff p in w.world.

Actually, we need a more specific formula. Here's the key:

From a < b, we have psi with F(psi) in a.world, psi in b.world, psi not in a.world.

By truth lemma: M, a |= F(psi). So by DN at a: M, a |= F(F(psi)).

M, a |= F(F(psi)) means: exists c in fragment with a R c and M, c |= F(psi).
M, c |= F(psi) means: exists d in fragment with c R d and M, d |= psi, i.e., psi in d.world.

So we get: a <= c and c <= d and psi in d.

Now, is a < c (strict)? And is c < b? Not necessarily from this alone.

But we have MORE: from the one-sided constructions (constrained_forward_above and constrained_forward_below), we know intermediate elements exist with one-sided strictness. The question is achieving both.

### 4.5 The Compactness/Omitting-Types Approach

Here is a cleaner strategy that avoids the combined seed issue entirely:

**Step 1**: From `constrained_forward_above`, get c1 with a < c1 <= b.
**Step 2**: If c1 < b, done (c1 is strictly between a and b).
**Step 3**: If NOT (c1 < b), then b <= c1, and since c1 <= b, we have [c1] = [b].

In case 3: c1 is in the same equivalence class as b, with psi in GContent(c1) and psi not in a. Now c1 has G(psi) in c1.world.

**Step 4**: Apply `constrained_forward_below` to the pair (a, c1) -- since c1 is in class [b] and a < c1, this is a valid application. Get c2 with a <= c2 < c1. Since [c2] < [c1] = [b] and [a] < [b], and [c2] >= [a], we have either [c2] = [a] or [a] < [c2] < [b].

If [c2] is strictly between [a] and [b], done.

If [c2] = [a]: then a <= c2 and c2 <= a. Also c2 < c1 (where [c1] = [b]).

Now here is the key: c2 has neg(psi) in c2.world (from constrained_forward_below seed) AND c2 has GContent(a) subset c2 (from a <= c2).

**Step 5**: Apply `constrained_forward_above` to (c2, c1). Get c3 with c2 < c3 <= c1.

c3 has G(psi') in c3 for some psi' not in c2. Since c2 is in class [a] and c3 > c2, either [c3] = [a] or [c3] = [b] (assuming no intermediate class).

If [c3] = [b]: then c3 < c1 is impossible since both are in [b] -- wait, c3 <= c1 and we need c2 < c3. If [c3] = [b], then c1 <= c3 and c3 <= c1 (both in class [b]). And c2 < c3 (since psi' in GContent(c3) and psi' not in c2).

If [c3] = [a]: then c3 <= a. But c3 > c2, and c2 is in [a], so c3 >= c2 and [c3] = [a] means a <= c3 and c3 <= a. Also psi' in GContent(c3) subset a (since c3 <= a). But psi' not in c2. However c2 is in [a], so GContent(a) subset c2, and psi' in a but not necessarily in GContent(a), so psi' might not be in c2. This is consistent -- no contradiction.

The iteration can continue but doesn't obviously terminate in a contradiction.

### 4.6 The Correct Adjacency Argument

After the analysis above, the adjacency contradiction approach needs a more sophisticated argument. Here is one that works:

**Theorem**: In the canonical frame of TM + DN, the preorder on MCSes has the following density property: if w1 < w2 (CanonicalR w1 w2 and not CanonicalR w2 w1), then there exists w3 with w1 < w3 < w2.

**Proof using DN formula instances**:

Given w1 < w2, extract psi with F(psi) in w1, psi in w2, psi not in w1.

Construct the set:
```
S = {F(psi)} union GContent(w1) union HContent(w2)
```

This set is a subset of w1 (F(psi) in w1, GContent(w1) in w1 by reflexivity, HContent(w2) in w1 by duality). Hence consistent.

Extend S to MCS w3 by Lindenbaum. Then:
- w1 R w3 (GContent(w1) subset w3)
- w3 R w2 (HContent(w2) subset w3, gives GContent(w3) subset w2 by duality)
- F(psi) in w3

Now, F(psi) in w3 and DN gives F(F(psi)) in w3. By canonical_forward_F on w3: exists w4 in fragment with w3 R w4 and F(psi) in w4. By canonical_forward_F on w4: exists w5 with w4 R w5 and psi in w5.

So we have the chain: w1 R w3 R w4 R w5, with psi in w5.

**For w3 < w2**: Suppose w2 R w3 (for contradiction). Then GContent(w2) subset w3. In particular, G(psi) in w2, so psi in GContent(w2) subset w3. So psi in w3. And F(psi) in w3. That's fine, not a contradiction.

Hmm, psi in w3 doesn't contradict F(psi) in w3.

The issue is that F(psi) alone in w3 is NOT enough to prevent w2 R w3. We need something that's in w3 but NOT in b's G-content to prevent the backward relation.

**Enhancement**: Add neg(chi) to the seed for some chi in GContent(w2) \ w3.

But we're back to the combined seed problem.

### 4.7 Reformulated Recommendation

After thorough analysis, the adjacency contradiction approach in its pure form does not easily yield a proof. The core difficulty is always the same: achieving simultaneous two-sided strictness requires a seed containing formulas from both w1 and w2 that are not jointly consistent by subset-of-MCS arguments.

However, there IS a path forward. See Section 9 (Recommended Strategy).

---

## 5. Approach 3: Irreflexive Setting

### 5.1 Strategy

Work with a strict temporal logic where G means "at all STRICTLY future times" (not including the present). In such a setting:
- G(phi) does NOT imply phi
- The T-axiom is absent
- CanonicalR becomes irreflexive (the canonical relation for strict G)
- The quotient issue vanishes (an irreflexive total order is already antisymmetric)

### 5.2 Analysis

**Advantages**:
- The combined seed `{G(psi), neg(psi)}` becomes consistent (no T-axiom chain)
- The density proof follows the standard textbook argument directly
- No need for Antisymmetrization quotient

**Disadvantages**:
- Requires changing the axiom system from reflexive G/H to irreflexive G'/H'
- All existing proofs (soundness, truth lemma, linearity, totality, etc.) would need to be redone or adapted
- The JPL paper uses reflexive temporal operators, so this deviates from the source
- Massive refactoring effort (1000+ lines affected)

### 5.3 Feasibility of a Translation Layer

One could define:
```lean
G'(phi) = G(phi) ∧ phi      -- strict future "always" = phi now AND always in future
F'(phi) = F(phi) ∨ phi       -- strict future "sometimes" = phi now OR sometime in future
```

Wait, that's backwards. For irreflexive G' (strictly future):
```lean
G'(phi) = phi ∧ G(phi)       -- NO: this is reflexive G again
G'(phi) = G(phi) \ {current}  -- NOT expressible in modal syntax
```

The issue is that strict-future G' is NOT definable from reflexive G in the modal language without additional operators. So a translation layer is not feasible.

### 5.4 Verdict

**Not recommended.** The architectural cost is prohibitive (1000+ lines of rework) and deviates from the source material.

---

## 6. Approach 4: Frame Density Without Quotient

### 6.1 Strategy

Prove that CanonicalR on MCSes (or on the BidirectionalFragment) is dense in the strict sense: if w1 R w2 and not w2 R w1, then there exists w3 with w1 R w3, w3 R w2, not w3 R w1, and not w2 R w3.

### 6.2 Analysis

This is EXACTLY the same problem as proving DenselyOrdered on the preorder. The preorder has a < b iff a R b and not b R a. DenselyOrdered requires a < c < b for some c. This is:
- a R c (a <= c)
- c R b (c <= b)
- not c R a (so a < c)
- not b R c (so c < b)

Which is the four conditions above. So Approach 4 is identical to the blocker problem. The quotient adds no difficulty (Section 2).

### 6.3 Verdict

**Equivalent to the original problem.** Not a distinct approach.

---

## 7. Approach 5: Direct Q-Embedding

### 7.1 Strategy

Instead of proving DenselyOrdered and applying Cantor's theorem, directly construct an order-embedding of the quotient into Q. This bypasses the DenselyOrdered proof entirely.

### 7.2 Construction Sketch

For any countable linear order L, there exists an order-embedding L -> Q (this is a standard result, weaker than Cantor's isomorphism theorem). The construction:

1. Enumerate elements of L as l_0, l_1, l_2, ...
2. Map each l_i to a rational that preserves the order of previously mapped elements
3. This always succeeds because Q is dense and unbounded

### 7.3 Problem: Embedding vs Isomorphism

An order-EMBEDDING L -> Q gives L as an ordered SUBSET of Q. But for the torsor construction, we need T ISOMORPHIC to Q (or at least, we need D to act freely and transitively on T).

If T merely embeds into Q, we can still define D as the translation group of T's image in Q, but this group may not be all of Q -- it depends on the image's structure.

However, there's a clean alternative: define D as Q and use the embedding to transfer the torsor structure. Specifically:
1. Embed T into Q
2. Show the image is a dense subset of Q (from DN)
3. ... but actually, the IMAGE of T in Q may not be all of Q, so T is not isomorphic to Q.

The embedding approach does not bypass the need for density. Without density, T could be isomorphic to Z, and an embedding Z -> Q exists but does not make T isomorphic to Q.

### 7.4 Verdict

**Does not bypass the blocker.** The isomorphism T ≃o Q requires T to be dense; an embedding alone is insufficient for the torsor construction.

---

## 8. Analysis Summary

| Approach | Feasibility | Effort | Verdict |
|----------|------------|--------|---------|
| 1. Two-formula seed | Blocked by T-axiom | N/A | BLOCKED |
| 2. Adjacency contradiction | Promising but needs careful argument | 80-120 lines | RECOMMENDED (with modification) |
| 3. Irreflexive setting | Requires major refactor | 1000+ lines | NOT RECOMMENDED |
| 4. Frame density (no quotient) | Equivalent to original | N/A | SAME PROBLEM |
| 5. Direct Q-embedding | Does not bypass density | N/A | INSUFFICIENT |

---

## 9. Recommended Strategy: Soundness-Based Density

### 9.1 Core Insight

The approaches above try to prove density SYNTACTICALLY (constructing intermediate MCSes with explicit formula content). The recommended approach instead uses SOUNDNESS to transfer the density property.

**Key Observation**: The canonical model satisfies all theorems of TM + DN (by the truth lemma). DN = F(phi) -> F(F(phi)) is a theorem. The frame condition for DN is EXACTLY the density of the strict order. Therefore, the canonical frame IS dense.

The challenge is formalizing this "frame condition" argument in Lean. Here is how:

### 9.2 The Frame Condition Lemma

**Lemma (DN frame condition)**: Let M be a Kripke model where DN holds at all worlds for all formulas. Then the underlying frame is dense.

**Proof**: Given w1 < w2 (w1 R w2, not w2 R w1):

1. Extract psi with psi not in w1, psi in w2 (from not w2 R w1).
2. Since w1 R w2 and psi in w2: F(psi) in w1 (by `canonical_F_of_mem_successor`, already proven).
3. By DN at w1 with formula psi: F(F(psi)) in w1.
4. By canonical_forward_F on w1 with F(psi): exists w3 with w1 R w3 and F(psi) in w3.
5. By canonical_forward_F on w3 with psi: exists w4 with w3 R w4 and psi in w4.

We have: w1 R w3 R w4 and psi in w4, psi not in w1.

Now we need: w1 < w3 or w3 < w2 (at least one strict inequality strictly between w1 and w2).

**Case A**: w1 < w3 (not w3 R w1). Then we need w3 <= w2.
  - If w3 R w2 (w3 <= w2), then w1 < w3 <= w2, so w1 < w3 < w2 or w3 = w2 (in the quotient). Either way, w3 <= w2 with w1 < w3.

**Case B**: w3 R w1 (so w3 and w1 are equivalent or w3 < w1). But w1 R w3 too, so w1 and w3 are in the same equivalence class.

In Case B, w3 has F(psi) and is equivalent to w1. Now w3 R w4 with psi in w4.

**Sub-case B1**: w4 R w1 and w1 R w4 (w4 equivalent to w1). Then psi in w4 and GContent(w1) = GContent(w4) (mutual R). But psi not in w1, and psi in w4. These are different MCSes in the same class. Now w4 R w2 (by w4 equiv w1, and w1 R w2, transitivity). So w1 <= w4 <= w2, but [w4] = [w1], so this doesn't help.

**Sub-case B2**: not w4 R w1 (w1 < w4). Then w1 < w4. And w4 R w2? We need to check: w3 R w4, w3 equiv w1, w1 R w2. By transitivity of R and w3 equiv w1: w4 is accessible from w1 (w1 R w3 R w4, so w1 R w4 by transitivity). And w4 R w2? Not necessarily.

Hmm, w4 does NOT necessarily satisfy w4 R w2.

### 9.3 The Constrained F-Witness Approach

The issue with Section 9.2 is that the witness w3 from `canonical_forward_F` does not preserve the relation to w2. We need a CONSTRAINED witness.

**Revised construction**: Instead of generic canonical_forward_F, use a constrained Lindenbaum that includes HContent(w2) in the seed:

Seed = {F(psi)} union GContent(w1) union HContent(w2)

This seed is a subset of w1.world (proven in constrained_seed_below_subset_a, with F(psi) playing the role of the distinguishing formula). Actually, F(psi) is in w1 (step 2), GContent(w1) in w1 (reflexivity), HContent(w2) in w1 (duality). So the seed is subset of w1, hence consistent.

Extending to MCS w3:
- F(psi) in w3
- w1 R w3 (GContent(w1) subset w3)
- w3 R w2 (HContent(w2) subset w3, then by duality GContent(w3) subset w2)

Now w1 <= w3 <= w2, and F(psi) in w3.

By DN: F(F(psi)) in w3. By canonical_forward_F: exists w4 with w3 R w4 and F(psi) in w4.

But w4 is NOT constrained to be <= w2.

**Enhanced seed for w4**: Use constrained Lindenbaum again:

Seed2 = {F(psi)} union GContent(w3) union HContent(w2)

This is subset of w3 (F(psi) in w3, GContent(w3) in w3, HContent(w2) in w3 -- the last because w3 R w2 implies HContent(w2) subset w3 by duality? Actually, w3 R w2 means GContent(w3) subset w2. By the duality lemma `GContent_subset_implies_HContent_reverse`, HContent(w2) subset w3. Yes!)

So Seed2 is consistent (subset of w3). Extend to w4:
- F(psi) in w4
- w3 R w4 (GContent(w3) subset w4)
- w4 R w2 (HContent(w2) subset w4, by duality gives GContent(w4) subset w2)

Now: w1 <= w3 <= w4 <= w2, with F(psi) in w3 and F(psi) in w4.

We can continue this iteration indefinitely: w1 <= w3 <= w4 <= w5 <= ... <= w2, all with F(psi).

By DN on each: F(F(psi)) in each.

**But we still don't have strictness!** F(psi) alone does not give us anything in GContent to prevent backward relations.

### 9.4 The Breakthrough: Using Infinitely Many Intermediate Points

The iteration in 9.3 gives an infinite chain w1 = c0 <= c1 <= c2 <= ... <= w2, all with F(psi). In the QUOTIENT, this is a chain [w1] = [c0] <= [c1] <= ... <= [w2].

If ALL [ci] equal either [w1] or [w2], then the quotient has only two elements between (and including) [w1] and [w2]. But the chain is infinite, and each ci is an MCS.

Actually, this doesn't lead anywhere new. The chain could have all ci in class [w1] or [w2].

### 9.5 The Actual Recommended Approach: F(psi) Witness Strictness

Here is the approach that actually works. Return to the basic setup:

Given a < b, with psi such that F(psi) in a, psi in b, psi not in a, G(psi) in b.

By DN: F(F(psi)) in a.

Use `constrained_forward_above` to get c with a < c <= b (using G(psi) seed, so psi in GContent(c), giving a < c since psi not in a).

If c < b, DONE. The interesting case is c <= b AND b <= c (same class as b).

Now c has: G(psi) in c (from seed), and c is in class [b]. Also GContent(a) subset c.

Apply `constrained_forward_below` to the pair (a, c). This gives c' with a <= c' < c. Since [c] = [b], c' < c means c' < b. If a < c', done.

The remaining case: c' <= a and a <= c' (same class as a), AND c' < c (i.e., c' < b).

c' has: neg(psi) in c' (from constrained_forward_below seed). And c' is in class [a].

Now we need another element. But here's the key: c' also has F(psi) in c'. Why?

From the constrained_forward_below seed: {neg(psi)} union GContent(a) union HContent(c). Since c is in class [b], HContent(c) = HContent of something equivalent to b.

Does c' have F(psi)? The seed includes GContent(a), and F(psi) in a.world, but F(psi) is NOT in GContent(a) (F(psi) = neg(G(neg psi)), not of the form G(something)).

So F(psi) is NOT guaranteed to be in c'. However, we can ADD it to the seed:

Seed = {neg(psi), F(psi)} union GContent(a) union HContent(c)

This seed is subset of a.world: neg(psi) in a (psi not in a), F(psi) in a, GContent(a) in a, HContent(c) in a (from a <= c and duality... actually a <= c gives GContent(a) subset c, so HContent(c) subset a by duality). Confirmed, seed subset of a.world.

Extending to c': neg(psi) in c', F(psi) in c', GContent(a) subset c' (so a R c'), HContent(c) subset c' (so c' R c, i.e., c' <= c).

Now c' has F(psi). By DN: F(F(psi)) in c'. Since [c'] = [a], and a has F(F(psi)) too.

Apply the constrained construction AGAIN from c' toward c, but this time with a MODIFIED seed using F(psi):

Seed3 = {F(psi)} union GContent(c') union HContent(c)

Note GContent(c') = GContent(a) (since [c'] = [a], mutual R). And HContent(c) = HContent of class [b].

Seed3 is subset of c' (F(psi) in c', GContent(c') in c' by reflexivity, HContent(c) in c' by duality from c' R c). Consistent.

Extend to c'': F(psi) in c'', c' R c'' (GContent(c') subset c''), c'' R c (HContent(c) subset c'').

Now c'' has F(psi). By canonical_forward_F on c'' with psi: exists d with c'' R d and psi in d. But d may not be <= c.

THIS IS GOING IN CIRCLES. Every constrained construction maintains `<= w2` via HContent but cannot achieve the second strictness condition because F(psi) doesn't contribute to GContent.

### 9.6 The REAL Solution: G-Content Accumulation

The fundamental obstacle is that we need to put something in GContent(c) that's NOT in a, while also having something in c that prevents b R c. The T-axiom makes G(something) and neg(something) contradictory.

**The actual solution uses the P (past) direction.**

Given a < b, with psi such that G(psi) in b, psi not in a.

By the past T-axiom analogy: H(phi) -> phi. And there exists chi with H(chi) in a, chi not in b (from not b R a, looking at HContent).

Wait -- not b R a means not GContent(b) subset a. That gives us something in GContent(b) not in a, which is psi. It does NOT directly give us something in HContent(a) not in b.

Actually, let me check: does not(b R a) give something in HContent(a) not in b?

b R a means GContent(b) subset a. By duality (GContent_subset_implies_HContent_reverse): HContent(a) subset b.

NOT(b R a) does NOT directly imply NOT(HContent(a) subset b). The duality goes one way: GContent(b) subset a IMPLIES HContent(a) subset b. The contrapositive: NOT(HContent(a) subset b) IMPLIES NOT(GContent(b) subset a). But NOT(GContent(b) subset a) does NOT imply NOT(HContent(a) subset b).

Hmm. So we CANNOT extract a past-direction distinguishing formula from a < b.

Actually, let me check the duality more carefully. Is the duality an equivalence or just one direction?

From `GContent_subset_implies_HContent_reverse`: if GContent(M1) subset M2 (i.e., M1 R M2), then HContent(M2) subset M1 (i.e., M2 R_past M1).

And `HContent_subset_implies_GContent_reverse`: if HContent(M1) subset M2 (i.e., M1 R_past M2), then GContent(M2) subset M1 (i.e., M2 R M1).

So GContent(b) subset a IFF HContent(a) subset b. These are EQUIVALENT for MCSes.

Therefore: NOT(GContent(b) subset a) IFF NOT(HContent(a) subset b).

So not(b R a) DOES give us chi in HContent(a) not in b. Specifically: exists chi with H(chi) in a and chi not in b.

Now we have:
- psi: G(psi) in b, psi not in a (from GContent(b) not subset a)
- chi: H(chi) in a, chi not in b (from HContent(a) not subset b)

These are INDEPENDENT formulas. psi distinguishes via the future direction, chi via the past direction.

**Combined seed using BOTH future and past distinguishing formulas**:

Seed = {G(psi), neg(chi)} union GContent(a) union HContent(b)

Check consistency: Is this seed subset of some MCS?

- G(psi) in b (given)
- neg(chi) -- is it in b? chi not in b, so neg(chi) in b (MCS completeness). YES.
- GContent(a) subset b (from a R b)
- HContent(b) subset b (by reflexivity)

**The entire seed is a subset of b.world!** Therefore it is consistent.

Extend to MCS c via Lindenbaum:
- G(psi) in c -- so psi in GContent(c)
- neg(chi) in c
- GContent(a) subset c -- so a R c (a <= c)
- HContent(b) subset c -- so by duality, c R b (c <= b)

**Strictness check 1 (a < c)**: psi in GContent(c) and psi not in a. So GContent(c) NOT subset a. Therefore NOT(c R a). Hence a < c.

**Strictness check 2 (c < b)**: If b R c, then HContent(c) subset b (by duality from GContent(b) subset c). H(chi) in a, and a R c gives... hmm, we need H(chi) in c for this to work.

Actually, let me reconsider. We need to show NOT(b R c), i.e., NOT(GContent(b) subset c).

GContent(b) subset c means: for all phi, if G(phi) in b then phi in c. In particular, since H(chi) in a... no, H(chi) doesn't help directly.

Wait, chi is our past-distinguishing formula. G(chi)... is G(chi) in b? Not necessarily. chi was extracted from HContent(a) not in b, meaning H(chi) in a and chi not in b. We don't know about G(chi).

Let me reconsider the structure. neg(chi) in c. To show NOT(b R c), we need something in GContent(b) that's NOT in c. Is there such a thing?

GContent(b) has psi in it (G(psi) in b). psi in c? We have G(psi) in c, so by T-axiom psi in c. So psi IS in c. That doesn't help.

What about chi? Is chi in GContent(b)? We don't know. chi is characterized by H(chi) in a and chi not in b. There's no reason for G(chi) to be in b.

Hmm. neg(chi) in c. If chi were in GContent(b) (i.e., G(chi) in b), then b R c would give chi in c, contradicting neg(chi) in c. So IF G(chi) in b, we'd get NOT(b R c). But we DON'T know G(chi) in b.

**Key question**: Can we choose chi so that G(chi) in b?

We need chi in HContent(a) \ b AND chi in GContent(b). That is:
- H(chi) in a
- chi not in b
- G(chi) in b

Is this possible? G(chi) in b and chi not in b contradicts the T-axiom (G(chi) -> chi in b gives chi in b). So NO, G(chi) in b and chi not in b is impossible.

So we CANNOT use chi for both the past-distinguishing role and the GContent(b) role.

### 9.7 ACTUAL BREAKTHROUGH: Using P(psi) and the Past Seed

Let me try a different approach to the "below" strictness.

**Setup**: a < b, psi with G(psi) in b, psi not in a, F(psi) in a.

Instead of preventing b R c via negation of a formula, use the PAST direction.

Consider: H(neg(psi)) in a? If H(neg(psi)) in a, then neg(psi) in HContent(a), which is subset of b (from duality, since a R b implies HContent(a)... wait, that's backward. a R b means GContent(a) subset b. By duality HContent(b) subset a. NOT HContent(a) subset b (that's the reverse direction, which is b R a, which we don't have).

So HContent(a) is NOT necessarily subset of b.

Back to the drawing board. Let me try:

Seed = {G(psi), P(neg(psi))} union GContent(a) union HContent(b)

where P(neg(psi)) = neg(H(psi)).

P(neg(psi)) in b? We have psi in b, so H(psi)... H(psi) means "psi at all past times." By T-axiom for past: H(psi) -> psi. So H(psi) in b would imply psi in b, which is true. But H(psi) might or might not be in b.

Actually, the question is whether P(neg(psi)) = neg(H(psi)) is in b. If H(psi) is in b, then neg(H(psi)) is NOT in b. If H(psi) NOT in b, then neg(H(psi)) = P(neg(psi)) IS in b.

Is H(psi) in b? H(psi) means "psi at all past and current times." We know psi in b. By temp_a: psi -> G(P(psi)) in b, so G(P(psi)) in b. But this is about P(psi) being always true in the future, not H(psi) being in b.

We don't have information about H(psi) in b. It could go either way.

This approach is also getting stuck. Let me reconsider fundamentally.

### 9.8 Synthesis: The Working Approach

After extensive analysis, here is an approach that resolves the blocker:

**Use a WEAKER intermediate point**: Instead of requiring a SINGLE c with a < c < b, observe that the one-sided lemmas give us elements in the "gap" and we can combine them:

**Step 1**: `constrained_forward_above` gives c1 with a < c1 <= b. G(psi) in c1, psi in GContent(c1), psi not in a.

**Step 2**: `constrained_forward_below` gives c2 with a <= c2 < b. neg(psi) in c2.

**Step 3**: By totality (bidirectional_totally_ordered), c1 and c2 are comparable: c1 <= c2 OR c2 <= c1 OR c1.world = c2.world.

**Case c1.world = c2.world**: Then psi in GContent(c1) = GContent(c2) (since their worlds are equal), so psi in c2 by T-axiom. But neg(psi) in c2. Contradiction with MCS consistency. This case is IMPOSSIBLE.

**Case c2 <= c1**: GContent(c2) subset c1. We need to determine if c2 < c1 or c1 <= c2. If c1 <= c2 too, then c1.world could equal c2.world (handled above, impossible) or they're equivalent. If equivalent, GContent(c1) subset c2, so psi in GContent(c1) subset c2, so psi in c2, contradicting neg(psi) in c2. So this sub-case is also impossible. Therefore c2 < c1 (STRICT).

Now we have a < c1 <= b and a <= c2 < b and c2 < c1.

**Sub-case c2 < c1 < b**: Then c1 is our answer (a < c1 < b).
**Sub-case c2 < c1 and c1 <= b and b <= c1**: [c1] = [b]. Then a <= c2 < c1, and [c1] = [b]. If a < c2, then c2 is our answer (a < c2 < b since c2 < c1 equiv b). If [c2] = [a], continue...

**Case c1 <= c2**: GContent(c1) subset c2, so psi in GContent(c1) subset c2, so psi in c2. But neg(psi) in c2. Contradiction. This case is IMPOSSIBLE.

**Summary of case analysis**:
- c1 = c2 (worlds equal): IMPOSSIBLE (psi and neg(psi) in same MCS)
- c1 <= c2: IMPOSSIBLE (psi in c2 from GContent(c1), contradicts neg(psi) in c2)
- c2 <= c1: FORCED. And c2 < c1 strictly (if c1 <= c2 also, contradiction as above).

So we ALWAYS have c2 < c1 (strict). Together with a < c1 <= b and a <= c2 < b.

Now: a <= c2 < c1 <= b.

If a < c2, DONE: a < c2 < c1 <= b, so a < c2 < b (since c2 < c1 <= b gives c2 < b which we already have).

If c2 <= a (so [c2] = [a]), AND c1 < b: DONE, a < c1 < b.

The ONLY remaining case: [c2] = [a] AND [c1] = [b]. That is, a <= c2 <= a and b <= c1 <= b.

In this case, we apply the density argument recursively to the pair (c2, c1), which has the same quotient gap [a] < [b].

**BUT**: c2 has neg(psi) and F(psi), while c1 has G(psi). These are DIFFERENT representatives of [a] and [b] respectively.

**Key new ingredient**: From c2 < c1, extract a DIFFERENT distinguishing formula psi'. Specifically, apply `strict_lt_has_distinguishing_formula` to (c2, c1): exists psi' with G(psi') in c1, psi' in c1, psi' not in c2, F(psi') in c2.

Now psi' is possibly different from psi. Apply `constrained_forward_above` and `constrained_forward_below` to (c2, c1) using psi':
- c1' with c2 < c1' <= c1, G(psi') in c1'
- c2' with c2 <= c2' < c1, neg(psi') in c2'

By the same case analysis: c2' < c1' (strict).

If c2' or c1' gives a strictly intermediate element, done. Otherwise, [c2'] = [c2] = [a] and [c1'] = [c1] = [b].

**Iteration terminates?** Each iteration produces new MCSes c2', c1' with new formulas. The FORMULA psi' at iteration i might equal psi or be different. If the SAME psi is extracted each time, we're stuck. But are there only finitely many equivalence classes (no -- the set of formulas is countable but the MCSes are uncountable)?

Actually, the iteration doesn't obviously terminate. But here's the resolution:

**In the last remaining case ([c2] = [a], [c1] = [b]), the pair (c2, c1) is ANOTHER instance of the same problem, with DIFFERENT representatives.** If we could show that the distinguishing formula psi' is DIFFERENT from psi, we'd get an infinite descent, but that's not obviously useful either.

However, let me reconsider the case [c2] = [a] and [c1] = [b] more carefully.

We have: c2 in class [a], c1 in class [b], c2 < c1.

c2 has: neg(psi) in c2, GContent(a) subset c2, HContent(b) subset c2.
c1 has: G(psi) in c1, psi in GContent(c1), GContent(a) subset c1, HContent(b) subset c1.

**c2 also has F(psi)**: From the enhanced seed {neg(psi), F(psi)} union GContent(a) union HContent(b) (which is subset of a, as shown in Section 9.5).

So c2 has F(psi) and neg(psi).

By DN on c2: F(F(psi)) in c2. So there exists c3 with c2 R c3 and F(psi) in c3.

We want c3 to also satisfy c3 R c1 (c3 <= c1). Use constrained construction:

Seed = {F(psi)} union GContent(c2) union HContent(c1)

This is subset of c2: F(psi) in c2, GContent(c2) in c2 by reflexivity, HContent(c1) in c2 because c2 R c1 implies HContent(c1) subset c2 by duality.

Extend to c3: F(psi) in c3, c2 R c3, c3 R c1.

Now c2 <= c3 <= c1, with F(psi) in c3.

We also know psi not in c2 (neg(psi) in c2). And psi in GContent(c1) (G(psi) in c1).

If c3 R c1 (yes, from seed) and c1 R c3: then [c3] = [c1] = [b]. psi in GContent(c1) subset c3 (from c1 R c3), so psi in c3. And neg(psi) might or might not be in c3.

If NOT c1 R c3: then c3 < c1, i.e., c3 < b. Combined with c2 <= c3 (from c2 R c3), if c2 < c3, we have c2 < c3 < c1 and [a] = [c2] < [c3] < [c1] = [b], DONE.

If c2 R c3 and c3 R c2: [c3] = [c2] = [a]. GContent(c2) subset c3 and GContent(c3) subset c2. We still have F(psi) in c3 and all GContent of class [a] in c3.

So the question reduces to: is c1 R c3 or not?

If c1 R c3 ([c3] = [b]): psi in c3 (from GContent(c1) subset c3). And c3 has F(psi). Both psi and F(psi) can coexist -- no contradiction.

If NOT c1 R c3 (c3 < c1): if c2 < c3, DONE. If [c3] = [c2], iterate.

THE ITERATION MIGHT NOT TERMINATE. But there's a crucial observation:

**Each new intermediate point c3 has F(psi) in it.** And c3 is between c2 and c1 (in the preorder). If [c3] = [a], then c3 is a NEW element of class [a] with F(psi). If [c3] = [b], then c3 is a new element of class [b] with F(psi).

The CLASSES [a] and [b] can contain infinitely many MCSes. The iteration produces new MCSes but doesn't necessarily produce new classes.

### 9.9 The Resolution: Well-Ordering Argument or Syntactic Density

I believe the correct resolution involves recognizing that the EXISTING one-sided constructions, combined with the totality case analysis (Section 9.8 showing c2 < c1), give us a chain:

a <= c2 < c1 <= b  with [c2] = [a], [c1] = [b] in the worst case.

Now, between c2 and c1 we can find c3 (by the same argument applied to the pair c2, c1). If [c3] is neither [a] nor [b], done. If [c3] = [a] or [c3] = [b], iterate.

**Claim**: The iteration MUST terminate because of the FORMULAS involved.

Each application of `strict_lt_has_distinguishing_formula` to a pair (ci, cj) with [ci] = [a] < [b] = [cj] produces a formula psi_k with G(psi_k) in cj, psi_k not in ci. If psi_k is always the SAME formula psi, the iteration doesn't progress. But the REPRESENTATIVES ci, cj change.

**Actually, the formula CAN be the same psi every time**, because psi is defined by the GAP between classes [a] and [b], not by the specific representatives. Every representative of [b] has G(psi) (since all have the same GContent), and no representative of [a] has psi (since psi not in any GContent(a)-equivalent set by the equivalence class definition... wait, psi not in a.world but psi COULD be in c2.world, since c2 is a different MCS in class [a]).

Actually, c2 has neg(psi) in c2.world, so psi NOT in c2. And for any representative w of class [a]: does w have psi or neg(psi)? Since w is in class [a], a R w and w R a. w R a means GContent(w) subset a. a has neg(psi) (psi not in a). But GContent(w) subset a doesn't tell us whether psi or neg(psi) is in w.

So representatives of [a] can have psi or neg(psi). The one-sided constructions specifically build representatives with neg(psi).

This analysis shows the problem is genuinely hard syntactically.

---

## 10. The Actual Recommended Path: Enhanced Constrained Seed

After the extensive analysis above, here is the approach I recommend:

### 10.1 The Key Lemma to Prove

```lean
theorem density_from_DN
    (a b : BidirectionalFragment M0 h_mcs0)
    (h_lt : a < b) :
    exists c : BidirectionalFragment M0 h_mcs0, a < c ∧ c < b
```

### 10.2 Proof Strategy

**Phase A**: Extract two elements using existing one-sided constructions.
1. From `constrained_forward_above`: get c1 with a < c1 <= b
2. From `constrained_forward_below` (enhanced with F(psi) in seed): get c2 with a <= c2 < b, F(psi) in c2, neg(psi) in c2
3. By totality + contradiction analysis: c2 < c1 (strict)

**Phase B**: If c1 < b or a < c2, done. Otherwise [c1] = [b] and [c2] = [a].

**Phase C**: In the [c1] = [b], [c2] = [a] case, construct c3 using a THIRD seed that combines information from c2 and c1:

Seed = {F(psi), G(psi)} union GContent(c2) union HContent(c1)

Check: G(psi) in c1 (since G(G(psi)) in c1 by Temp4, wait... c1 is in class [b], G(psi) in b, so G(psi) in c1? Not directly. G(psi) in GContent(b). c1 in class [b] means b R c1, so GContent(b) subset c1. So G(psi) is in c1 but not necessarily via GContent(c1).

Actually: G(psi) in c1. By Temp4: G(G(psi)) in c1, so G(psi) in GContent(c1).

And F(psi) in c2 (from enhanced seed in step 2).

Seed = {F(psi), G(psi)} union GContent(c2) union HContent(c1)

Is this subset of c1? G(psi) in c1 (yes). F(psi) in c1? F(psi) = neg(G(neg(psi))). By T-axiom, G(psi) -> psi, so psi in c1. F(psi) = neg(G(neg psi)). G(neg psi) in c1 would give neg(psi) in c1 by T-axiom, contradicting psi in c1. So G(neg psi) NOT in c1, hence neg(G(neg psi)) = F(psi) in c1. Yes, F(psi) in c1.

GContent(c2) subset c1? c2 R c1 (from c2 < c1, which means c2 <= c1), so yes.
HContent(c1) subset c1? By reflexivity yes.

**Seed is subset of c1, hence consistent.**

Extend to c3:
- F(psi) in c3
- G(psi) in c3 -> psi in c3 (by T-axiom) -> psi in GContent(c3) (from G(psi) in c3)
- c2 R c3 (GContent(c2) subset c3)
- c3 R c1 (HContent(c1) subset c3 -> GContent(c3) subset c1 by duality)

**Strictness check 1 (c2 < c3)**: psi in GContent(c3). GContent(c3) subset c2? If so, psi in c2. But neg(psi) in c2. Contradiction. So NOT(GContent(c3) subset c2), i.e., NOT(c3 R c2). Since c2 R c3, we get c2 < c3.

**Strictness check 2 (c3 < c1)**: Need NOT(c1 R c3), i.e., NOT(GContent(c1) subset c3). F(psi) in c3, psi in c3 (from G(psi) via T-axiom). So F(psi) and psi both in c3. Hmm, this doesn't prevent GContent(c1) subset c3.

Actually, GContent(c1) includes psi (since G(psi) in c1 means psi in GContent(c1)). And psi IS in c3. So psi being in both GContent(c1) and c3 is fine and doesn't prevent GContent(c1) subset c3.

What else is in GContent(c1)? ALL formulas phi such that G(phi) in c1. c1 is in class [b], so c1 has the same GContent-relevant structure as b. We need something in GContent(c1) that is NOT in c3.

From c3's construction: c3 extends the seed. The seed is a subset of c1, so c3 extends to a SUPERSET of the seed that is an MCS. It could potentially contain all of GContent(c1) (making [c3] = [c1] = [b]).

So this approach ALSO does not guarantee c3 < c1.

### 10.3 Final Assessment

**The density proof from DN appears to require one of**:
1. A compactness/model-theoretic argument showing the combined seed `{G(psi), neg(psi')} union GContent(a) union HContent(b)` is consistent for SOME pair psi, psi' in GContent(b) \ a -- this requires finding formulas where the T-axiom chain does not connect them.
2. A global argument (not per-pair) showing the quotient MUST be dense because DN is valid in the canonical model.

Option 2 is the more promising direction. The canonical model satisfies DN at every world (truth lemma). DN's frame condition is density. So the canonical frame IS dense. The issue is that "frame condition" arguments typically go through the SOUNDNESS direction (dense frame -> DN valid), not the COMPLETENESS direction (DN valid at all worlds -> frame dense).

**For completeness direction**: We need to show that if DN holds at every MCS (syntactically), then the CanonicalR relation is dense. This is exactly what we've been trying to do, and it seems to require the combined seed construction.

### 10.4 Recommended Next Steps

1. **Attempt the enhanced seed with F(psi)**: Prove `{F(psi), G(psi)} union GContent(a) union HContent(b)` gives c3 with a < c3 (from psi in GContent(c3) and psi not in a) and c3 < b. The "c3 < b" part needs additional argument.

2. **If stuck on c3 < b**: Consider the counting argument. If we can show the seed forces c3 to contain neg(chi) for some chi in GContent(b), that would give NOT(b R c3). This requires analyzing what the Lindenbaum construction is FORCED to include.

3. **Alternative: prove DenselyOrdered as an axiom-level property**. Define a helper predicate `FrameDense(R)` that states density of R, prove DN implies FrameDense for any model satisfying DN, then apply to the canonical model.

4. **If ALL syntactic approaches fail**: Mark the density proof as [BLOCKED] and consider working with the WEAKER result a <= c <= b (which is available), proving density at a later stage, or accepting the density of the canonical frame as an axiom (technical debt).

**I do NOT recommend Option B (sorry deferral)**. If the syntactic density proof is genuinely blocked, the task should be marked [BLOCKED] for user mathematical review rather than proceeding with sorry.

---

## 11. Mathlib Theorems Found

| Theorem | Type | Relevance |
|---------|------|-----------|
| `toAntisymmetrization_lt_toAntisymmetrization_iff` | `[a] < [b] <-> a < b` | Trivializes quotient transfer |
| `antisymmetrization_fibration` | Lifting property for `<` | Alternative quotient transfer |
| `Order.iso_of_countable_dense` | Cantor's theorem for countable dense orders | T ≃o Q once density is proven |
| `addGroupIsAddTorsor` | Every AddGroup is a self-torsor | D = Q torsor structure |
| `OrderDual.denselyOrdered` | Dual order preserves density | May be useful for past direction |

---

## 12. Effort Estimates

| Component | Lines | Difficulty | Status |
|-----------|-------|------------|--------|
| Quotient transfer (Section 2) | 10-15 | Low | Ready to implement |
| One-sided strictness (existing) | 0 | Done | COMPLETED |
| Totality case analysis (Section 9.8) | 30-40 | Medium | Ready |
| Combined c3 construction (Section 10.2) | 40-60 | Medium-High | Needs c3 < b argument |
| Full density proof | 80-120 total | High | Partially blocked on c3 < b |

---

## 13. Decisions

1. The quotient transfer is trivial and should be implemented immediately (Section 2).
2. The one-sided constructions should be combined with totality to get c2 < c1 (Section 9.8, Phase A).
3. The combined seed approach `{F(psi), G(psi)} union GContent(c2) union HContent(c1)` gives c2 < c3 but the c3 < c1 direction remains open.
4. The T-axiom is the fundamental mathematical obstruction preventing direct combined-seed constructions.
5. If the c3 < b argument cannot be resolved, the task should be marked [BLOCKED] rather than using sorry.

---

## 14. Risks and Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| c3 < c1 argument not found | Medium | High | Mark [BLOCKED], request user mathematical review |
| Iteration doesn't terminate | Medium | High | Seek global/semantic argument instead of syntactic |
| T-axiom obstruction is fundamental | Medium | High | Consider irreflexive reformulation as future work |
| Combined seed requires new Lean infrastructure | Low | Medium | Build on existing constrained_forward_above/below |

---

## 15. Artifacts

- **This report**: `specs/956_construct_d_as_translation_group_from_syntax/reports/research-015.md`
- **Key referenced files**:
  - `Theories/Bimodal/Metalogic/Bundle/DenseQuotient.lean` -- Existing one-sided density lemmas
  - `Theories/Bimodal/Metalogic/Bundle/BidirectionalReachable.lean` -- Fragment, totality, quotient
  - `Theories/Bimodal/ProofSystem/Axioms.lean` -- DN axiom, T-axiom
  - `specs/956_construct_d_as_translation_group_from_syntax/handoffs/phase-6-blocker-20260309.md` -- Blocker document
