# Teammate A: Primary Approach — Literature Survey for limitDomSubtype_Icc_finite

## Key Findings

### 1. Burgess 1982 — The Foundation (HIGHEST relevance)

Burgess's completeness proof (§2) constructs chronicles with **finite domains** (condition C0': "dom f is finite"). The omega chain builds a limit by countably extending these finite stages. Crucially:

- Each chronicle step adds **exactly one new rational** to the domain (Lemmas 2.9, 2.10).
- The limit domain `X = ⋃ dom(f_n)` is countable.
- Burgess never discusses bounded interval finiteness because in his setting (arbitrary linear orders), the discrete case is handled by adding the discreteness axiom `G'⊥ ∧ H'⊥` (§1.6), and completeness for discrete orders is left as "a routine exercise." He does **not** provide an explicit proof that bounded intervals in discrete limit domains are finite.

**Relevant insight**: The chronicle construction adds points one at a time. Each stage `n` has `dom(f_n) : Finset Rat`. The key question is: in the discrete case, can a bounded interval `[a,b]` accumulate infinitely many domain points across all stages?

### 2. Verbrugge 2004 — Step-by-Step Construction (HIGHEST relevance)

Verbrugge's paper provides the most directly applicable technique. Their completeness proof for **D** (discrete logic) and **Z** (integers) uses the step-by-step method with:

- **Theorem 5** (D completeness): At odd stages, an immediate successor and predecessor are assigned to each point. The construction ensures discreteness — no new points are ever inserted between a point and its immediate successor.
- **Theorem 6** (Z completeness): Uses **finite adequate sets** (Definition 4). The adequate set Σ is finite, so there are only finitely many maximal consistent subsets of Σ. This directly bounds how many structurally distinct points can exist.
- **Key mechanism**: In the Z construction, the "middle part" between `t_l` and `t_r` is **finite** (explicitly stated: "this period will just last a finite number of stages"). Then the extension to Z produces copies of this finite pattern.

**Critical insight for our problem**: Verbrugge shows that in the discrete case, the construction process itself terminates after finitely many insertions into any bounded region. This is because:
1. Each insertion resolves a `¬G`-formula
2. The set of relevant formulas is finite (closed under subformulas of the input)
3. Each formula is treated once, and after treatment, no further insertions are needed in that region

### 3. Venema 1993 — Discrete/Well-Ordered Time (HIGH relevance)

Venema's paper addresses well-ordered time (`ω`) and discrete time, but uses a fundamentally different technique: "Completeness via Completeness" — leveraging expressive completeness of S,U to transfer from one model to another via Doets's theorem.

- **Lemma 3.3**: Shows `D ↔ discrete ordering` where D = `F⊤ → U(⊤,⊥) ∧ P⊤ → S(⊤,⊥)`. This is exactly the discreteness axiom used in our formalization (`next_top = U(⊤,⊥)`).
- **Theorem 4.3**: For completeness of BN (Burgess + Discreteness) with respect to ω, Venema constructs a well-ordered model and then uses `D` to force isomorphism with ω.
- Venema does **not** directly prove bounded interval finiteness; instead, the n-equivalence theorem of Doets (§3.8) transfers properties wholesale.

**Not directly applicable** to our proof strategy (we need a direct structural argument, not a model-replacement argument).

### 4. Xu 1988 — Expressibility Limits (MEDIUM relevance)

Xu extends Burgess's methods to non-linear time. The key insight for us:

