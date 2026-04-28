# Research Report: Task #107 — Literature-Based Plan Revision Analysis

**Task**: 107 - Burgess chronicle construction for BX representation theorem
**Started**: 2026-04-28T17:39:00Z
**Completed**: 2026-04-28T19:15:00Z
**Task Type**: lean4
**Domains**: logic
**Mode**: Team Research (4 teammates)

## Executive Summary

Four teammates read Burgess 1982, Xu 1988, Reynolds 1992, and Venema 1993 in detail and compared them against the Lean codebase. The results are transformative: **the 11 chronicle sorry sites are not caused by missing axioms or impossible properties — they are caused by the codebase deviating from the paper's construction in three specific ways**. Fixing these deviations eliminates the blockers without needing B_sub_A, BX9, or any new mathematical insights.

### The Three Root Causes

| # | Deviation | Paper's approach | Codebase's approach | Sorry sites caused |
|---|-----------|-----------------|---------------------|-------------------|
| 1 | **C4 elimination strategy** | Induction on intermediate point count + formula substitution via BX6 (absorption) | "Rightmost point + bridging lemma" | 2 nested bridging (RRelation.lean:1177, 1191) |
| 2 | **C5 formulation** | Guard η ∈ g(x,y) — the interval DCS contains the guard | Guard γ ∈ f(z) for each domain point z individually | 2 FUC (ChronicleToCountermodel.lean:615, 619) |
| 3 | **C5 elimination** | Full induction with Lemma 2.7/2.8 for inserting between existing points; g-values assigned eagerly | Only case n=0 (place witness after everything); g-values deferred | 7 c2' sorry sites (CounterexampleElimination.lean:786-970, 1086) |

## 1. B_sub_A Was Never Part of the Construction

**Unanimous finding (all 4 teammates)**. Neither Burgess 1982 nor Xu 1988 uses the property "β ∈ B implies β ∈ A" anywhere. It was an artifact of the closed guard convention, which was non-standard — **all papers use open/strict guard semantics** (the same as our system after task 113).

Burgess's Lemma 2.6 (D0 consistency) uses:
- **Maximality of R(A,B,C)**: since δ ∉ B, there exist β₀ ∈ B, γ₀ ∈ C with ¬U(γ₀, β₀ ∧ δ) ∈ A
- **A4a + A5a + A3a** axioms for the consistency argument
- **Not** B ⊆ A at any point

Xu's approach (Lemma 3.2.1) provides the replacement property: R(A,B,C) implies B is closed under forming Until/Since with endpoint elements. This uses only BX5 (self_accum) + maximality.

**The 37 research rounds spent on B_sub_A were investigating a problem that never existed in the mathematics.** The property was introduced by the codebase's (now-removed) closed guard convention and was never needed by the original proof.

## 2. The Nested Bridging Problem Is Solved by Formula Substitution

**Unanimous finding (all 4 teammates, independently traced through the same proof).**

### Burgess's Lemma 2.9 (C4 elimination)

Induction on n = number of domain points between x and y:

**Case n = 0**: Adjacent pair. Apply Lemma 2.6 directly (requires R-maximality at adjacent pairs).

