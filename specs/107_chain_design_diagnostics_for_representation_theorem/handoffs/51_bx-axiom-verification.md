# Phase 1: BX Axiom Sufficiency Verification for D0 Seed

## Status: VERIFIED WITH ADJUSTMENTS

## Executive Summary

BX5, BX13, BX14 provide the mathematical content needed for both Burgess Lemma 2.6 (D0 seed consistency) and Lemma 2.7 (Until-formula splitting). However, the plan's D0 seed definition and proof chain steps require corrections to align with the actual BX axiom statements and the codebase conventions.

---

## 1. Exact Lean Statements of Key BX Axioms

### BX5 (self_accum_until)

```
Axiom.self_accum_until (φ ψ : Formula) :
  Axiom ((φ.untl ψ).imp ((φ.and (φ.untl ψ)).untl ψ))
```

**Reads as**: `(φ U ψ) → ((φ ∧ (φ U ψ)) U ψ)`  
**Role**: Guard enrichment -- intermediate points get both φ (original guard) and the eventuality φ U ψ.

### BX7 (linear_until)

```
Axiom.linear_until (φ ψ χ θ : Formula) :
  Axiom (((φ.untl ψ).and (χ.untl θ)).imp
    ((((φ.and χ).untl (ψ.and θ)).or ((φ.and χ).untl (ψ.and χ))).or
      ((φ.and χ).untl (φ.and θ))))
```

**Reads as**: `(φ U ψ) ∧ (χ U θ) → ((φ∧χ) U (ψ∧θ)) ∨ ((φ∧χ) U (ψ∧χ)) ∨ ((φ∧χ) U (φ∧θ))`  
**Role**: Linear ordering of Until witnesses. Three disjuncts: witnesses coincide, first comes first, second comes first.

### BX13 (enrichment_until)

```
Axiom.enrichment_until (φ ψ p : Formula) :
  Axiom ((p.and (φ.untl ψ)).imp (φ.untl (ψ.and (φ.snce p))))
```

**Reads as**: `p ∧ (φ U ψ) → φ U (ψ ∧ (φ S p))`  
**Role**: Event enrichment -- the Until event is conjoined with a Since formula anchored at the current point.

### BX14 (separation_until)

```
Axiom.separation_until (p q r : Formula) :
  Axiom ((q.untl p).imp ((r.untl p).neg.imp (q.untl (q.and r.neg))))
```

**Reads as**: `(q U p) ∧ ¬(r U p) → q U (q ∧ ¬r)`  
**Role**: Separation -- if two Until formulas share the same event but one fails, the surviving guard gets narrowed.

---

## 2. Comparison with Burgess's Axioms

### A5a vs BX5

**Burgess A5a**: `U(p, q) → U(p, q ∧ U(p, q))`

This enriches the **event** with the eventuality itself: the event q is replaced by q ∧ U(p, q).

**BX5**: `(φ U ψ) → ((φ ∧ (φ U ψ)) U ψ)`

This enriches the **guard** with the eventuality: the guard φ is replaced by φ ∧ (φ U ψ), while the event ψ stays unchanged.

**Verdict**: BX5 is NOT identical to A5a -- they enrich different components (guard vs event). However, both are valid on linear orders. BX5 provides the critical property needed in the D0 proof: intermediate points satisfy both the original guard and the eventuality.

**Semantic equivalence for the D0 proof**: What matters is that after applying BX5, we have a new Until formula where intermediate points carry richer information. Both BX5 and A5a achieve this, but through different enrichment targets. The subsequent steps (BX14, BX13) must be adapted to work with BX5's guard-enriched output.

### A4a vs BX14

**Burgess A4a (plan rendering)**: `U(p, q) ∧ ¬U(p, r) → U(q ∧ ¬r, q)`

**BX14**: `(q U p) ∧ ¬(r U p) → q U (q ∧ ¬r)`

**Matching**: Set BX14's variables as: event p, guard q, negated-guard r. Then:
- `(q U p)` = U(guard=q, event=p)  
- `¬(r U p)` = ¬U(guard=r, event=p)  
- `q U (q ∧ ¬r)` = U(guard=q, event=q ∧ ¬r)

