# Teammate D (Round 3) Findings: Burgess Alignment and Guard Semantics

**Task**: 117 — Investigate Burgess alignment and guard semantics on discrete domains for X ≅ ℤ embedding
**Date**: 2026-05-08

## Key Findings

### 1. Burgess's Truth Lemma on Non-Dense Domains

Burgess's Claim 2.11 (p. 373-374) proves (+) by induction on formula complexity. The Until case:

**Forward** (U(β,γ) ∈ f(x) → x ∈ V(U(β,γ))):
- C5a gives y ∈ X with x < y, γ ∈ f(y), β ∈ g(x,y)
- For any z ∈ X with x < z < y: C3 gives g(x,y) ⊆ f(z), hence β ∈ f(z)
- By IH: y ∈ V(γ) and z ∈ V(β) for all z between x and y in X

**Backward** (¬U(β,γ) ∈ f(x) → x ∉ V(U(β,γ))):
- For any y ∈ X with x < y and γ ∈ f(y) (by IH from y ∈ V(γ)):
- C4a gives z ∈ X with x < z < y and ¬β ∈ f(z)
- By IH: z ∉ V(β), so the guard fails

**Critical observation**: Burgess quantifies "for any z ∈ X" — over the domain X, NOT over all rationals. On a discrete domain, when x and y are adjacent in X (no z ∈ X between them), the guard `∀ z ∈ X, x < z < y → β ∈ f(z)` is vacuously true. The Until semantics V(U(β,γ)) at x requires ∃ y ∈ X with x < y, γ at y, and β at all intermediate X-points. On a discrete domain, if y is the immediate successor of x, there are no intermediate points and the guard is trivially satisfied.

**This is semantically correct**: on a discrete order, U(β,γ) at x with witness at the immediate successor x' means γ at x' with no guard obligations — matching the next-step operator X(γ) = ⊥ U γ.

### 2. Guard Semantics on ℤ vs ℚ in the Formalization

The `truth_at` definition (Truth.lean:127-128) quantifies over ALL of D:
```
∀ r : D, t < r → r < s → truth_at ... r φ
```

On ℤ (D = Int): between consecutive integers n and n+1, there are NO integers r with n < r < n+1, so the guard is vacuously true. Between n and n+2, there is exactly r = n+1.

This matches Burgess's semantics perfectly. The formalization's guard quantifies over the same domain D that the rest of the truth evaluation uses. On ℤ, this is finite (and often empty) between consecutive points. On ℚ, it's dense.

**No hidden density assumptions in the truth lemma**: I verified that `RestrictedParametricTruthLemma.lean` requires only `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]` (line 37). There is NO `DenselyOrdered` constraint. The truth lemma works on ANY such D, including ℤ.

**Confirmed in ParametricRepresentation.lean** (lines 28-29, 40, 66-68): the header documentation explicitly states "Base: Instantiate with D = Int" and "Base completeness uses D = Int parametrically."

### 3. C4a and Domain Discreteness

**Does C4a create density cascades?** No.

Burgess's Lemma 2.9 (C4a elimination) inserts z between x and y when ¬U(γ,δ) ∈ f(x) and γ ∈ f(y). After insertion, (x,z) and (z,y) are new adjacent pairs. Could these generate NEW C4a counterexamples?

Yes, but with bounded depth. A C4a counterexample at (x,y) requires a specific formula pair (γ,δ) from f(x). The subformula closure is finite, so only finitely many distinct formula pairs can trigger C4a at any given pair. Each C4a insertion handles one formula pair. After inserting z between x and y:
- The pair (x,z) may have at most |subformulas| C4a counterexamples
- The pair (z,y) similarly
- But each insertion RESOLVES one counterexample permanently

The domain grows by at most one point per counterexample elimination step. Since each step processes one counterexample from a countable enumeration (counterexample_enum), and each domain point pair has finitely many potential C4a counterexamples (bounded by the subformula closure), the limit domain X has countably many points.

**Key point**: C4a inserts finitely many points between any original pair. It does NOT densify the domain. Between any two original domain points, only finitely many new points are inserted (one per formula-pair counterexample). The limit domain has the structure of ℤ (or more precisely, a countable linear order without endpoints where every pair has finitely many points between them).

