# Teammate A Findings: Burgess 1982 Semantics and the Density Question

**Task**: 107 - Chain Design Diagnostics for Representation Theorem
**Focus**: Does constructing a completeness countermodel over Q implicitly validate GGp -> Gp?
**Date**: 2026-04-24

## Executive Summary

The colleague's concern is **well-founded but applies to THIS PROJECT, not to Burgess**. Burgess uses STRICT G semantics (like this project) and constructs his countermodel over Q. But Burgess's axiom system J_0 is intended to be complete for ALL linear orders (K_0), not just dense ones. The resolution is subtle: Burgess's construction does NOT implicitly validate GGp -> Gp because the truth lemma (Claim 2.11) works differently from how the colleague assumed. The key insight is that the chronicle construction over Q produces a model where only FINITELY many points are realized, and the "density" of Q is used purely as a bookkeeping device for point insertion -- it does NOT make the resulting model dense in the sense required for GGp -> Gp to be forced.

**However**, this project's semantics differ from Burgess in a critical way (Until guard convention), which changes the analysis significantly.

## Finding 1: Burgess Uses STRICT G Semantics

From Burgess 1982 Section 1.2 (line 44 of the literature file):

```
V(G α) = {x : ∀y (x < y ⊃ y ∈ V(α))}
```

This is **strict G**: G φ at x means φ holds at all y with x < y (strictly greater). This matches the project's `all_future` definition:

```lean
| Formula.all_future φ => ∀ (s : D), t < s → truth_at M Omega τ s φ
```

Burgess does NOT use reflexive G (which would be x ≤ y). This is the same as the project's semantics.

## Finding 2: Burgess Constructs His Countermodel Over Q

From Section 2 (lines 194-199):

**(C0)** f is a function from a **subset of the rational numbers** to the set of all MCSs.

The domain is explicitly Q. New points are inserted at midpoints (e.g., z = (x+y)/2 in Lemma 2.9) or successor positions (y = x+1 in Lemma 2.10).

## Finding 3: WHY the Density Argument Does NOT Apply to Burgess

The colleague's argument was:
> On a dense model over Q with strict G, the truth lemma gives: GGp ∈ mcs(0) → for all t₁ > 0, Gp ∈ mcs(t₁) → for all t₂ > t₁, p true at t₂. By density, p true at ALL t > 0. So Gp true at 0.

This argument has a **critical flaw**: it assumes the truth lemma holds at ALL rational points. But Burgess's construction does NOT define f at all rationals. The domain of f is the UNION of finite sets dom(f_n). This is a **countable, possibly non-dense** subset of Q.