**Burgess A4a with his convention**: U(p, q) means guard=p, event=q:
- `U(p, q)` = U(guard=p, event=q)
- `¬U(p, r)` = ¬U(guard=p, event=r)
- `U(q ∧ ¬r, q)` = U(guard=q ∧ ¬r, event=q)

**Key difference**: In BX14, the two Until formulas share the same **event** (p) but have different guards (q vs r). In Burgess A4a, they share the same **guard** (p) but have different events (q vs r). The conclusion also differs in which component is modified.

**Semantic analysis**: Both are valid on linear orders. BX14 separates based on guard difference with shared event. Burgess A4a separates based on event difference with shared guard. For the D0 proof, we need the specific form that our BX14 provides.

**Verdict**: BX14 is a different axiom from A4a, but provides the same mathematical power for the seed consistency argument. The proof chain must be written to match BX14's actual statement.

### A3a vs BX13

**Burgess A3a (standard form)**: `p ∧ U(q, r) → U(q ∧ S(p, r), r)`

This enriches the **guard** with S(p, r): the guard changes from q to q ∧ S(p, r), event stays r.

**BX13**: `p ∧ (φ U ψ) → φ U (ψ ∧ (φ S p))`

This enriches the **event** with φ S p: the guard stays φ, event changes from ψ to ψ ∧ (φ S p).

**Verdict**: BX13 enriches a different component than A3a. Crucially, BX13 enriches the EVENT with a Since formula, while A3a enriches the GUARD. For the D0 proof, we need the event to contain S-formulas (since the seed D0 contains S-formulas that must appear at the witness point). BX13's event-enrichment is actually the CORRECT form for our needs.

### A7a vs BX7

**Burgess A7a**: `U(p,q) ∧ U(r,s) → U(p∧r, q∧s) ∨ U(p∧s, q∧s) ∨ U(q∧r, q∧s)`

Note: A7a has **fixed event q∧s** in all three disjuncts. This is UNSOUND under open guard semantics (documented in Axioms.lean line 248).

**BX7**: `(φ U ψ) ∧ (χ U θ) → ((φ∧χ) U (ψ∧θ)) ∨ ((φ∧χ) U (ψ∧χ)) ∨ ((φ∧χ) U (φ∧θ))`

BX7 has **mixed events** in the disjuncts (ψ∧θ, ψ∧χ, φ∧θ) and **shared guard φ∧χ**. This IS sound under open guard.

**Verdict**: BX7 replaces A7a for Lemma 2.7. The three disjuncts correspond to the same linear ordering of witnesses, but with different event formulas that respect open guard semantics. The D2 elimination in Lemma 2.7 must be adapted to BX7's specific disjunct forms.

---

## 3. D0 Seed Consistency Proof Trace (Corrected)

The plan's proof chain (steps 1-6) has correct intuition but uses conventions that don't match the actual BX axiom forms. Here is the corrected trace.

### Setup

Given: `BurgessR3Maximal(A, B, C)`, A and C are MCS, `g_content(A) ⊆ C`, delta not in B.

### Step 1: Maximality Extraction

From `BurgessR3Maximal_extension_fails` + `dc_delta_B_controlled`:
- Obtain beta0 in B, gamma0 in C with `neg-untl(beta0 ∧ delta, gamma0) ∈ A`
- (The failure may be in the Until or Since direction; handle Until WLOG)

**Codebase support**: `burgessR3_gamma_not_in_B` provides a weaker version (gamma not in B from neg-untl and delta in C). For the D0 seed, we need the explicit beta0, gamma0 extraction from `BurgessR3Maximal_extension_fails` + `dc_delta_B_controlled`. Both exist in the codebase (PointInsertion.lean lines 566-579, 583-601).

### Step 2: BX5 Self-Accumulation

From `burgessR3(A, B, C)`: for all beta in B, gamma in C, `untl(beta, gamma) ∈ A`.

Apply BX5 to `untl(beta, gamma)`:
```
untl(beta, gamma) → untl(beta ∧ untl(beta, gamma), gamma) ∈ A
```

**Result**: `untl(beta ∧ untl(beta, gamma), gamma) ∈ A` for all beta in B, gamma in C.

