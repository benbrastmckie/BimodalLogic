# Teammate D Findings: Alternative Completeness Strategies in the Literature

**Task**: 107 — Burgess chronicle construction for BX representation theorem
**Focus**: Reynolds 1992, Venema 1993, and Hodkinson-Reynolds 2006 for alternative approaches
**Date**: 2026-04-28

## Key Findings

### 1. All Papers Use Strict (Open Guard) Semantics — This Is Standard

Every paper in the literature directory uses the **same strict Until/Since semantics** we now have after task 113:

- **Burgess 1982** (§1.2): `U(α,β)` at x iff ∃y > x with α(y) and ∀z with x < z < y: β(z). Open interval (x,y). No requirement that β hold at x itself.
- **Xu 1988** (§1, clause iv): Identical — `t < t'` strictly, guard on open interval `t < t'' < t'`.
- **Reynolds 1992** (§2): `U(A,B)` at t iff ∃s > t with A(s) and ∀u: t < u < s → B(u). Explicitly strict.
- **Venema 1993** (§2.2): Same strict semantics.

**This is critical**: The entire literature works with open guard. The "closed guard" convention that our codebase used before task 113 was non-standard. The B_sub_A property was an artifact of the closed guard convention, not something the original proofs ever relied on.

**Confidence**: HIGH.

### 2. Burgess's Proof Does NOT Need B_sub_A — It Never Existed

Re-reading Burgess 1982 §2.3 carefully:

Burgess defines `r(A, β, C)` to mean: for all γ ∈ C, U(γ, β) ∈ A. This is exactly our `burgessR(A, β, C)`.

He defines `r(A, B, C)` to mean: B is a DCS and r(A, β, C) for all β ∈ B. This is our `burgessR3(A, B, C)` (with B being a DCS, not necessarily MCS).

He defines `R(A, B, C)` to mean: r(A, B, C) holds and B is maximal with this property. This is our `BurgessR3Maximal(A, B, C)`.

**Nowhere in Burgess's proof does "β ∈ B implies β ∈ A" appear.** The property was never part of the construction. What Burgess uses instead:

- **Lemma 2.3** establishes duality: r(A, β, C) iff S(α, β) ∈ C for all α ∈ A. The DCS B serves as the "interval content" between two endpoint MCSs, and elements of B live in the interval — they need not belong to either endpoint.

- **Lemma 2.6** (consistency of D0): Uses A4a and A5a to construct the seed set. The proof at no point assumes B ⊆ A. Instead, it uses the **maximality of R(A,B,C)**: since δ ∉ B, there exist β₀ ∈ B and γ₀ ∈ C with ¬U(γ₀, β₀ ∧ δ) ∈ A.

Let me trace Burgess's Lemma 2.6 consistency argument in detail:

**Goal**: Given R(A, B, C) and δ ∉ B, show that D₀ = {S(α,β) : α∈A, β∈B} ∪ B ∪ {¬δ} ∪ {U(γ,β) : γ∈C, β∈B} is consistent.

**Proof**: It suffices to show each formula ζ = S(α,β) ∧ β ∧ ¬δ ∧ U(γ,β) is consistent for α∈A, β∈B, γ∈C.

Since δ ∉ B and R(A,B,C), there exist β₀∈B, γ₀∈C with ¬U(γ₀, β₀∧δ) ∈ A. WLOG β₀ = β, γ₀ = γ.

From r(A,B,C): U(γ,β) ∈ A. By A5a: U(γ, β∧U(γ,β)) ∈ A. Combined with ¬U(γ, β∧δ) ∈ A, by A4a: U(β∧U(γ,β)∧¬δ, β) ∈ A. By A3a: U(β∧U(γ,β)∧¬δ∧S(α,β), β) ∈ A. By §2.2 (consistency criterion): ζ is consistent.

**The entire argument uses only:**
- Maximality of B (to get the ¬U(γ₀, β₀∧δ) formula)
- A4a (linearity of Until), A5a (self-accumulation), A3a (interaction), A6a (absorption)
- The consistency criterion (§2.2)

**None of these require B ⊆ A.** The B_sub_A property was a codebase artifact, not a mathematical necessity.

**Confidence**: HIGH — this is directly from the paper.

### 3. Xu's Simplification: What Changed from Burgess

Xu 1988 simplifies Burgess's axiom system. The key results:

- **Xu's Sigma4** = axioms (7)-(11) + their duals = our BX axiom system (after task 113).
- **Xu's Theorem 3.3**: Sigma4 is complete for the class of all linear frames.
- **Xu's key lemma 3.2.1**: Given R(A,B,C), we have (i) for β∈B and γ∈C: U(γ,β)∈B, and (ii) for β∈B and α∈A: S(α,β)∈B. This is the **closure property** of B — the interval DCS is closed under forming Until/Since formulas with the endpoints.