Specifically:
- Each (f_n, g_n) has **finite** domain (condition C0').
- The limit (f, g) has domain X = ∪ dom(f_n), which is countable.
- X inherits the ordering from Q but is NOT necessarily dense.

The truth lemma (Claim 2.11, line 241) says:

```
(+) x ∈ V(α) iff α ∈ f(x)
```

This holds for **x ∈ X** (the constructed domain), not for all of Q. The valuation V is defined on the linear order (X, <), and G quantifies over points in X:

```
V(G α) = {x ∈ X : ∀y ∈ X (x < y ⊃ y ∈ V(α))}
```

Since X need not be dense, GGp -> Gp is NOT forced by the construction. The model (X, <) could have gaps, making it behave like a discrete order in some places.

**Key insight**: Burgess uses Q as a "pool of available coordinates" for point insertion, not as the actual domain of the model. The model's domain is a sparse subset of Q.

## Finding 4: Burgess's Axiom System Does NOT Include Density

From Section 1.6 (lines 83-95), Burgess explicitly lists density as a SEPARATE extension:

| Postulates on < | Axioms for S, U |
|-----------------|-----------------|
| Density | F'⊤ |
| Discreteness | G'⊥ ∧ H'⊥ |

The base system J_0 includes NEITHER density nor discreteness axioms. J_0 is complete for K_0 = the class of ALL linear orders.

The density axiom F'⊤ (= "will arbitrarily soon be true") is only added when restricting to dense orders. It is NOT a theorem of J_0.

## Finding 5: Comparison with This Project's BX System

The project's BX axiom system differs from Burgess's J_0 in several important ways:

| Feature | Burgess J_0 | Project BX |
|---------|-------------|------------|
| G semantics | Strict (x < y) | Strict (t < s) |
| Until witness | Strict (x < y) | Strict (t < s) |
| Until guard | Open interval (x < z < y) | Half-open [t, s): t ≤ r, r < s |
| Density axiom | Not included | Not included |
| Seriality | Not included (no endpoints assumed) | BX1: ⊤ → F(⊤), BX1': ⊤ → P(⊤) |
| Until elimination | Not present | BX9: (φ U ψ) → (φ ∨ ψ) |
| Until eventuality | Derivable from U semantics | BX10: (φ U ψ) → F(ψ) |
| Temp 4 | Not included | temp_4: G(φ) → G(G(φ)) |

**Critical difference: Until guard convention.**

Burgess defines Until with an **open** guard interval:
```
V(U(α,β)) = {x : ∃y (x < y ∧ y ∈ V(α) ∧ ∀z (x < z < y ⊃ z ∈ V(β)))}
```
Guard: strictly between x and y, i.e., the open interval (x, y).

The project uses a **half-open** guard [t, s):
```lean
| Formula.untl φ ψ => ∃ s : D, t < s ∧ truth_at M Omega τ s ψ ∧
    ∀ r : D, t ≤ r → r < s → truth_at M Omega τ r φ
```
Guard: t ≤ r ∧ r < s, i.e., the interval [t, s).

This is a significant semantic difference. Under half-open guard, (φ U ψ) at t implies φ(t) (since t ∈ [t,s)), which is why BX9 (Until elimination) is an axiom. Under Burgess's open guard, (φ U ψ) at t does NOT imply φ(t).

## Finding 6: Does the Project's temp_4 (GG → G) Interact with Density?

The project includes `temp_4: G(φ) → G(G(φ))` as an axiom. Under strict G on ALL linear orders, this is valid:

- G(φ) at t means: for all s > t, φ(s).
- G(G(φ)) at t means: for all s₁ > t, for all s₂ > s₁, φ(s₂).
- If G(φ) at t, then for any s₁ > t, we need G(φ) at s₁, i.e., for all s₂ > s₁, φ(s₂). Since s₂ > s₁ > t implies s₂ > t, this follows from G(φ) at t.

So temp_4 (G → GG direction) is valid on all strict linear orders. Good.

The CONVERSE, GGp → Gp, is the density direction. Under strict G:
- GGp at t: for all s₁ > t, for all s₂ > s₁, p(s₂).
- Gp at t: for all s > t, p(s).
- Gap: GGp tells us p holds at all s₂ that are "> some s₁ > t", i.e., all s₂ that are at distance ≥ 2 "steps" from t. On a dense order, any s > t has some s₁ with t < s₁ < s, so s is at distance ≥ 2. On Z, the immediate successor of t is NOT at distance ≥ 2.

So **GGp → Gp is the density axiom for strict G** and is NOT in the BX system.

## Finding 7: Implications for the Completeness Construction

The colleague's concern about Q-based construction forcing GGp → Gp is **resolved by Burgess's technique**: the model domain is a sparse subset of Q, not all of Q.

For the project's completeness proof:
1. Using Burgess's chronicle-over-Q technique is safe -- it does NOT force density.
2. The half-open guard convention requires adapted versions of Burgess's lemmas (especially the counterexample lemmas 2.9, 2.10), but does not fundamentally change the construction.
3. The temp_4 axiom (G → GG) is already sound on all linear orders and does not interfere.
4. The GGp → Gp direction is NOT provable in BX (as intended) and NOT forced by the Q-based construction.

## Risks and Caveats

1. **Half-open guard adaptation**: Burgess's lemmas (2.4-2.8) are proved for open-guard Until. The project needs analogous lemmas for half-open guard. The self-accumulation (BX5) and absorption (BX6) axioms may need to play the role that A5a and A6a play in Burgess's system, but the guard difference could introduce subtle issues.

2. **BX9 and BX10 are extra axioms**: These axioms (Until elimination and Until-implies-F) are consequences of half-open guard semantics that are NOT present in Burgess. Any completeness proof must account for these being axioms rather than semantic consequences.

3. **Seriality**: Burgess's base system has no seriality axiom; the project's BX system does (BX1/BX1'). This means the constructed model must have no endpoints, which the Q-based construction naturally handles (rationals have no endpoints, and the construction can always add points beyond existing ones via Lemma 2.10).

## Conclusion

**The colleague's concern is a non-issue for Burgess's construction** because the countermodel domain is a sparse subset of Q, not all of Q. The density of Q serves only as a "coordinate space" allowing midpoint insertion, not as a property of the constructed model.

**For this project specifically**, the main challenge is not density but the adaptation of Burgess's open-guard Until lemmas to the project's half-open guard convention. This is where the completeness construction needs careful work.
