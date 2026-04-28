# Teammate B Findings: Xu 1988 Sigma4 Completeness — Detailed Analysis

**Task**: 107 — Burgess chronicle construction for BX representation theorem
**Focus**: How Xu 1988 proves completeness for Sigma4, mapped to our blockers
**Date**: 2026-04-28

## 1. Xu's Sigma4 Axiom System — Mapped to BX

Xu defines Sigma4 at p. 195 as axioms (7), (8), (9), (10), (11). Here is the complete mapping:

### Base Logic (shared across all Xu systems)

| Xu axiom | Formula | Our BX name | Notes |
|----------|---------|-------------|-------|
| (1) | `G(p→q) → (U(r,p)→U(q,r)) ∧ (U(r,p)→U(r,q))` | BX2 + BX3 | Xu packs left+right mono into one axiom |
| (2) | `H(p→q) → (S(p,r)→S(q,r)) ∧ (S(r,p)→S(r,q))` | BX2' + BX3' | Since mirror |
| (3) | `p ∧ U(q,r) → U(q ∧ S(p,r), r)` | BX4 (connect_future) | Temporal connectedness |
| (4) | `p ∧ S(q,r) → S(q ∧ U(p,r), r)` | BX4' (connect_past) | Mirror |

### Sigma4-specific axioms

| Xu axiom | Formula | Our BX name | Notes |
|----------|---------|-------------|-------|
| (7) | `U(p,q) → U(p, q ∧ U(p,q))` | BX5 (self_accum_until) | Self-accumulation |
| (8) | `S(p,q) → S(p, q ∧ S(p,q))` | BX5' (self_accum_since) | Mirror |
| (9) | `U(q ∧ U(p,q), q) → U(p,q)` | BX6 (absorb_until) | Absorption |
| (10) | `U(p,q) ∧ U(r,s) → U(p∧r, q∧s) ∨ U(p∧s, q∧s) ∨ U(q∧r, q∧s)` | BX7 (linear_until) | Linearity |
| (11) | `S(p,q) ∧ S(r,s) → S(p∧r, q∧s) ∨ S(p∧s, q∧s) ∨ S(q∧r, q∧s)` | BX7' (linear_since) | Mirror |

### What Xu DOES NOT include (and we DO have)

| Our BX axiom | What it does | Why Xu omits it |
|-------------|--------------|-----------------|
| BX1/BX1' (serial_future/past) | ⊤ → F(⊤) | Xu proves completeness for ALL frames, not just serial ones |
| BX10/BX10' (until_F/since_P) | φ U ψ → F(ψ) | Not needed for Xu's proof — his frame is constructed with F built-in |
| BX11/BX11' (temp_linearity) | F(φ) ∧ F(ψ) → disjunction | Derivable from BX7 using BX12 |
| BX12/BX12' (F_until_equiv) | F(φ) → ⊤ U φ | This is the definition of F in Xu/Burgess (F = U(−, ⊤)) |
| BX9 (until_elim) | φ U ψ → φ ∨ ψ | **Correctly absent** — not sound under open guard |
| BX8 (until_step) | | **Correctly absent** — not sound under half-open guard |

### Crucial Observation: Xu's Sigma4 is WEAKER than our BX system

Xu's Sigma4 = (1)-(4) + (7)-(11) = BX2-BX7 + BX4-BX4' (roughly). Our system adds BX1, BX10, BX11, BX12, plus modal axioms and modal-temporal interaction. **Our system is a proper EXTENSION of Xu's Sigma4.** This means Xu's completeness proof works in a MORE GENERAL setting — it proves completeness with FEWER axioms than we have.

### NOTE on Xu axiom (3) vs Burgess A3a

Xu's axiom (3) is `p ∧ U(q,r) → U(q ∧ S(p,r), r)`. This is EXACTLY Burgess's A3a: `p ∧ U(q,r) → U(q ∧ S(p,r), r)`. In our system this is BX4 (connect_future). It is **NOT** what one might confuse with the closed-guard "until_guard" axiom.

## 2. How Xu Proves Completeness for Sigma4

Xu's proof for Sigma4 (p. 195-198) is **not independently developed** — he explicitly refers to Burgess [1] and says "by applying the work of Burgess in [1] together with our 3.2.1 and 3.2.2."

### High-level structure