This is exactly what our codebase calls `burgessR3_absorption` (or should). Xu's Lemma 3.2.1 uses axiom (7) (= BX5, self_accum_until). The proof: if U(γ,β) ∉ B for some β∈B, γ∈C, then by maximality there exist β'∈B, γ'∈C with ¬U(γ', β'∧U(γ,β)) ∈ A. But axiom (7) gives U(γ'', β''∧U(γ'',β'')) → U(γ', β'∧U(γ,β)), contradicting ¬U(γ'',β'') ∈ A since β''∈B, γ''∈C.

**Key for task 107**: Xu's 3.2.1 is the property that lets the C5 counterexample lemma (our Lemma 2.10) go through. It means the g-value (= B) is closed under forming Until formulas with the endpoint content. This is load-bearing for the guard propagation.

**Xu's 3.2.2** (= Burgess's 2.6 for linear frames): The C4 counterexample lemma, adapted for the linear case. The proof proceeds by induction on the number of intermediate points. In the base case (n=0), apply 3.2.2 directly. In the induction step (n=m+1), find the successor x' of x. If ¬U(γ,β) ∈ f(x'), reduce to n=m. If U(γ,β) ∈ f(x'), then β∧U(γ,β) ∈ f(x') (else x,y,γ,β wouldn't be a counterexample). By axiom (9) (= BX6, absorption): ¬U(β∧U(γ,β), β) ∈ f(x). Reduce to n=0 with γ' = β∧U(γ,β), y' = x'.

**This is exactly our nested bridging case!** And the proof uses axiom (9) = BX6 (absorb_until), NOT BX9 (until_elim). Let me re-read this carefully...

Actually wait — Burgess's Lemma 2.9 case n=m+1 says: "If U(γ,δ) ∈ f(x'), note first that we must have δ ∈ f(x')". But under open guard, does U(γ,δ) at x' guarantee δ at x'? No! Under open guard, U(γ,δ) at x' means the guard δ holds on the open interval (x', s) for some s. It does NOT mean δ holds at x' itself.

Hmm, but in Burgess's construction, he says "else x,y,γ,δ would not be a counterexample." Let me re-read: the counterexample is ¬U(γ,δ) ∈ f(x) and γ ∈ f(y), and no z between x and y has ¬δ ∈ f(z). At x' (which is between x and y), if ¬δ ∈ f(x'), we have our counterexample resolver. If δ ∈ f(x'), that's fine. But Burgess says "we must have δ ∈ f(x')" — this follows from the fact that x' is between x and y and no point between them has ¬δ. Since f(x') is an MCS, either δ ∈ f(x') or ¬δ ∈ f(x'). If ¬δ ∈ f(x'), then x' itself is the counterexample resolver, contradicting our assumption. So δ ∈ f(x') follows.

Then he says: "Let γ' = δ ∧ U(γ,δ) ∈ f(x')." But this assumes U(γ,δ) ∈ f(x'). Since x' is between x and y with δ ∈ f(x'), and since no point between x and y lacks δ... wait, that doesn't give us U(γ,δ) ∈ f(x').

Let me re-read Burgess more carefully. In his case n=m+1:
1. x' immediately succeeds x in dom f
2. "If ¬U(γ,δ) ∈ f(x'), we can reduce to case n=m by replacing x by x'." — This is clear.
3. "If U(γ,δ) ∈ f(x'), note first that we must have δ ∈ f(x'), else x,y,γ,δ would not be a counterexample."

Wait — this says δ ∈ f(x'), not δ ∈ g(x,x'). The counterexample for C4a is: ¬U(γ,δ) ∈ f(x), γ ∈ f(y), and NO z between x and y has ¬δ ∈ f(z). So for x' between x and y, we need δ ∈ f(x') (otherwise ¬δ ∈ f(x') and x' would resolve the counterexample, contradicting that it IS a counterexample).

OK so δ ∈ f(x') is correct. And U(γ,δ) ∈ f(x') (from the "If U(γ,δ) ∈ f(x')" branch). So γ' = δ ∧ U(γ,δ) ∈ f(x'). Now "using A3a" (which is BX3, the interaction axiom): from ¬U(γ,δ) ∈ f(x), we get...

Actually, Burgess uses A6a = our absorption axiom: U(q ∧ U(p,q), q) → U(p,q). Taking the contrapositive: ¬U(p,q) → ¬U(q ∧ U(p,q), q). So ¬U(γ,δ) ∈ f(x) gives ¬U(δ ∧ U(γ,δ), δ) ∈ f(x), i.e., ¬U(γ', δ) ∈ f(x). Since γ' ∈ f(x'), we now have a C4a counterexample with (x, x', γ', δ) and n=0 intermediate points.

**This is the nested case resolved WITHOUT BX9!** The key is axiom A6a (= BX6, absorb_until), not BX9. The absorption axiom lets us "push" the nested formula into the event position.

So the proof works as follows:
- Have: ¬U(γ,δ) ∈ f(x), U(γ,δ) ∈ f(x'), δ ∈ f(x'), γ ∈ f(y)
- Set γ' = δ ∧ U(γ,δ)
- By A6a contrapositive: ¬U(γ', δ) ∈ f(x)
- Now (x, x', γ', δ) is a C4a counterexample with 0 intermediate points
- Apply the base case of the induction

**This is the fix for the nested bridging lemma.** The current codebase tries to prove "γ ∉ B" directly (the `burgessR3_gamma_not_in_B_nested` approach), but Burgess instead restructures the counterexample to avoid the nested case entirely.

**Confidence**: HIGH — this is the original proof strategy.

### 4. The C4 Elimination Should Use Induction, Not Direct Bridging

Looking at CounterexampleElimination.lean's current approach vs Burgess:

**Current codebase approach**: For a C4 counterexample (x, y, γ, δ):
- Find the rightmost w with ¬U(γ,δ) ∈ f(w)
- Look at successor w_next
- If w_next = y: use simple bridging (δ ∈ f(y), works)
- If w_next < y: need nested bridging (U(γ,δ) ∈ f(w_next), broken)

**Burgess's approach**: Induction on n = number of points between x and y:
- Base case n=0: Apply Lemma 2.6 directly to insert a point
- Induction step n=m+1: Look at the successor x' of x
  - If ¬U(γ,δ) ∈ f(x'): reduce to (x', y, γ, δ) with n=m points between
  - If U(γ,δ) ∈ f(x'): δ ∈ f(x') (forced), set γ' = δ∧U(γ,δ), use A6a to get ¬U(γ',δ) ∈ f(x), reduce to (x, x', γ', δ) with n=0 points

**The fundamental difference**: Burgess uses induction on the number of intermediate points and restructures the counterexample. The codebase uses a "find rightmost" strategy and tries to prove a separate bridging lemma. Burgess's approach avoids the nested bridging lemma entirely.

**Recommendation**: Restructure CounterexampleElimination.lean to follow Burgess's induction-based approach rather than the rightmost-point + bridging approach.

**Confidence**: HIGH.

### 5. Reynolds 1992: Not Directly Applicable

Reynolds 1992 proves completeness of U,S over the **real numbers**, not general linear orders. His approach:

1. Use Burgess-Xu to get a **rational-flowed** model (Corollary 1, §4)
2. Show this model satisfies Prior-U/Prior-S axioms and Sep
3. Use Kamp's expressive completeness to translate between temporal and first-order formulas
4. Apply Doets' theorem to get a real-flowed model

**Why it doesn't help us directly**:
- Steps 1 is exactly Burgess's construction — it's a prerequisite, not an alternative
- Steps 2-4 are about transferring from Q to R, which we don't need (our target is linear orders, not specifically R)
- Reynolds explicitly says (§4): "the more complicated U and S construction of Burgess [2] is necessary for us"

**However**: Reynolds confirms that the Burgess-Xu result gives **strong completeness** for linear frames (his Theorem 1): "Although neither Burgess nor Xu mention *strong* completeness their proofs do establish that."

**For our logic TM** (which adds S5 modal Box): Reynolds's approach doesn't address the modal component. The interaction between Box and Until/Since is handled by our BX axioms, not by Reynolds.

**Confidence**: HIGH that Reynolds is not an alternative path.

### 6. Venema 1993: Elegant But Narrower Scope

Venema proves completeness for **well-ordered** frames and for (ω, <). His approach:

1. Use Burgess's construction to get a linear model
2. Show the model is "definably well-ordered" using axiom W: Fp → U(p, ¬p)
3. Apply Doets' theorem for well-orders

**Key insight**: Venema's Lemma 4.1 shows that every BW-model is definably well-ordered, using the fact that U'(ψ,χ) ≡ ⊥ in any model satisfying W. This is because W forces: if Fχ holds, then U(¬χ, χ) holds, contradicting the gap structure that U' requires.

**Why it doesn't help us**:
- We need completeness for ALL linear orders, not just well-orders or ω
- Venema's axiom W (Fp → U(p, ¬p)) is NOT sound for dense orders
- The "definably well-ordered → well-ordered n-equivalent" step uses Doets' theorem, which is specific to well-orders

**The Venema approach is a dead end for our logic.**

**Confidence**: HIGH.

### 7. Hodkinson-Reynolds 2006: Survey Only

The available portion of the Hodkinson-Reynolds handbook chapter contains only the introduction (§1) and table of contents. The sections on axiomatization (§5.1), filtration (§5.8), and mosaics (§5.10) are not included in our PDF.

From the TOC, relevant sections would be:
- §5.1 Hilbert style axiom systems (p.696)
- §5.8 Filtration and the finite model property (p.706)
- §5.10 Mosaics (p.708)

The introduction mentions that Burgess-Xu is the standard approach for Until/Since completeness over linear orders. No alternative is suggested as simpler.

**Confidence**: LOW (limited content available).

### 8. The "Quick Win" Fragment: Box+G+H Only

Could we prove completeness for the modal-temporal fragment WITHOUT Until/Since?

For the G/H fragment over linear orders: this is classical and well-understood. Standard Henkin construction works. The interaction of Box (S5) with G/H needs the connect_future/past axioms (BX4/BX4') but should be straightforward.

**However**: The ROADMAP (line 1126) says "Only the algebraic/canonical model approach is pursued for completeness." And the 4 algebraic sorry stubs are on precisely this path. If those are fixable, we get completeness for the full language via the algebraic path.

The Box+G+H fragment completeness would NOT help with the full language unless we can lift it to Until/Since. The Kamp expressibility theorem says U/S are expressively complete over Dedekind-complete orders, but that's a semantic result — it doesn't give a syntactic proof-theoretic reduction.

**Confidence**: MEDIUM — a Box+G+H quick win exists in principle but doesn't obviously extend.

### 9. ROADMAP Dead End Assessment Post-Task-113

Reviewing dead ends that might be reassessed after the open guard transition:

| Dead End | Status Post-113 | Assessment |
|----------|----------------|------------|
| #10 FMP bridge | Still dead | Truth lemma gap unchanged by guard semantics |
| #34-36 Lindenbaum opacity | Still dead | BXCanonical path still blocked |
| #7 g_ordered | Possibly dead | g_ordered was identified as unnecessary; may be irrelevant now |
| #13 simple chain | Still dead | Simple chains can't handle Until/Since |
| #23 deterministic chain | Still dead | Deterministic construction has structural issues |
| #31 direct Henkin | Still dead | Lindenbaum opacity blocks direct approach |

**No dead end is revived by task 113's changes.** The open guard transition doesn't remove Lindenbaum opacity or truth lemma gaps — it removes certain axioms and adds the strict semantics.

**Confidence**: HIGH.

## Recommended Approach

### Primary: Follow Burgess's Proof Structure Exactly

The task 107 codebase has diverged from Burgess's original proof in two critical ways:

1. **C4 elimination uses "rightmost point + bridging" instead of Burgess's induction on intermediate points.** This is the root cause of the nested bridging problem. Restructure to use induction, and the nested case is handled by A6a (absorption) exactly as Burgess intended.

2. **D0 consistency argument assumed B_sub_A, which Burgess never uses.** The original proof uses maximality of B (the R-relation) to get the key ¬U formula, then A4a + A5a + A3a for the consistency argument. None of this requires B ⊆ A.

### Secondary: Investigate the Algebraic Path

The 4 algebraic sorry stubs (InteriorOperators.lean:83, TenseS5Algebra.lean:195/278/320) may be fixable independently and could provide a separate completeness route. This is orthogonal to the chronicle construction.

### Not Recommended: Reynolds, Venema, or Other Alternative Approaches

- Reynolds requires Burgess-Xu as a prerequisite — it's an extension, not an alternative
- Venema is limited to well-orders — not applicable to general linear frames
- No paper suggests a fundamentally simpler approach than Burgess's chronicle construction for Until/Since over linear orders

## Evidence/Examples

- Burgess 1982, §2.6 (Lemma 2.6): Full consistency argument without B_sub_A
- Burgess 1982, §2.9 (Counterexample Lemma for C4): Induction-based proof avoiding nested bridging
- Xu 1988, §3.2.1 (Lemma 3.2.1): Closure property of the interval DCS
- Xu 1988, §3.3 (Theorem 3.3): Linear frame completeness using axioms (7)-(11)
- Reynolds 1992, §4: Explicitly states Burgess construction is necessary
- Venema 1993, §4.1: Limited to well-orders via axiom W

## Confidence Level

| Finding | Confidence |
|---------|-----------|
| Open guard is standard in all papers | HIGH |
| B_sub_A never existed in Burgess/Xu | HIGH |
| Nested bridging solved by A6a + induction | HIGH |
| Reynolds/Venema not alternative paths | HIGH |
| C4 induction restructure is the correct fix | HIGH |
| D0 consistency argument works without B_sub_A | HIGH |
| Algebraic path viability | MEDIUM |
| Box+G+H fragment quick win | MEDIUM |

**Overall**: HIGH — the literature clearly shows the proof works under strict semantics without the properties that were invalidated.