**Why the density case is separate**: The `.density` kind in `PotentialCounterexampleKind` (CE:575) is NOT part of C4a. It's a separate counterexample type that inserts midpoints between ALL adjacent pairs, regardless of formula content. This is needed ONLY for the dense variant (F'⊤ axiom). For the base logic, removing the `.density` case leaves C4a and C5a counterexample elimination, which produces a discrete domain.

### 4. Restricted Coherence on Discrete Domains

The three restricted coherence conditions (TemporalCoherence.lean:295, 535, 565) are:

**restricted_temporally_coherent**: F(φ) ∈ fam.mcs t → ∃ s > t, φ ∈ fam.mcs s
- On ℤ: this gives a witness at some integer s > t. Works identically to ℚ — just quantifies over ℤ instead.

**restricted_forward_until_since_coherent**: U(φ,ψ) ∈ fam.mcs t → ∃ s > t, φ ∈ fam.mcs s ∧ ∀ r, t < r < s → ψ ∈ fam.mcs r
- On ℤ: the witness s could be t+1 (immediate successor) with guard vacuously true, or s = t+k with guard covering t+1,...,t+k-1.
- **No density assumption**: the guard is just a universal quantifier over D, which on ℤ is finite.

**restricted_backward_until_since_coherent**: Given semantic Until witness pattern, derive syntactic membership.
- On ℤ: the backward direction uses C4a to find guard-failing points. Since C4a counterexamples have been eliminated, the guard holds at all intermediate domain points. On ℤ, the intermediate points are finitely many — the proof is identical.

**None of these definitions or proofs assume density.** They work on any `[Preorder D]` (TemporalCoherence.lean uses only Preorder).

### 5. limit_g on a Discrete Domain

`limit_g` (ChronicleConstruction.lean:884-887):
```lean
fun x z => { φ | ∀ y ∈ limit_dom A h_mcs, x < y → y < z → φ ∈ limit_f A h_mcs y }
```

**Adjacent pairs (x immediately precedes z in limit_dom)**: No y ∈ limit_dom with x < y < z, so limit_g(x,z) = Set.univ. This is semantically correct: g(x,z) captures what's true throughout the interval (x,z), and when the interval is empty, everything is vacuously true.

**Non-adjacent pairs**: limit_g(x,z) = ∩{limit_f(y) | x < y < z, y ∈ limit_dom} — the intersection of MCS values at intermediate points.

**SetConsistent uses outside the density case**:
- CE:1026, 1607, 2105, 2631: Comments explicitly say "use lemma_2_8 (avoids needing SetConsistent g)" — these C4a/C5a cases intentionally bypass the SetConsistent requirement
- CE:245: `BurgessR3Maximal_bot_not_mem` takes `SetConsistent B` as a parameter — but this is only CALLED from the density case (CE:3561-3570)
- CE:3539-3570: The ONLY place in the entire Chronicle module where `SetConsistent (χ.g pc.x pc.y)` is needed — the density case with the sorry

**Conclusion**: Removing the density case (`.density` in PotentialCounterexampleKind) eliminates the ONLY code path that requires `SetConsistent` on g-values. All C4a/C5a cases explicitly use `lemma_2_8`/`lemma_2_8_since` which avoids needing SetConsistent g. This is noted in four separate comments in CE.

### 6. Burgess Section 1.6 Variants

From Burgess (p. 369):

| Postulate | Axiom |
|-----------|-------|
| Density | F'⊤ |
| Discreteness | G'⊥ ∧ H'⊥ |

For the **base logic** (no extra axioms): Burgess proves completeness over ALL linear orders (𝒱₀). The construction produces a countable subset X ⊂ ℚ. Since C4a/C5a only insert finitely many points between any original pair, the limit X is discrete.

For the **dense variant**: Add F'⊤ axiom and density counterexample elimination. This ensures between any two domain points there's always another, making X dense. Then X ≅ ℚ by Cantor's theorem.

For the **discrete variant**: Add G'⊥ ∧ H'⊥. The base construction already produces a discrete X. The discreteness axioms ensure the discrete next/previous operators are meaningful.

**Confirmation**: For the base logic, the limit domain is discrete (ℤ-like). The existing parametric infrastructure already supports D = Int (ParametricRepresentation.lean:28, 66). The Cantor iso is only needed for the dense variant.

## Gaps and Risks

### Embedding X ≅ ℤ

The limit domain X is a countable discrete linear order without endpoints. Such an order is order-isomorphic to ℤ by the classical back-and-forth characterization theorem. However:

1. **Is X actually always discrete?** It should be if we remove the density case. But C4a DOES insert midpoints (z = (x+y)/2). After C4a resolves a counterexample between x and y by inserting z, the pair (x,z) is now adjacent. Future C4a counterexamples at (x,z) may insert another midpoint w = (x+z)/4. Could this create accumulation points in the limit?

   **Answer**: No. Each C4a insertion resolves one specific formula-pair counterexample. The subformula closure is finite (say size N). Between any original adjacent pair (x,y), at most N C4a counterexamples can be triggered. Each inserts one point. So between x and y, at most N points are inserted, and each sub-interval again has at most N potential counterexamples, giving at most N² points at depth 2, etc. But the counterexample_enum processes them in a fair enumeration — each counterexample is processed at most once. After processing, it's no longer a counterexample. So the total number of insertions between any original pair is bounded by the number of counterexample tuples involving those coordinates, which is finite (countable enumeration processed fairly).

   **However**: The limit could still have accumulation points. Consider: x=0, y=1. Insert z₁=0.5 (C4a). Then insert z₂=0.25 (C4a at (0, 0.5)). Then z₃=0.125, etc. The sequence 0, 0.125, 0.25, 0.5, 1 has x=0 as an accumulation point from the right. But this is a sequence of rational midpoints that converges to 0. Since 0 ∈ X, this means 0 has no immediate successor in X — the domain is not discrete at 0.

   **This is a real concern**. If C4a cascades produce arbitrarily fine subdivisions at certain points, those points may lose their immediate successors, making X non-discrete.

2. **Mitigation**: Burgess's construction processes counterexamples via a fair enumeration. At each finite stage, dom f_n is finite, so there ARE immediate successors. But in the limit, accumulation could occur. The question is whether the specific C4a insertion pattern (which depends on formula content) always terminates at finite depth.

   For the **base logic without density**: a C4a counterexample at (x,y) requires ¬U(γ,δ) ∈ f(x) AND γ ∈ f(y). After inserting z with ¬δ ∈ f(z), the counterexample at (x,y) is resolved. New counterexamples at (x,z) or (z,y) require DIFFERENT formula pairs. Since the subformula closure is finite, only finitely many rounds of splitting can occur at any pair.

   But here's the issue: C5a also inserts points. C5a for U(ξ,η) ∈ f(x) inserts y after x. Then C4a might insert between x and y, then C5a might insert after y, etc. The interaction between C4a and C5a creates a complex insertion pattern.

   **Nevertheless**: the key fact is that each insertion resolves one counterexample, and the counterexample enumeration is fair. In the limit, EVERY counterexample is resolved. The order structure of X depends on the specific formula content of the MCSs, but X is always a countable linear order without endpoints (by C5a for seriality).

### Is X ≅ ℤ Always True?

**No, not necessarily.** A countable linear order without endpoints that is NOT dense need not be isomorphic to ℤ. For example, ℤ + ℤ (two copies of integers with the first copy before the second) is a countable linear order without endpoints, is not dense, but is not isomorphic to ℤ (it has a "gap" between the two copies where every element of the first is less than every element of the second, but there are infinitely many elements on each side — this is not a gap in the order sense but rather a partition into two infinite parts with no element in between... actually wait, that IS ℤ + ℤ which is different from ℤ).

Actually, ℤ + ℤ has the property that there exist elements a, b with a < b such that {c : a < c < b} is infinite. In ℤ, for any a < b, the set {c : a < c < b} is finite. So ℤ + ℤ ≇ ℤ.

**Could X have the ℤ + ℤ structure?** Possibly, if C5a insertions create two "clusters" of points separated by a gap that C4a never fills. For example, if no C4a counterexample triggers between two distant domain points, and C5a keeps inserting successors within each cluster.

**However**: For the X ≅ ℤ claim to work, we need X to have the property that between any two domain points, there are finitely many others. This IS guaranteed by the chronicle construction: at each finite stage, dom f_n is finite. In the limit, between any two points x, y ∈ X, there are at most countably many points. But are there finitely many?

Actually, YES. Here's why: x ∈ dom f_{n_x} and y ∈ dom f_{n_y}. Let N = max(n_x, n_y). At stage N, both x and y are in dom f_N, and the set {z ∈ dom f_N : x < z < y} is finite. At each subsequent stage, at most one new point is inserted (the elimination of one counterexample). So at stage N + k, at most k new points have been inserted globally. The number of points between x and y at stage N + k is at most |{z ∈ dom f_N : x < z < y}| + k. In the limit, this is ω (countably infinite).