1. Use the same chronicle framework as Burgess: Definition 2.5 (C0-C4) with modifications
2. For linear orders (Sigma4): use Burgess's C1-C6 but with strengthened C4 (= C4'')
3. The key Xu contributions for Sigma4 are:
   - **Lemma 3.2.1** (new content for R(A,B,C)): proves B is "closed under Until/Since" when R(A,B,C) holds
   - **Lemma 3.2.2** (strengthened 2.4): the C5 counterexample lemma gets stronger D with B ⊆ B' ∩ D ∩ B''
   - **Modified C4**: Replace Burgess C4 with C4'' = `g(t,t') ⊆ g(t,t'') ∩ f(t'') ∩ g(t'',t')` for all intermediate t''

### The critical innovation: Lemma 3.2.1

**Xu Lemma 3.2.1** (p. 192): Suppose R(A, B, C). Then:
- (i) for every β ∈ B and γ ∈ C, U(γ, β) ∈ B
- (ii) for every β ∈ B and α ∈ A, S(α, β) ∈ B

**THIS IS THE REPLACEMENT FOR B ⊆ A.** Instead of needing B ⊆ A (which is impossible under open guard), Xu shows that B is closed under forming Until/Since formulas with endpoint elements. This is a **strictly weaker** property that is provable from axioms (7) and (10) (= BX5 and BX7).

**Proof of 3.2.1(i)** (from Xu p. 192):
> Suppose for contradiction that U(γ, β) ∉ B for some β ∈ B, γ ∈ C. Then by 2.0 there are β' ∈ B, γ' ∈ C such that ¬U(γ', β' ∧ U(γ,β)) ∈ A. It is easy to see that U(γ'', β'' ∧ U(γ'',β'')) → U(γ', β' ∧ U(γ,β)) ∈ TL(∅) where γ'' = γ ∧ γ', β'' = β ∧ β'. Hence by (7), ¬U(γ'', β'') ∈ A. But by hypothesis U(γ'', β'') ∈ A since β'' ∈ B and γ'' ∈ C.

The proof uses **only axiom (7)** (= BX5, self_accum_until) and **the maximality of B** (the R-relation). It does NOT use BX9 at any point.

### What 3.2.1 gives us that B ⊆ A doesn't

Under the old closed guard, B ⊆ A was a crude but powerful inclusion. Under open guard, B and A are genuinely different sets. But 3.2.1 gives a _structural_ property: B is closed under Until/Since formation with endpoint elements. This is what Burgess's Lemma 2.5 (in his paper, not Xu's) implicitly uses.

**Impact on our codebase**: The property `R(A, B, C) → ∀ β ∈ B, ∀ γ ∈ C, U(γ, β) ∈ B` needs to be proved in Lean. It uses BX5 + maximality. It does NOT correspond to `rRelation_guard_continues'`, which is the Xu 2.3 two-argument version. It's a NEW lemma that needs implementation.

## 3. Xu's Lemma 2.3 — What It Actually Says

**Xu Lemma 2.3** (p. 188): Suppose R(A, B, C). Then:
- (i) S(α, ⊤) ∈ B for every α ∈ A
- (ii) U(γ, ⊤) ∈ B for every γ ∈ C

**This is NOT `rRelation_guard_continues'`.** Our `rRelation_guard_continues'` is:
```
rRelation A B → untl(γ,δ) ∈ A → δ ∉ B → γ ∈ B ∧ untl(γ,δ) ∈ B
```

Xu's Lemma 2.3 is about the MAXIMAL relation R(A,B,C) and uses the THREE-argument setting. It says: when B is maximal with respect to r(A,−,C), then S(α,⊤) ∈ B for all α ∈ A and U(γ,⊤) ∈ B for all γ ∈ C.

**Xu's proof** (p. 188):
> Suppose S(α,⊤) ∉ B for some α ∈ A. Then by 2.0(iii) there are β ∈ B, γ ∈ C such that ¬U(γ, β ∧ S(α,⊤)) ∈ A. But [...] α ∧ U(γ,β) → U(γ, β ∧ S(α,⊤)) ∈ TL(∅) [by axioms (1) and (3)], and by hypothesis α ∧ U(γ,β) ∈ A.

This uses axioms (1) = BX2+BX3 and (3) = BX4. **It works under open guard because it only uses BX4 (connect_future), not BX9.**