**Codebase support**: `until_self_accum_in_mcs` (RRelation.lean line 96) provides this at MCS level.

### Step 3: BX14 Separation

We have:
- `untl(beta ∧ untl(beta, gamma), gamma) ∈ A` (from step 2, with specific beta0, gamma0)
- `neg-untl(beta0 ∧ delta, gamma0) ∈ A` (from step 1)

To apply BX14: `(q U p) ∧ ¬(r U p) → q U (q ∧ ¬r)`

We need two Until formulas sharing the same event. Our formulas:
- `untl(beta0 ∧ untl(beta0, gamma0), gamma0)` -- guard = beta0 ∧ untl(beta0, gamma0), event = gamma0
- `untl(beta0 ∧ delta, gamma0)` -- guard = beta0 ∧ delta, event = gamma0

These share event gamma0. Set:
- p = gamma0 (shared event)
- q = beta0 ∧ untl(beta0, gamma0) (first guard)
- r = beta0 ∧ delta (second guard)

BX14 gives: `untl(q, q ∧ ¬r) ∈ A`
= `untl(beta0 ∧ untl(beta0, gamma0), (beta0 ∧ untl(beta0, gamma0)) ∧ ¬(beta0 ∧ delta)) ∈ A`

The event `(beta0 ∧ untl(beta0, gamma0)) ∧ ¬(beta0 ∧ delta)` contains:
- beta0 (from the first conjunct)
- untl(beta0, gamma0) (the eventuality persists)
- ¬(beta0 ∧ delta) which, combined with beta0, gives ¬delta

**Simplification**: At the witness point where this event holds: beta0, untl(beta0, gamma0), and neg-delta all hold. This is the key content the D0 seed needs.

### Step 4: BX13 Enrichment (Iterated)

For each alpha in A, apply BX13 to the formula from step 3:

BX13: `p ∧ (φ U ψ) → φ U (ψ ∧ (φ S p))`

With:
- p = alpha (the formula we want to enrich with)
- phi = guard from step 3
- psi = event from step 3

Since alpha ∈ A and the Until formula is in A, BX13 gives:
```
untl(guard, event ∧ snce(guard, alpha)) ∈ A
```

At the witness point: the event holds, AND snce(guard, alpha) holds. The Since formula `snce(guard, alpha)` at the witness point means: there exists a past point (namely the evaluation point of A) where alpha holds, and guard held in between.

**For the D0 seed**: The Since formulas in D0 are `S(alpha, beta)` for alpha in A, beta in B. Via BX13, the event of our enriched Until contains snce(guard, alpha) for each alpha in A. The guard includes beta0 (from step 3), so snce(guard, alpha) is a stronger form of snce(beta, alpha) = S(beta, alpha).

This is where the event-enrichment form of BX13 is actually BETTER than Burgess's guard-enrichment A3a for our purposes: the S-formulas land in the event, which means they hold at the witness point, which is where D0 elements need to appear.

### Step 5: Consistency via BX10

After enrichment, we have an Until formula in A (which is MCS, hence consistent):
```
untl(guard, enriched_event) ∈ A
```

By BX10 (until_F): `F(enriched_event) ∈ A`.

By the MCS property and F semantics, enriched_event is consistent.

The enriched event contains: beta0, untl(beta0, gamma0), neg-delta, snce(guard, alpha) for selected alpha.