- **Theorem 2.9**: Irreflexivity is **not** U,S-definable. This is precisely why BX uses special handling (the IRR axiom approach vs Reynolds 1992's alternative).
- Xu's chronicle construction follows Burgess exactly — finite stages, one point added at a time.
- No explicit treatment of bounded interval finiteness in discrete settings.

### 5. Reynolds 1992 — IRR-Free Completeness (MEDIUM relevance)

Reynolds gives an orthodox axiomatization for U,S over the reals. Section 10 mentions a similar technique for integers. The key structural insight:

- The completeness proof goes through rational-flowed models first, then transfers to reals via Doets's theorem.
- The rational model is constructed exactly as in Burgess — omega chain of finite chronicles.
- No explicit bounded interval finiteness argument.

### 6. Omega Chain Structure (from ChronicleConstruction.lean)

From the codebase itself, the critical structural fact:
```
structure Chronicle where
  dom : Finset Rat    -- FINITE at each stage
```

`limit_dom A h_mcs = { x | ∃ n : Nat, x ∈ (omega_chain_val A h_mcs n).dom }`

Each stage `n` adds at most one point (resolving one counterexample). So for any point `x ∈ limit_dom`, there exists a **first stage** `n_x` at which `x` enters the domain.

## Recommended Approach

**The proof should be a direct induction on the omega chain construction, exploiting the discrete hypothesis.**

The argument is:

1. **Both `a` and `b` enter the domain at finite stages**: ∃ `n_a`, `n_b` such that `a ∈ dom(n_a)` and `b ∈ dom(n_b)`. Let `N = max(n_a, n_b)`.

2. **After stage N, the discrete structure prevents new insertions between existing adjacent points**: In the discrete case, `U(⊤,⊥)` is in every domain MCS. This means for any domain point `x`, its C5 witness `y > x` has an **empty guard** (⊥ is never in any MCS). So `x` and `y` are adjacent — no domain points can exist between them.

3. **Key insight**: Once all points in `[a,b]` have been inserted (at some finite stage `M ≥ N`), the discreteness axiom prevents C4 counterexamples from inserting new points between adjacent domain points. A C4 counterexample `(x, y, γ, δ)` with `x < z < y` requires `z` to be a domain point between `x` and `y`. But in the discrete case, adjacent points have no domain points between them by construction.

4. **Therefore**: `{x ∈ limit_dom | a ≤ x ∧ x ≤ b}` is a subset of `dom(M)` for some finite `M`, hence finite.

**However**, this argument has a subtlety: the omega chain construction doesn't just resolve counterexamples *within* `[a,b]` — it can resolve counterexamples *elsewhere* that happen to add points inside `[a,b]`. The key is that in the **discrete** case, once adjacency is established between two points, no new point can be inserted between them (because the guard in C5 is ⊥).

The cleanest formalization approach is:

**Strong induction**: Given `a ≤ b` in `LimitDomSubtype`, and the discrete hypothesis, show that the interval `{x | a ≤ x ∧ x ≤ b}` is contained in a finite stage's domain. This requires showing that the omega chain eventually "stabilizes" on `[a.val, b.val]`.

**Alternative (simpler)**: Use the already-proven `SuccOrder` and `PredOrder` to show that `{x | a ≤ x ∧ x ≤ b}` = `{a, succ(a), succ(succ(a)), ..., b}` — i.e., it's exactly the set of successor iterates from `a` up to `b`. If this set were infinite, by pigeonhole (since `LimitDomSubtype` is countable and embeds in ℚ), we'd get an accumulation point in `[a.val, b.val]`, contradicting discreteness.

Actually, the **simplest approach** may be to not use the literature at all, but instead use a **Lean-internal argument**:

- Since `LimitDomSubtype` has `SuccOrder` with `succ_le_iff`, and `PredOrder` with `le_pred_iff`, and is a subset of ℚ, bounded intervals are finite because each successor moves strictly forward by a positive rational gap (no two domain points are equal). The interval `[a.val, b.val] ∩ ℚ` has a finite number of domain points because each `succ` step creates a strict gap.

## Evidence/Examples

- **Burgess 1982, §1.6**: Discreteness axiom `G'⊥ ∧ H'⊥` (= `U(⊤,⊥) ∧ S(⊤,⊥)`) — exactly what `h_discrete` provides.
- **Verbrugge 2004, Theorem 5**: "It will then never be necessary to introduce at an even stage a successor of t which is not a successor of u" — the key stabilization argument.
- **Verbrugge 2004, Theorem 6**: Middle part is finite; extension produces periodic copies.
- **ChronicleTypes.lean:380**: `dom : Finset Rat` confirms each stage has finite domain.
- **ChronicleConstruction.lean:551**: `limit_dom = { x | ∃ n, x ∈ (omega_chain_val A h_mcs n).dom }` — countable union of finite sets.

## Confidence Level

**Medium-High**

The literature does not contain an explicit proof of bounded interval finiteness in discrete limit domains. However, the structural argument is clear from the construction: discrete ordering prevents accumulation of domain points. The main risk is in the formal details of showing that the omega chain stabilizes on bounded intervals.

The Verbrugge 2004 paper provides the strongest indirect evidence — their Z completeness proof implicitly relies on bounded regions being finite, though they don't state it as a separate lemma. The step-by-step method's termination in bounded regions is the core mechanism.

**None of the papers contain a directly extractable proof**, but the combination of:
1. Finite stages (Burgess C0')
2. Discrete adjacency (from `U(⊤,⊥)`)
3. No insertions between adjacent points

...gives a clear path to a formal proof. The key formal challenge is showing property (3) within the specific omega chain construction used in this project.
