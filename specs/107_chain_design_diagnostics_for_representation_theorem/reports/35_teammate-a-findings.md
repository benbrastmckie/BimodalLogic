# Teammate A Findings: Convention Mismatch Analysis

**Task**: 107 — Burgess chronicle construction
**Date**: 2026-04-27
**Angle**: Primary — convention swap analysis

## Key Findings

### Finding 1: THE HANDOFF'S MISMATCH CLAIM IS WRONG (HIGH CONFIDENCE)

The handoff (`phase1_d0_consistency_handoff.md`) claims:
- "Burgess: B provides EVENTS, C provides GUARDS"
- "Our code: B provides GUARDS, C provides EVENTS"

**This is backwards.** Careful reading of Burgess Section 1.2:

```
V(U(α,β)) = {x : ∃y(x<y ∧ y∈V(α) ∧ ∀z(x<z<y → z∈V(β)))}
```

In Burgess's `U(α,β)`: **α = EVENT** (first arg, at endpoint y), **β = GUARD** (second arg, at intermediate z).

In Burgess's `r(A, β, C) = ∀γ∈C, U(γ, β) ∈ A`: γ∈C is in EVENT position (first arg), **β∈B is in GUARD position** (second arg).

In our `burgessR(A, β, C) = ∀γ∈C, untl(β, γ) ∈ A`: **β∈B is in GUARD position** (first arg), γ∈C is in EVENT position (second arg).

**B-elements are GUARDS in BOTH conventions.** The difference is only argument order:
- Burgess: `U(event, guard)` — event first, guard second
- Our code: `untl(guard, event)` — guard first, event second

The semantic ROLE of B (guard/interval content) is identical.

### Finding 2: Xu 1988 Uses the SAME Convention as Burgess (HIGH CONFIDENCE)

Xu Section 1, item (iv):
```
(F,V) |= U(β,γ)[t] iff ∃t'(t<t' ∧ (F,V)|=β[t'] ∧ ∀t''(t<t''<t' → (F,V)|=γ[t'']))
```

So Xu's `U(β,γ)`: β = EVENT (first arg, at endpoint t'), γ = GUARD (second arg, at intermediate t'').

Xu's `r(A, β, C) = ∀γ∈C, U(γ, β) ∈ A` (Section 2, line 77): same as Burgess. β∈B = GUARD, γ∈C = EVENT.

Both Burgess and Xu: first=EVENT, second=GUARD. Our code: first=GUARD, second=EVENT. **All three have B = GUARD.**

### Finding 3: A4a Translates Correctly to Our Convention (HIGH CONFIDENCE)

Burgess A4a: `U(p,q) ∧ ¬U(p,r) → U(q∧¬r, q)`

In Burgess convention (first=event, second=guard): p=event, q=guard, r=guard. This says: if U holds with guard q but NOT with extended guard r, then U holds with event enriched to q∧¬r and guard q.

Translated to our convention (swap args): `untl(q,p) ∧ ¬untl(r,p) → untl(q, q∧¬r)`

This is: if untl holds with guard q and event p, but NOT with guard r and same event p, then untl holds with guard q and event q∧¬r.

**The maximality witness in our convention**: `BurgessR3Maximal(A,B,C)` with δ∉B gives `∃β₀∈B, γ₀∈C: ¬untl(β₀∧δ, γ₀) ∈ A`. We also have `untl(β₀, γ₀) ∈ A`.

Matching to translated A4a: q=β₀, p=γ₀, r=β₀∧δ. Output: `untl(β₀, β₀∧¬(β₀∧δ)) = untl(β₀, β₀∧¬δ)` ∈ A. After event weakening (BX3): `untl(β₀, ¬δ) ∈ A`, i.e., the guard β₀ holds until ¬δ is witnessed.

**This is exactly the formula needed for D₀ consistency!**

### Finding 4: A4a Is Not Sound Under Strict Semantics — But BX5+BX6+BX7 Subsume It (MEDIUM CONFIDENCE)

The codebase (`TemporalDerived.lean:528-538`) documents that A4a is "not valid under strict semantics" but "BX5 + BX6 (absorb_until) + BX7 (linear_until) subsume A4a's role."

The derivation path (sketch in our convention):
1. From `untl(β₀, γ₀) ∈ A`, BX5 gives `untl(β₀ ∧ untl(β₀,γ₀), γ₀) ∈ A` — guard enriched
2. From step 1 and `¬untl(β₀∧δ, γ₀) ∈ A`, apply BX7 (linearity) to the two Until formulas
3. BX7 gives three disjuncts; two can be eliminated because they imply `untl(β₀∧δ, γ₀)` (contradicting the negation)
4. The surviving disjunct gives `untl(β₀∧untl(β₀,γ₀), β₀∧¬δ)` or similar — which contains ¬δ in the EVENT position
5. BX10 (until_F) extracts F(β₀∧¬δ) ∈ A, giving the needed formula for D₀ consistency

**No convention swap is needed.** The BX axioms work in our convention.

### Finding 5: The Handoff's "No Corresponding Axiom" Claim Is Wrong (HIGH CONFIDENCE)

The handoff says: "Needed: something from U(p,q) AND not U(p AND r, q) → ??? — uses GUARD extension failure. This is NOT valid under half-open guard semantics."

This is wrong on two counts:
1. It conflates A4a's role: A4a handles guard failure (`¬U(p,r)`) not guard extension. The pattern `¬untl(β₀∧δ, γ₀)` is NOT "guard extension failure" — it's "guard strengthening failure," which is exactly what A4a handles.
2. The claim about half-open guard invalidity is about A4a itself, not about the BX substitutes. BX5+BX7 work under half-open guard (they are sound, documented at `TemporalDerived.lean:537-538`).

### Finding 6: No Convention Swap Is Needed (HIGH CONFIDENCE)

The convention difference (arg order) does NOT affect the proof structure:
- B = GUARD in all conventions (Burgess, Xu, ours)
- A5a and BX5 both enrich the GUARD (B-side)
- A4a and BX5+BX7 both handle guard-strengthening failure
- The D₀ seed set has the same structure in all conventions

A convention swap would be cosmetic (matching arg order to Burgess) but is NOT required for mathematical correctness. The existing convention follows the Kamp/standard CS convention which is used by most modern logic textbooks and formalization projects.

## Recommended Approach

**Do NOT swap conventions.** Instead:
1. Correct the handoff's wrong analysis
2. Proceed with the D₀ consistency proof using BX5+BX7 to derive the A4a-equivalent formula
3. The proof path is: maximality witness → BX5 (enrich guard) → BX7 (linearity, eliminate 2 of 3 disjuncts) → BX10 (extract F) → consistency criterion

**Estimated effort**: 8-12 hours for the D₀ consistency proof following this corrected analysis.

## Confidence Level

**High** for the convention analysis (verified line-by-line against Burgess 1.2, Xu 1(iv), and our Truth.lean).

**Medium** for the BX5+BX7 derivation path (the sketch is plausible but the disjunct elimination step needs careful formal verification — BX7's three disjuncts may not all be cleanly eliminable).