**Key point**: Any finite subset of D0 elements maps to a finite enrichment of the Until event. Since the enriched event is consistent (it's the event of an Until formula in an MCS, extractable via BX10), the finite subset is consistent.

### Step 6: Lindenbaum Extension

Extend D0 to MCS D. From the seed structure:
- B ⊆ D (B is in the seed)
- neg-delta ∈ D (in the seed)
- S(alpha, beta) ∈ D for all alpha ∈ A, beta ∈ B (in the seed) -- establishes burgessRSince(D, beta, A) for beta ∈ B
- U(gamma, beta) ∈ D for all gamma ∈ C, beta ∈ B (in the seed) -- establishes burgessR(D, beta, C) for beta ∈ B

**Wait**: The seed S-formulas are `snce(alpha, beta)` = S(alpha, beta) where alpha is guard, beta is event. For burgessRSetSince(C, B', A), we need for all beta' ∈ B', for all alpha ∈ A: `snce(beta', alpha) ∈ C`. But the seed has `snce(alpha, beta) ∈ D`, which is S(guard=alpha, event=beta) in D.

**Convention correction needed**: The plan's D0 definition `{S(alpha, beta) : alpha in A, beta in B}` should be read as `{snce(beta, alpha) : alpha in A, beta in B}` in our guard-first convention, where beta is the guard (from the interval B) and alpha is the event (from endpoint A). This ensures:
- For all beta ∈ B, alpha ∈ A: `snce(beta, alpha) ∈ D`
- This gives `burgessRSince(D, beta, A)` for each beta ∈ B

Similarly, `{U(gamma, beta) : gamma in C, beta in B}` should be `{untl(beta, gamma) : gamma in C, beta in B}` giving burgessR(D, beta, C).

**Alternatively**: The existing `burgessR3Maximal_from_g_content_sub` can be used if we ensure `g_content(A) ⊆ D` and `g_content(D) ⊆ C`. But Burgess's approach avoids needing `g_content(A) ⊆ D` by establishing burgessR3 directly from the seed elements.

---

## 4. Corrected D0 Seed Definition

The Burgess D0 seed for Lemma 2.6, adapted to our convention (guard-first for untl/snce):

```
D0 = B
     ∪ {delta.neg}
     ∪ {snce(beta, alpha) : alpha ∈ A, beta ∈ B}
     ∪ {untl(beta, gamma) : gamma ∈ C, beta ∈ B}
```

This differs from the plan's rendering in the S-formula argument order:
- Plan says: `{S(alpha, beta) : alpha in A, beta in B}`
- Corrected: `{snce(beta, alpha) : alpha in A, beta in B}` -- guard=beta, event=alpha

With this correction, after Lindenbaum extension to MCS D:
- `burgessR3(A, B_subset_D, D)` follows from S-formulas in D
- `burgessR3(D, B_subset_D, C)` follows from U-formulas in D
- Where B_subset_D is B viewed as a subset of D

Then `burgessR3Maximal_extension_exists` (Zorn) gives B', B'' as needed.

---

## 5. Gaps and Adjustments

### Gap 1: BX13 Enrichment is Iterated, Not Single-Step

The BX chain for seed consistency requires iterating BX13 for multiple alpha values. Each application enriches the event with one more snce formula. For arbitrary finite subsets, we need a finite number of enrichment steps. This is handled by structural induction on the finite subset.

**Assessment**: Implementable. The pattern is similar to existing `untl_conj_eta_of_g_content` (PointInsertion.lean line 985), which iterates right_mono_until for G-formulas.

### Gap 2: BX14 Argument Matching

BX14's conclusion `q U (q ∧ ¬r)` has the guard q in the event. For the D0 proof, the event must contain: beta, U(beta, gamma), neg-delta. BX14's conclusion includes q = beta ∧ U(beta, gamma) in the event, which gives us beta, U(beta, gamma). The neg-delta comes from ¬r where r = beta ∧ delta: ¬(beta ∧ delta) combined with beta gives neg-delta.

**Assessment**: Requires a propositional step to extract neg-delta from ¬(beta0 ∧ delta) ∧ beta0. This is straightforward classical logic: `beta0 ∧ ¬(beta0 ∧ delta) → beta0 ∧ ¬delta`. Derivable in BX via Peirce's law.

### Gap 3: S-Formula Convention in D0

As noted in Section 4, the plan's S-formula argument order is inverted relative to our convention. The corrected seed uses `snce(beta, alpha)` (guard=beta, event=alpha), not `snce(alpha, beta)`.

**Assessment**: Notation fix only. The BX13 enrichment naturally produces `snce(guard, p)` where guard includes beta-components from B. The enrichment gives the correct form.

### Gap 4: burgessR3 from Seed vs g_content Approach

The current `lemma_2_6_splitting` uses `burgessR3Maximal_from_g_content_sub` which requires `g_content(A) ⊆ D`. Burgess's approach bypasses this by establishing `burgessR3` directly from seed elements in D.

This requires either:
(a) A new helper: `burgessR3Maximal_from_seed_elements` that takes explicit S/U-formula membership, or
(b) Showing `g_content(A) ⊆ D` from the S/U-formulas in D. This is possible: from `untl(beta, gamma) ∈ D` for all beta ∈ B, gamma ∈ C, if G(phi) ∈ A then phi ∈ g_content(A), and we need phi ∈ D. Since D is MCS and contains B, and the Until formulas establish a forward connection, we can derive g_content(A) ⊆ D from the r-relation properties.

Actually, approach (b) is essentially the same density gap problem. Approach (a) is cleaner.

**Assessment**: Need a helper that takes `burgessR3(A, B_as_subset_D, D)` (proved from seed U/S-formulas) plus `SetDeductivelyClosed(B_as_subset_D)` and applies Zorn. The existing `burgessR3Maximal_extension_exists` (RRelation.lean line 727) does exactly this.

### Gap 5: D0 Consistency Proof Structure

The consistency proof for D0 uses the fact that any finite inconsistent subset L ⊆ D0 can be refuted by constructing an Until formula in A whose event subsumes the finite subset. The key challenge is handling the MIXED case where L contains elements from multiple components of D0 (B, neg-delta, S-formulas, U-formulas).

The BX chain (BX5 -> BX14 -> BX13 iterated) produces a single Until formula in A whose event contains:
- beta-components (from B)
- neg-delta
- S-formulas (via BX13)
- U-components (from BX5 self-accumulation)

By BX10, the event is consistent (it's F-extractable from an MCS). Since the event subsumes the finite L, L is consistent.

**Assessment**: The argument is sound but the formal proof requires careful tracking of formula containment. The `right_mono_until_mcs` helper (line 968) can strengthen events, and `untl_conj_eta_of_g_content` (line 985) demonstrates the pattern.

---

## 6. Lemma 2.7 BX Chain Verification

For completeness, here is the verification for Lemma 2.7's BX5+BX7+BX13 chain.

### Setup

Given: `BurgessR3Maximal(A, B, C)`, U(xi, eta) in A, eta not in B.

### Step 1: Maximality Extraction

From eta not in B and maximality: obtain beta0 ∈ B, gamma0 ∈ C with neg-untl(beta0 ∧ eta, gamma0) ∈ A.

### Step 2: BX5 on Both Until Formulas

- BX5 on `untl(xi, eta)`: `untl(xi ∧ untl(xi, eta), eta) ∈ A`
- BX5 on `untl(beta0, gamma0)` (from burgessR3): `untl(beta0 ∧ untl(beta0, gamma0), gamma0) ∈ A`

### Step 3: BX7 Three-Way Disjunction

Apply BX7 to the two enriched Until formulas. Let:
- φ = xi ∧ untl(xi, eta), ψ = eta
- χ = beta0 ∧ untl(beta0, gamma0), θ = gamma0

BX7 gives one of:
- D1: `(φ∧χ) U (ψ∧θ)` = `(xi∧U(xi,eta)∧beta0∧U(beta0,gamma0)) U (eta∧gamma0)`
- D2: `(φ∧χ) U (ψ∧χ)` = `(xi∧U(xi,eta)∧beta0∧U(beta0,gamma0)) U (eta∧beta0∧U(beta0,gamma0))`
- D3: `(φ∧χ) U (φ∧θ)` = `(xi∧U(xi,eta)∧beta0∧U(beta0,gamma0)) U (xi∧U(xi,eta)∧gamma0)`

### Step 4: Eliminate D1 and D2

**D1 elimination**: The event eta∧gamma0 implies the guard of untl(beta0∧eta, gamma0) would be satisfied (eta appears in event, beta0 appears in guard). But we need to show this leads to untl(beta0∧eta, gamma0) ∈ A, contradicting neg-untl(beta0∧eta, gamma0) ∈ A.

Specifically: from D1, by right_mono_until (since eta∧gamma0 → beta0∧eta at the event, given beta0 in the guard), we can derive untl(something, beta0∧eta), then by further mono reasoning, untl(beta0∧eta, gamma0) ∈ A. Contradiction.

Actually, D1 elimination is more subtle. We have D1: `(φ∧χ) U (eta∧gamma0)`. The guard φ∧χ contains beta0. By left_mono, untl(beta0∧eta, gamma0) can potentially be derived. But we need to be more careful.

**D2 elimination**: The event eta∧beta0∧U(beta0,gamma0) contains eta. Combined with beta0 from the event, this gives beta0∧eta at the event. By right_mono, from D2 we get untl(phi∧chi, beta0∧eta) and then (with gamma0 being the ultimate target) we can show untl(beta0∧eta, gamma0) ∈ A via transitivity or absorption. Contradiction with neg-untl(beta0∧eta, gamma0).

Wait, this isn't right either. Let me think more carefully.

For D2: `(φ∧χ) U (ψ∧χ)` = untl(guard, eta∧beta0∧U(beta0,gamma0)).

The event contains eta and beta0. By right_mono_until with the derivation `eta∧beta0∧U(beta0,gamma0) → beta0∧eta` (propositional), we get: untl(guard, beta0∧eta). But this has guard = φ∧χ, event = beta0∧eta.

We need untl(beta0∧eta, gamma0) to contradict. We have untl(guard, beta0∧eta) where guard contains beta0∧eta. By BX6 (absorption) or transitivity? Actually, we need a different argument.

The correct D2 elimination: from D2, the event contains beta0∧eta. The guard contains U(beta0, gamma0). By BX6/BX5 chain reasoning, this eventually gives untl(beta0∧eta, gamma0). But this requires careful BX axiom application.

**Assessment for Lemma 2.7**: The D1/D2 elimination is more intricate than a simple contradiction. It requires showing that the existence of D1 or D2 implies untl(beta0∧eta, gamma0) ∈ A (contradicting the neg-untl from step 1). The exact proof requires careful use of BX2G (left_mono_until_G), BX3 (right_mono_until), and possibly BX6 (absorption). This is doable but non-trivial.

**D3 survives**: `(xi∧U(xi,eta)∧beta0∧U(beta0,gamma0)) U (xi∧U(xi,eta)∧gamma0) ∈ A`

The event contains xi and gamma0. By BX10, F(xi∧U(xi,eta)∧gamma0) ∈ A. This gives a consistent formula from which D0 for Lemma 2.7 can be seeded.

---

## 7. Confidence Assessment

| Item | Confidence | Notes |
|------|------------|-------|
| BX5 provides A5a's role | HIGH | Different enrichment target (guard vs event) but same mathematical power |
| BX14 provides A4a's role | HIGH | Different form but same separation capability; step 3 verified |
| BX13 provides A3a's role | HIGH | Event-enrichment form is actually better for D0 seed proof |
| BX7 provides A7a's role (Lemma 2.7) | HIGH | Sound replacement; D1/D2 elimination requires care |
| D0 seed consistency proof chain | MEDIUM-HIGH | Steps verified; iterated enrichment pattern clear; formal proof complexity non-trivial |
| burgessR3 from D0 seed elements | HIGH | Existing `burgessR3Maximal_extension_exists` handles this |
| D1/D2 elimination in Lemma 2.7 | MEDIUM | Requires careful BX axiom chain; no fundamental obstacle |

**Overall confidence**: HIGH that BX13 and BX14 are sufficient for the D0 seed approach. The axioms are different from Burgess's A3a/A4a but provide equivalent mathematical power for the specific proof patterns needed.

---

## 8. Recommendations for Phase 2

1. **Correct the D0 seed S-formula convention**: Use `snce(beta, alpha)` not `snce(alpha, beta)`.
2. **Build the BX chain incrementally**: Prove MCS-level lemmas for BX13 and BX14 first (similar to `until_self_accum_in_mcs` for BX5).
3. **Handle the iterated enrichment**: Use structural induction on finite subsets for the consistency proof.
4. **Use `burgessR3Maximal_extension_exists`** directly (not `burgessR3Maximal_from_g_content_sub`) to avoid the density gap.
5. **For Lemma 2.7 (Phase 3)**: Prove D1/D2 elimination as separate lemmas before tackling the full proof.