### Connection to our codebase's `rRelation_guard_continues'`

The codebase's `rRelation_guard_continues'` is a consequence of the TWO-argument `rRelation(A, B)`, which says: for all γ,δ, if γ U δ ∈ A, then δ ∈ B or (γ ∈ B ∧ γ U δ ∈ B). This is NOT from Xu's paper — it's an additional property that the codebase defines independently.

**For the FUC proof**, what's needed is not `rRelation_guard_continues'` but rather the combination of:
1. **Xu Lemma 2.3**: R(A,B,C) implies closure under ⊤-guarded Until/Since
2. **Xu Lemma 3.2.1**: R(A,B,C) implies closure under Until/Since with endpoint elements
3. **The C3 condition**: g(x,z) ⊆ f(y) for intermediate y

## 4. Does Xu Handle "B ⊆ A"?

**No, and he doesn't need it.** Xu's proof NEVER uses B ⊆ A. The property never appears anywhere in his paper.

Instead, Xu uses:
- **Lemma 2.3**: S(α,⊤) ∈ B for α ∈ A (which says "traces of A appear in B as Since formulas")
- **Lemma 3.2.1**: B is closed under forming Until formulas with C-elements
- **The 2.1 equivalence** (= Burgess 2.3): r(A,β,C) iff for all α ∈ A, S(α,β) ∈ C

The Burgess construction similarly never uses B ⊆ A. Looking at Burgess's proof of Lemma 2.6 (the D0 consistency argument), the key set D0 contains:
```
D0 = {S(α,β) : α ∈ A, β ∈ B} ∪ B ∪ {¬δ} ∪ {U(γ,β) : γ ∈ C, β ∈ B}
```

The consistency proof for D0 shows that `ζ = S(α,β) ∧ β ∧ ¬δ ∧ U(γ,β)` is consistent. It does this using:
- A4a (= our codebase's analogue — but NOTE: Burgess A4a is `U(p,q) ∧ ¬U(p,r) → U(q ∧ ¬r, q)`, which is NOT an axiom in Xu's system or ours!)
- A5a (= BX5 self_accum_until)
- A3a (= BX4 connect_future)

**CRITICAL FINDING**: Burgess's A4a axiom `U(p,q) ∧ ¬U(p,r) → U(q ∧ ¬r, q)` is NOT in Xu's Sigma4 system. Burgess's system J0 has 7 axiom schemas (A1a-A7a + mirrors), while Xu's Sigma4 has axioms (1)-(4) + (7)-(11). The correspondence is:

| Burgess J0 | Xu | Our BX |
|-----------|-----|--------|
| A1a | (1) first part | BX2 |
| A2a | (1) second part | BX3 |
| A3a | (3) | BX4 |
| **A4a** | **NOT IN Sigma4** | **NOT IN BX** |
| A5a | (7) | BX5 |
| A6a | (9) | BX6 |
| A7a | (10) | BX7 |

**A4a is the "Until comparison" axiom**: `U(p,q) ∧ ¬U(p,r) → U(q ∧ ¬r, q)`. It says: if you have Until(p,q) but NOT Until(p,r), then you can form Until(q ∧ ¬r, q). This is sound on linear orders but Xu proves completeness WITHOUT it — it's derivable from (7)+(9)+(10) = BX5+BX6+BX7 on linear orders.

**Impact**: Burgess's D0 consistency proof uses A4a directly. Since we don't have A4a, we need to follow Xu's approach, which uses 3.2.1 and 3.2.2 instead. The good news is that Xu's approach is designed to work WITHOUT A4a.

## 5. How Xu/Burgess Handle the Nested Case in C4 Elimination

### Burgess's approach (2.9)

Burgess proves C4 counterexample elimination by induction on the number n of domain points between x and y.

**Case n = 0**: Direct application of Lemma 2.6 (point insertion between adjacent pair).