**Case n = m+1**: Let x' be the immediate successor of x.
- If ¬U(γ,δ) ∈ f(x'): reduce to n = m by replacing x with x'.
- If U(γ,δ) ∈ f(x'): 
  1. δ ∈ f(x') is **forced** (otherwise ¬δ ∈ f(x') would resolve the counterexample)
  2. Set γ' = δ ∧ U(γ,δ) ∈ f(x')
  3. By **BX6** (absorption) contrapositive: ¬U(γ',δ) ∈ f(x)
  4. Now (x, x', γ', δ) is a C4 counterexample with **0 intermediate points**
  5. Apply the base case

**The nested case is handled by SUBSTITUTING the formula** (γ → γ' = δ ∧ U(γ,δ)) and reducing to the adjacent case. The codebase's "rightmost point + bridging lemma" strategy is a deviation that introduces the nested case. `burgessR3_gamma_not_in_B_nested` was never needed — Burgess and Xu both handle this with BX6 (which we have).

### Xu's Theorem 3.3 (identical strategy)

> "If U(γ,β) ∈ f(t'), we must have β ∧ U(γ,β) ∈ f(t'). Since ¬U(γ,β) ∈ f(t₁), by (9) [= BX6]: ¬U(β ∧ U(γ,β), β) ∈ f(t₁). Hence reduce to case n = 0."

**Fix**: Delete `burgessR3_gamma_not_in_B_nested` and `_since_nested`. Restructure `eliminate_C4_counterexample` to use induction with formula substitution via BX6.

## 3. The FUC Problem Is Caused by a Wrong C5 Formulation

### Paper vs Code C5

| Aspect | Burgess C5a | Code C5 |
|--------|------------|---------|
| Guard location | η ∈ **g(x,y)** | γ ∈ **f(z)** for each z ∈ dom between x,y |
| Truth lemma | Immediate: g(x,y) ⊆ f(z) by C3 → η ∈ f(z) | Requires separate proof that γ propagates |
| Guard source | C5 elimination places η in g-value | C5 elimination defers g-value assignment |

### How Burgess's Truth Lemma Works (Claim 2.11)

For α = U(β,γ) [Burgess notation: β = event, γ = guard]:
1. C5a gives y with β ∈ f(y) and **γ ∈ g(x,y)**
2. For any z between x and y: C3 gives **g(x,y) ⊆ f(z)**, so γ ∈ f(z)
3. Done — the guard is at every intermediate point

**The FUC proof is trivial once C5 puts the guard in g(x,y).** The codebase's FUC sorry exists because:
1. C5 is formulated with guards at individual domain points instead of in g(x,y)
2. C5 elimination doesn't assign g-values (defers them, creating c2' sorry sites)
3. Without η ∈ g(x,y), C3 can't distribute the guard

### The C5 Elimination Induction Step Is Missing

Burgess's Lemma 2.10 uses induction on elements after x:
- **Case n=0**: Apply Lemma 2.4. Place new y after x. Set g(x,y) = B where η ∈ B.
- **Case n=m+1**: Let x' succeed x. Use Lemma 2.7 or 2.8 to insert z between x and x'.

The codebase only implements case n=0 (placing y after ALL domain points). **Lemmas 2.7 and 2.8 (insertion between existing points with guard propagation) are not implemented.** This is the second root cause of the FUC sorry.

**Fix**: 
1. Reformulate C5 to put guard in g(x,y) instead of individual f(z)
2. Implement the full C5 elimination induction (including Lemma 2.7/2.8)
3. The truth lemma then follows from C5 + C3 exactly as Burgess describes

## 4. C2' Must Include Maximality

**Unanimous finding (Teammates A, B, C).**

Burgess's C2' requires **R(f(x), g(x,y), f(y))** — R-maximality. The code's C2' only requires DCS + burgessR3 (no maximality). This matters because:

1. **Lemma 2.6** starts "Suppose R(A,B,C) and δ ∉ B" — maximality is needed to derive the ¬U formula
2. **Xu's Lemma 3.2.1** (closure under Until/Since formation) requires R-maximality
3. The C4 base case applies Lemma 2.6 to an adjacent pair, needing R-maximality

**Fix**: Upgrade c2' to require `BurgessR3Maximal` instead of just `burgessR3`. The infrastructure `burgessR3Maximal_exists_from_seed` (RRelation.lean:1131) already produces maximal DCSs.

## 5. A4a Is Not In Our Axiom System

**Key finding (Teammate B).**

Burgess's A4a = `U(p,q) ∧ ¬U(p,r) → U(q ∧ ¬r, q)` (Until comparison axiom). This is used in his D0 consistency proof. **It is NOT in Xu's Sigma4 system and NOT in our BX axioms.**

| Burgess J0 | Xu Sigma4 | Our BX |
|-----------|-----------|--------|
| A1a | (1) part 1 | BX2 |
| A2a | (1) part 2 | BX3 |
| A3a | (3) | BX4 |
| **A4a** | **absent** | **absent** |
| A5a | (7) | BX5 |
| A6a | (9) | BX6 |
| A7a | (10) | BX7 |

**Impact**: We cannot follow Burgess's D0 consistency proof exactly — we must use Xu's approach (Lemma 3.2.1 + 3.2.2) which avoids A4a. Xu proves completeness for Sigma4 = (7)+(8)+(9)+(10)+(11) = BX5+BX5'+BX6+BX7+BX7', which is a subset of our system.

A4a is derivable from BX5+BX6+BX7 on linear orders (Xu's completeness result implies this), but the derivation is non-trivial and not needed — Xu's direct approach is cleaner.

## 6. The `rRelation` Concept Is a Codebase Invention

**Finding (Teammates A, B, C).**

The codebase's `rRelation(A, B)` (obligation propagation: for U(γ,δ) ∈ A, either δ ∈ B or γ ∈ B ∧ U(γ,δ) ∈ B) does not appear in Burgess or Xu. Only the content-based `burgessR3(A, B, C)` (= Burgess's r(A,B,C)) is used in the chronicle construction.

The `rRelation` concept has caused persistent confusion:
- Reports confuse it with `burgessR3`
- `rRelation_guard_continues'` was proposed as the FUC fix, but operates on the wrong concept
- `c2` uses `r3Relation` (based on `rRelation`) instead of `burgessR3`

**Impact**: The `rRelation`/`r3Relation` concepts should be relegated to a secondary role. The chronicle construction should use only `burgessR3`/`BurgessR3Maximal`, matching the papers. A bridge lemma `BurgessR3Maximal_implies_rRelation` can be proved separately if needed for other purposes.

## 7. Reynolds and Venema Are Not Alternatives

**Finding (Teammate D).**

- **Reynolds 1992**: Explicitly requires Burgess's construction as step 1. His contribution is transferring from Q to R using Doets' theorem. Not an alternative.
- **Venema 1993**: Limited to well-orders (uses axiom W: Fp → U(p,¬p)). Not applicable to general linear frames.
- **Hodkinson-Reynolds 2006**: Survey confirms Burgess-Xu is the standard approach.

No paper suggests a simpler alternative to the chronicle construction for Until/Since over linear orders.

## 8. Corrected Sorry Analysis

The 11 chronicle sorry sites, reclassified by root cause:

| Root cause | Sorry sites | Fix |
|-----------|-------------|-----|
| **Wrong C4 strategy** (deviation #1) | 2: RRelation.lean:1177, 1191 | Restructure to induction + BX6 substitution |
| **Wrong C5 formulation** (deviation #2) | 2: ChronicleToCountermodel.lean:615, 619 | Put guard in g(x,y), use C3 for distribution |
| **Deferred g-value assignment** (deviation #3) | 6: CounterexampleElimination.lean:786, 824, 864, 902, 938, 970 | Assign g-values during C5 elimination (Lemma 2.10) |
| **Missing C5 induction step** (deviation #3) | 1: CounterexampleElimination.lean:1086 (density) | Implement full Lemma 2.10 induction |

**All 11 sorries trace to 3 deviations from the paper.** None require new mathematical insights — only faithful implementation of the published proofs.

## 9. Revised Plan Direction

### What the plan revision must do

1. **Restructure C4 elimination** (CounterexampleElimination.lean:340-433)
   - Replace "rightmost point + bridging" with Burgess's induction on intermediate points
   - Use BX6 (absorption) for the formula substitution step
   - Delete `burgessR3_gamma_not_in_B_nested` and `_since_nested` sorry stubs
   - **Estimated: 10-15 hours**

2. **Reformulate C5** (ChronicleTypes.lean:418-424)
   - Change from "guard at every domain point" to "guard in g(x,y)"
   - This is a definition change with cascading effects on all C5-related proofs
   - **Estimated: 4-6 hours** (definition + proof updates)

3. **Implement full C5 elimination** (CounterexampleElimination.lean + ChronicleConstruction.lean)
   - Add Lemma 2.7/2.8 (insertion between existing points)
   - Assign g-values eagerly during elimination (η ∈ g(x,y))
   - Implement the induction step (case n=m+1)
   - **Estimated: 15-25 hours** (most complex change)

4. **Upgrade C2' to include maximality**
   - Change `c2'` to require `BurgessR3Maximal` instead of just `burgessR3`
   - Use `burgessR3Maximal_exists_from_seed` (already sorry-free) for construction
   - **Estimated: 3-5 hours**

5. **Implement Xu's Lemma 3.2.1** (B closure under Until/Since formation)
   - Prove: R(A,B,C) → ∀β∈B, ∀γ∈C, U(γ,β) ∈ B
   - Uses BX5 + maximality — no new axioms needed
   - **Estimated: 3-5 hours**

6. **Follow Xu's D0 consistency approach** (avoiding Burgess's A4a)
   - Use Lemma 3.2.1 + 3.2.2 instead of A4a
   - The seed set construction uses BX5+BX6+BX7 (all available)
   - **Estimated: 8-12 hours**

7. **Fix C2 definition** (ChronicleTypes.lean)
   - Change from `r3Relation` to `burgessR3`
   - **Estimated: 1-2 hours**

### Total estimate: 44-70 hours

This is LOWER than the previous estimate (100-150h) because:
- No open mathematical questions remain — only faithful implementation of published proofs
- The sorry sites are caused by deviations, not missing mathematics
- Existing sorry-free infrastructure (`burgessR3Maximal_exists_from_seed`, `lemma_2_6`, `burgessR3_absorption`) is correct and reusable

### Confidence: HIGH (80-90%)

The mathematics is established and published. The mapping between paper and codebase is now clear. The main risk is Lean engineering complexity, not mathematical uncertainty.

## Conflicts Resolved

| Conflict | Resolution |
|----------|-----------|
| B_sub_A: recoverable or not? | **Irrelevant** — never part of the construction |
| Nested bridging: provable or not? | **Not needed** — Burgess uses formula substitution |
| FUC: how hard? | **Trivial** once C5 is reformulated correctly |
| rRelation vs burgessR3 bridge? | **rRelation is unnecessary** — use only burgessR3 |
| A4a: available or not? | **Not available, not needed** — use Xu's approach |

## Gaps Identified

1. **Lemma 2.7 and 2.8 need careful study** before implementation — they handle insertion between existing points during C5 elimination
2. **The C5 reformulation has cascading effects** on all C5-related proofs (limit_satisfies_c5, the truth lemma, etc.) — scope needs careful assessment
3. **Xu's Lemma 3.2.1 proof** needs to be worked through in Lean detail to confirm BX5 + maximality suffice
4. **A3a/A4a validity in bimodal setting** — Teammate A flagged that these are valid in pure tense logic but might behave differently with Box. This needs verification if we ever want to follow Burgess's D0 proof directly.

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key contribution |
|----------|-------|--------|------------|-----------------|
| A | Burgess 1982 | Completed | HIGH | 6 paper-vs-code mismatches; C5 g-value assignment is the root FUC cause |
| B | Xu 1988 | Completed | HIGH | A4a absent from our system; Xu 3.2.1 is the B_sub_A replacement; nested case uses BX6 |
| C | Paper-vs-code critic | Completed | HIGH | Systematic mapping table; C5 formulation mismatch is deepest architectural issue |
| D | Reynolds/Venema/strategy | Completed | HIGH | No alternatives exist; all papers use open guard; B_sub_A never existed |

## References

### Burgess 1982
- p.367: U(event, guard) convention, F α = U(α, ⊤)
- p.370: r(A, β, C) definition, R(A, B, C) maximality
- p.371: Lemma 2.6 (D0 consistency) — uses A4a, A5a, A3a, NOT B_sub_A
- p.372: Chronicle conditions C0-C5a, C2' requires R-maximality
- p.372-373: Lemma 2.9 (C4 elimination) — induction with formula substitution via A6a
- p.373: Lemma 2.10 (C5 elimination) — induction with Lemma 2.7/2.8
- p.373-374: Claim 2.11 (truth lemma) — uses C5a (η ∈ g(x,y)) + C3

### Xu 1988
- p.188: Lemma 2.3 (S(α,⊤) ∈ B, U(γ,⊤) ∈ B) — uses BX4
- p.192: Lemma 3.2.1 (B closed under Until/Since formation) — uses BX5 + maximality
- p.195: Sigma4 axiom system = BX5+BX5'+BX6+BX7+BX7'
- p.195-198: Theorem 3.3 (C4 elimination for Sigma4) — induction with BX6 substitution

### Reynolds 1992
- §4: Requires Burgess construction as prerequisite

### Venema 1993
- §4.1: Limited to well-orders, not applicable

### Teammate Reports
- [39_teammate-a-findings.md] — Burgess 1982 detailed reading
- [39_teammate-b-findings.md] — Xu 1988 detailed reading
- [39_teammate-c-findings.md] — Paper-vs-code mapping table
- [39_teammate-d-findings.md] — Alternative approaches assessment