**Wait** — that shows the set could be countably infinite between x and y. So X might NOT be discrete. If infinitely many C4a/C5a insertions land between x and y, the interval could accumulate.

**Resolution**: The critical question is whether C4a/C5a insertions between two fixed points x and y eventually stop. For C4a: counterexamples are indexed by formula pairs from the finite subformula closure. After each formula pair is resolved, it stays resolved (the elimination doesn't create new counterexamples for the same formula pair — Burgess proves this). So at most |subformula_closure|² C4a insertions between x and y. But C5a can insert a witness y' > x, and then C4a can insert between x and y', and C5a can insert between y' and something further... In principle, the interval (x, original_y) could receive infinitely many insertions.

**Conclusion on discreteness**: The claim "X is always discrete" needs more careful analysis. X might have accumulation points from cascading C4a/C5a insertions. However, even if X is not discrete, it IS a countable linear order without endpoints. The key question for the embedding is:

1. If X is discrete → X ≅ ℤ → embed into ℤ
2. If X is dense → X ≅ ℚ → embed into ℚ (Cantor, but needs DenselyOrdered)
3. If X is neither discrete nor dense → X embeds order-preservingly into ℚ (every countable linear order embeds into ℚ), but is X ≅ ℤ?

For case 3: Any countable linear order embeds order-preservingly into ℚ (Cantor's theorem variant — every countable linear order is a sub-order of ℚ). So X ↪ ℚ is always possible. But we need ≅ (bijection) to use ℚ or ℤ as D. Alternatively, we need an order-preserving bijection from X to some AddCommGroup.

**Actually**, the formalization doesn't need X ≅ ℤ. It needs to build BFMCS over some D with AddCommGroup and produce a TaskFrame model. The current approach uses D = Rat and the Cantor iso X ≅ Rat (which requires DenselyOrdered X). The proposed approach uses D = Int.

But to use D = Int, we need to build FMCS/BFMCS over Int. The FMCS requires `mcs : D → Set Formula` — a function from ALL of D to formula sets. Currently, `cantor_f : Rat → Set Formula` assigns every rational a formula set via the Cantor iso. For D = Int, we'd need `int_f : Int → Set Formula`.

If X ≅ ℤ, then the iso gives us `int_f(n) = limit_f(iso(n))`. If X is not isomorphic to ℤ, we can still define `int_f` by embedding X into ℤ (not necessarily surjectively) and extending to all of ℤ. But then non-image integers get assigned arbitrary MCS values, and coherence proofs need to work for those too.

This is analogous to the current situation with Rat: the Cantor iso X ≅ Rat is a BIJECTION, so every rational is an image point. Without a bijection, some D-points are "gaps" that need MCS values assigned by extension.

## Summary

**Guard semantics work correctly on discrete domains**: vacuous guards for adjacent pairs, finite conjunctions for non-adjacent pairs. No density assumptions in the truth lemma or coherence conditions.

**The density case in CE is cleanly separable**: only the `.density` branch (CE:3535-3604) uses SetConsistent on g-values. All C4a/C5a branches explicitly use lemma_2_8 which avoids SetConsistent.

**The discreteness claim needs refinement**: while each finite stage is discrete, the limit domain X may not be strictly discrete (ℤ-isomorphic) due to cascading C4a/C5a insertions. However:
- X is always a countable linear order without endpoints
- X always embeds order-preservingly into ℚ (any countable linear order does)
- The ParametricRepresentation already supports D = Int (documented at lines 28, 40, 66-68)
- If X ≅ ℤ fails, we can still embed X ↪ ℤ non-surjectively and extend the FMCS, or embed X ↪ ℚ without needing density (using any order-preserving injection, not necessarily a Cantor iso)

**Confirmed: no hidden density assumptions** in RestrictedParametricTruthLemma, ParametricRepresentation, or TemporalCoherence. The Cantor iso (and hence DenselyOrdered) is used ONLY in ChronicleToCountermodel.lean for the specific embedding X → Rat.

## Confidence Level

**HIGH** on: guard semantics correctness on ℤ, separability of density case, no density assumptions in truth lemma/coherence.

**MEDIUM** on: X ≅ ℤ claim. The limit domain might not be strictly discrete. The embedding strategy needs to handle the general case (X is countable without endpoints, possibly with accumulation points from C4a cascades).