**Case n = m+1**: Let x' immediately succeed x in dom f.
- If ¬U(γ,δ) ∈ f(x'): reduce to case n = m by replacing x with x'.
- If U(γ,δ) ∈ f(x'): then δ ∈ f(x') (else x,y,γ,δ wouldn't be a counterexample). Let γ' = δ ∧ U(γ,δ) ∈ f(x'). By **A6a** (absorption): ¬U(γ',δ) ∈ f(x). Reduce to case n = 0 by replacing γ with γ' and y with x'.

**This is the nested case!** When U(γ,δ) ∈ f(x') but x' is not the final point, Burgess replaces the counterexample with a STRONGER one using A6a (absorption). He goes from:
- Counterexample: x, y, γ, δ with ¬U(γ,δ) ∈ f(x), γ ∈ f(y)
- New counterexample: x, x', γ', δ with ¬U(γ',δ) ∈ f(x), γ' ∈ f(x')

Where γ' = δ ∧ U(γ,δ). The key step: ¬U(γ',δ) ∈ f(x) follows from **A6a**: U(δ ∧ U(γ,δ), δ) → U(γ,δ), so ¬U(γ,δ) → ¬U(δ ∧ U(γ,δ), δ). **This uses only BX6 (absorb_until), NOT BX9.**

### Xu's approach for Sigma4 (Theorem 3.3)

For the Sigma4 case, Xu uses the SAME induction but references Burgess [1] directly:

> **Case n = 0**: Define μ' as in proving 3.2 but replacing TL(Sigma2) by TL(Sigma3).

> **Case n = m+1**: By C1* there is t' ∈ {t : t1 < t < t2} with no t in between t1 and t'. If ¬U(γ,β) ∈ f(t'), reduce to case n = m. If U(γ,β) ∈ f(t'), we must have β ∧ U(γ,β) ∈ f(t'), otherwise t1,t2,γ,β would not be a counterexample to C5a. Since ¬U(γ,β) ∈ f(t1), **by (9)** [= BX6 absorption]: ¬U(β ∧ U(γ,β), β) ∈ f(t1). Hence reduce to case n = 0 by replacing γ by β ∧ U(γ,β) and t2 by t'.

**THIS IS THE SAME STRATEGY AS BURGESS.** The nested case is handled by:
1. Recognizing that if U(γ,δ) ∈ f(x') AND δ ∈ f(x'), then δ ∧ U(γ,δ) ∈ f(x')
2. Using BX6 (absorption) to reduce to a case with fewer intermediate points

**The nested bridging lemma `burgessR3_gamma_not_in_B_nested` is NOT NEEDED.** The correct approach is Burgess/Xu's induction argument, which handles the nested case by SUBSTITUTING the counterexample rather than trying to prove that γ ∉ B.

### How this maps to CounterexampleElimination.lean

The current code at line 422 tries to use `burgessR3_gamma_not_in_B_nested` to prove γ ∉ g(w, w_next) when untl(γ,δ) ∈ f(w_next). **This is the wrong approach.** The correct approach from Burgess/Xu:

1. When U(γ,δ) ∈ f(w_next) and w_next < y: note that δ ∈ f(w_next) must hold (else the point w_next wouldn't be after the rightmost point with ¬U(γ,δ))
2. Form γ' = δ ∧ U(γ,δ) which is in f(w_next)
3. By BX6: ¬U(γ',δ) ∈ f(w), since ¬U(γ,δ) ∈ f(w) and U(γ',δ) → U(γ,δ) is a theorem
4. This gives a new counterexample (w, w_next, γ', δ) with ZERO intermediate points
5. Apply the base case (direct point insertion using Lemma 2.6)

**No nested bridging lemma is needed at all. The sorry stubs at lines 1169 and 1183 can be deleted and the C4 elimination restructured to use the induction pattern.**

## 6. Xu's Definition of "Chronicle" vs Burgess's

They are essentially the same. Xu's Definition 2.5 (p. 189) defines K (= the set of valid chronicles) with conditions:

| Xu | Burgess | Our codebase | Notes |
|----|---------|-------------|-------|
| C0 | C0 | `Chronicle.dom` | Finite subset of T* |
| C1 | (implicit) | (implicit) | Frame is asymmetric |
| C2 | C1 | `Chronicle.g` | f maps to MCS, g maps to DCS |
| C3 | C2 | `c2'` (partially) | r(f(t), g(t,t'), f(t')) for t < t' |
| C4 | C3 | `c3` | g(t,t') ⊆ f(t'') for t < t'' < t' |

For Sigma4 (linear orders), Xu strengthens:
- **C4** (replacing C4 in base) to: `g(t,t') ⊆ g(t,t'') ∩ f(t'') ∩ g(t'',t')` for ALL t < t'' < t' (not just adjacent). This is exactly our **C3** (three-way intersection).
- **C3** is strengthened to: r(f(t), g(t,t'), f(t')) where g is **R-maximal** for adjacent pairs (using 3.2.1 to get the stronger closure properties). This is our **c2'**.

The key difference for Sigma4 is that Xu uses **Lemma 3.2.1** (B is closed under Until/Since with endpoint elements) to construct the g-values for new adjacent pairs in the C5 counterexample lemma. This ensures the stronger C4'' holds automatically.

## 7. Density

**Xu's proof works for ALL linear orders (including non-dense ones).** The Sigma4 system characterizes the class C4 of ALL linear frames (p. 195):

> Let C4 be the class of all linear frames, i.e., of all transitive frames F satisfying ∀xy(x = y ∨ x < y ∨ y < x).

The completeness proof constructs a model over the rationals (which is dense), but the soundness holds for ALL linear orders. The construction embeds into Q by choosing fresh rationals at each step.

**Density of the limit domain is a CONSEQUENCE** of the construction, not a requirement. At finite stages the domain is discrete; only the limit (union of all stages) is dense.

## Summary: What the Literature Tells Us About Our Blockers

### Blocker 1: B_sub_A irrecoverable
**Literature says**: Correct — neither Burgess nor Xu use B ⊆ A anywhere. They use Lemma 2.3 (S(α,⊤) ∈ B for α ∈ A) and Lemma 3.2.1 (B closed under Until/Since formation). **No fix needed — the property was always a red herring from the closed-guard era.**

### Blocker 2: Nested bridging lemma
**Literature says**: The lemma is NOT NEEDED. Burgess and Xu handle the nested case via induction + BX6 (absorption). The C4 counterexample elimination should be restructured to use this induction pattern, eliminating the sorry stubs entirely. **Estimated: 8-12h to restructure CounterexampleElimination.lean.**

### Blocker 3: FUC replacement
**Literature says**: The FUC proof (truth lemma for Until) uses C5a + C4a + C3. At the limit:
- C5a gives witness y with ξ ∈ f(y) and η ∈ g(x,y)
- C3 gives g(x,y) ⊆ f(z) for all z between x and y
- This means η ∈ f(z) for all z between x and y
- **The guard is AUTOMATIC from C3.** No `rRelation_guard_continues'` needed.

BUT: the C5a witness gives η ∈ g(x,y), not η at the chronicle level. We need that the limit chronicle satisfies C5a with g-values that correctly track the guard. The key is that at each finite stage, the C5 counterexample lemma (Xu 2.7 / Burgess 2.10) places η ∈ g(x,y) by construction. **The guard propagation comes from C3 + the omega-chain construction, not from any axiom.**

### Blocker 4: rRelation/burgessR3 bridge
**Literature says**: The two concepts ARE different but the bridge is through **Lemma 3.2.1**. R(A,B,C) (maximal burgessR3) implies that B satisfies rRelation(A,B) as a CONSEQUENCE: for any γ U δ ∈ A, either δ ∈ B (if resolved) or γ ∈ B ∧ γ U δ ∈ B (by 3.2.1 and maximality). **A new lemma `BurgessR3Maximal_implies_rRelation` needs to be proved.**

### Blocker 5: D0 seed reconstruction
**Literature says**: Burgess's D0 consistency proof uses A4a which we don't have. Xu's approach using 3.2.1 + 3.2.2 should be followed instead. The key is that Xu's 3.2.2 (= strengthened 2.4) gives the D0-like construction without needing A4a or B ⊆ A.

## Confidence Level

| Finding | Confidence | Rationale |
|---------|------------|-----------|
| Axiom mapping Sigma4 ↔ BX | HIGH | Direct textual correspondence, verified against Lean source |
| B_sub_A never used in literature | HIGH | Read both papers end-to-end, no occurrence |
| Nested case solved by induction + BX6 | HIGH | Explicit in both Burgess 2.9 and Xu 3.3 |
| FUC guard from C3 + C5 | HIGH | This is exactly what Burgess 2.11 proves |
| A4a not in our system | HIGH | Verified against Axioms.lean — no constructor matches |
| Xu 3.2.1 replaces B_sub_A | HIGH | Explicit proof uses only BX5 + maximality |
| BurgessR3Maximal → rRelation bridge | MEDIUM | Mathematically clear but needs Lean implementation |
