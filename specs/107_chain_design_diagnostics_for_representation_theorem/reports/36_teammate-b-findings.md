# Teammate B Findings: Alternative Approaches in the Literature

**Task**: 107 — Burgess chronicle construction for BX representation theorem
**Angle**: Alternative literature approaches for completeness of Until/Since tense logic under strict semantics
**Confidence**: HIGH (on the key conclusions)

---

## Key Findings

### 1. No Author Gives a Direct Until/Since Completeness Proof for Strict Semantics (HIGH CONFIDENCE)

After reading all available literature (Burgess 1982, Xu 1988, Reynolds 1992, Venema 1993, Verbrugge 2004, Hodkinson & Reynolds 2006), **no paper provides a completeness proof for Until/Since under strict (irreflexive) temporal semantics**. The situation:

- **Burgess 1982**: Works over arbitrary linear orders (no irreflexivity or transitivity assumed). His axioms A3a/A4a are valid for his semantic setup.
- **Xu 1988**: Extends Burgess to non-linear (branching) time. Same semantic setup — no assumptions on the frame relation beyond what the axioms enforce. His condition C1 is `∀xy ¬(x < y ∧ y < x)` (asymmetry), but NOT irreflexivity.
- **Reynolds 1992**: Works specifically with irreflexive linear orders (the reals), BUT uses the Burgess-Xu construction as a black box to get a rational model first, then applies Doets' theorem to transfer to the reals. The strict semantics in his paper is the same as ours. Crucially, **Reynolds does not need to modify Burgess's seed construction** — he uses it unchanged because the BX axioms are derivable in his system. His extra axioms (Prior-U, Prior-S, Sep) handle the real-number-specific properties.
- **Venema 1993**: Works with well-orderings (ω). Uses Burgess's completeness as a lemma, then applies Doets' theorem. Adds axiom W: `Fp → U(p, ¬p)`.
- **Verbrugge 2004**: Uses step-by-step construction for G/H only (NOT Until/Since). Not applicable.
- **Hodkinson & Reynolds 2006**: Survey chapter, no new completeness proofs.

**Conclusion**: The Burgess 1982 chronicle construction is THE standard approach for Until/Since completeness. Every subsequent author builds on it rather than replacing it. There is no alternative in the literature that avoids Burgess-style MCS/DCS construction.

### 2. Xu 1988's Simplified Seed Construction Avoids the Mixed A/C Problem (HIGH CONFIDENCE)

This is the most important finding. **Xu's Lemma 2.4 uses a dramatically simpler seed than Burgess's Lemma 2.6:**

**Burgess Lemma 2.6 seed** (our codebase's `burgess_D0`):
```
D₀ = {S(α,β) : α∈A, β∈B} ∪ B ∪ {¬δ} ∪ {U(γ,β) : γ∈C, β∈B}
```
This mixes elements from A (Until formulas), C (Since formulas), and B, creating the "mixed A/C problem" that is blocking our proof.

**Xu's Lemma 2.4 construction** (for the analogous case, counterexample to C5a):
```
Step 1: Let B* be such that B ⊆ B* and R(A, B*, C). [Extend B to maximal]
Step 2: Observe β ∉ B* (from the counterexample hypothesis).
Step 3: B* ∪ {¬β} is consistent. [Because β ∉ B*, and B* is an MCS-compatible DCS]
Step 4: Let D be an MCS extending B* ∪ {¬β}.
Step 5: By 2.3 and 2.1: r(A, ⊤, D) and r(D, ⊤, C).
Step 6: Complete by applying 2.0 to get R(A, B', D) and R(D, B'', C).
```

**The critical difference**: Xu's seed is simply `B* ∪ {¬β}` — there are NO Since or Until formulas mixed in. The consistency of `B* ∪ {¬β}` follows trivially from the maximality of B* (if β ∉ B*, then B* ∪ {¬β} is consistent by properties of DCS/MCS extensions).

**Why Xu can do this**: His Lemma 2.3 proves that whenever `R(A, B, C)` holds:
- `S(α, ⊤) ∈ B` for every `α ∈ A`
- `U(γ, ⊤) ∈ B` for every `γ ∈ C`

This means B already contains `P(α)` for all α ∈ A and `F(γ)` for all γ ∈ C. So the extended D (from `B* ∪ {¬β}`) inherits enough temporal information from B* to establish `r(A, ⊤, D)` and `r(D, ⊤, C)` — which can then be extended to full `R(A, B', D)` and `R(D, B'', C)`.

**However**, there is a key prerequisite: Xu's Lemma 2.3 uses axiom (3) — which is exactly Burgess's A3a. Under strict semantics, **A3a is not valid**, so Xu's Lemma 2.3 may not hold.

### 3. The Relationship Between Xu's Simplification and Our Setting (MEDIUM-HIGH CONFIDENCE)

Xu's simplification relies on the following chain:
1. `R(A, B, C)` holds (maximality of B).
2. Lemma 2.3: For α ∈ A and β ∈ B, `S(α, ⊤) ∈ B` (i.e., `P(α) ∈ B`).
3. This uses: from `α ∈ A` and `U(γ, β) ∈ A` (via r-relation), A3a gives `U(γ ∧ S(α, β), β) ∈ A`. Then if `S(α, ⊤) ∉ B`, maximality of B gives a contradiction.

**Under strict semantics**: A3a is replaced by BX4 (`connect_future: φ → G(P(φ))`). The question is whether we can derive the analogous result `P(α) ∈ B` when `R(A, B, C)` holds.

Consider: from `α ∈ A` and BX4: `G(P(α)) ∈ A`. For any `γ ∈ C`: `U(γ, β) ∈ A` for `β ∈ B`. Since `G(P(α)) ∈ A`, by BX3 (right monotonicity): `U(γ, β ∧ P(α)) ∈ A` (weakened). Actually, this direction is wrong — BX3 strengthens the guard, not weakens it.

The correct approach would need: BX2 (left monotonicity) to transfer `G(P(α))` into the guard position, or a different argument. This is non-trivial under strict semantics.

### 4. Verbrugge's Step-by-Step Method Does NOT Help (HIGH CONFIDENCE)

The Verbrugge/de Jongh/Veltman 2004 paper only handles G/H temporal logic (without Until and Since). Their step-by-step construction is much simpler than Burgess's because:
- G/H only need `Γ ≺ Δ` (i.e., `∀Gφ ∈ Γ, φ ∈ Δ`), which is the basic predecessor relation.
- Until/Since need the full 3-argument `r(A, B, C)` relation, which requires the DCS B to track what holds "in between" — this is fundamentally more complex.

Their method would need complete reinvention for Until/Since, and any such reinvention would likely converge on something Burgess-like.

### 5. Reynolds 1992's Approach: Potentially Relevant Insight About Irreflexivity (MEDIUM CONFIDENCE)

Reynolds 1992 is the only paper that explicitly works with irreflexive linear orders. His key insight for completeness over the reals is:

1. First build a rational model using Burgess-Xu (unchanged).
2. Then use Doets' theorem to transfer to the reals.

**For our setting**: We aren't trying to get real-number completeness — we want completeness for S5 + strict temporal over arbitrary linear orders. But Reynolds' paper reveals something important:

**The IRR rule** (`q ∧ H(¬q) → A` implies `A`, where q is new) is a standard technique for handling irreflexive frames. Gabbay introduced it, and it makes completeness proofs much easier by giving each point a "name." Reynolds explicitly argues against using it (his whole paper is about avoiding it), but he notes that it makes proofs enormously easier.

For our Lean formalization, the IRR rule is not relevant since we're working with BX axioms that encode strict semantics directly. But the principle that "irreflexive frames are hard and require extra axiom work" is confirmed by all literature.

### 6. The "Two-Seed" Approach From the Handoff Has Precedent in Xu (MEDIUM-HIGH CONFIDENCE)

The handoff suggested a "two-seed approach": instead of proving D₀ consistent directly, construct D as a Lindenbaum extension of the simpler seed `{¬δ} ∪ B`, then prove `burgessR3(A, B, D)` and `burgessR3(D, B, C)` hold for the resulting D.

**This is structurally similar to what Xu does.** Xu's seed is `B* ∪ {¬β}`, which is a maximal extension of B plus ¬β. The consistency proof is trivial because β ∉ B*.

The difference is that Xu establishes `r(A, ⊤, D)` and `r(D, ⊤, C)` from Lemma 2.3 (which uses A3a). For us, the analogous step needs to be done via BX axioms, specifically:
- `r(A, ⊤, D)` needs: `∀γ ∈ D, U(γ, ⊤) ∈ A` — i.e., `F(γ) ∈ A` for all γ ∈ D.
- Since D extends B, and `F(γ) ∈ A` for all γ ∈ B (from the r-relation), we need `F(¬δ) ∈ A`. This is exactly what `left_mono_contrapositive_neg_delta` gives us (already proved sorry-free).

So the path is:
1. Prove `F(¬δ) ∈ A` — DONE (already have this via `left_mono_contrapositive_neg_delta`).
2. Let D = Lindenbaum extension of `B ∪ {¬δ}` — consistency of `B ∪ {¬δ}` needs: if `δ ∈ DC(B)` then `δ ∈ B` (since B is a DCS), contradicting `δ ∉ B`. So `¬δ` is consistent with B. This is standard.
3. Prove `r(A, ⊤, D)`: For γ ∈ D, need `F(γ) ∈ A`. For γ ∈ B, this follows from the r-relation. For γ = ¬δ, this follows from step 1. For general γ ∈ D, need that D is a DCS containing B ∪ {¬δ}, so any consequence γ of B ∪ {¬δ} satisfies `F(γ) ∈ A`... **but this is exactly where the argument gets non-trivial** under strict semantics.

## Alternative Approaches Compared

| Approach | Source | Key Technique | Advantages | Disadvantages |
|----------|--------|---------------|-----------|---------------|
| Burgess D₀ seed | Burgess 1982 | Full seed with S/U/B/¬δ, consistency via A3a+A4a | Direct, complete proof | A3a/A4a invalid under strict semantics; "mixed A/C problem" |
| Xu simplified seed | Xu 1988 | `B* ∪ {¬β}` seed, r(A,⊤,D) via Lemma 2.3 | Much simpler seed, no mixed A/C | Lemma 2.3 uses A3a; needs adaptation for strict semantics |
| Two-seed (handoff) | Task 107 handoff | `B ∪ {¬δ}` seed, prove burgessR3 after | Simplest seed, consistency trivial | Need `r(A, ⊤, D)` for D = Lindenbaum(B ∪ {¬δ}) — non-trivial |
| IRR rule | Gabbay 1981 | Point names via fresh atoms | Makes proofs vastly easier | Non-orthodox; not compatible with BX axiom system |
| Venema completeness | Venema 1993 | Burgess + Doets' theorem | Clean for well-orderings | Only for ω, not arbitrary linear orders |
| Verbrugge step-by-step | Verbrugge 2004 | Construction by stages | Elegant for G/H | Only G/H, not Until/Since |

## Recommended Path

### Primary Recommendation: Xu-Style Simplified Seed with BX Adaptations

Follow Xu 1988's Lemma 2.4 architecture rather than Burgess's full D₀. Specifically:

1. **Use `B* ∪ {¬δ}` as the seed** (where B* = B since B is already maximal via BurgessR3Maximal).
   - Consistency: `δ ∉ B` implies `¬δ` is consistent with B. Standard DCS argument.

2. **Prove `r(A, ⊤, D)` using BX axioms** (the Xu Lemma 2.3 replacement):
   - For β ∈ B: `U(γ, β) ∈ A` for all γ ∈ C, so `F(β) ∈ A` (via BX10: until_F).
   - Actually need `U(γ, ⊤) ∈ A` for all γ ∈ C, i.e., `F(γ) ∈ A` for all γ ∈ C.
   - From burgessR3: for any β₀ ∈ B, `U(β₀, γ) ∈ A` for all γ ∈ C (our convention: guard-first).
   - BX10: `untl(β₀, γ) → F(γ)`. So `F(γ) ∈ A` for all γ ∈ C. ✓
   - Similarly, need `S(α, ⊤) ∈ D` for all α ∈ A: since D extends B, and B contains all β satisfying `r(A, B, C)`, use BX4 (`connect_future`).
   - **Key sub-problem**: show that `D ⊇ B` is enough to get `r(A, ⊤, D)`. This needs the relationship between "B has enough temporal content" and "any MCS extending B inherits the r-relation."

3. **Extend to BurgessR3Maximal** via `burgessR3Maximal_exists_from_seed`.

### Fallback Recommendation: Direct Burgess D₀ with BX Substitution

If the Xu-style simplification proves harder than expected, fall back to the plan's BX5+BX7 approach for proving `burgess_D0_consistent`. Teammate A is analyzing this path.

## Evidence/Examples

### Xu's Simplified C5a Counterexample Elimination

From Xu 1988, Lemma 2.4:
```
Given: r(A, B, C), ¬U(γ, β) ∈ A, γ ∈ C
Step 1: B* ← extend B to R(A, B*, C)
Step 2: β ∉ B* (from ¬U(γ,β) ∈ A and R-maximality)
Step 3: D ← MCS extending B* ∪ {¬β} [consistent because β ∉ B*]
Step 4: r(A, ⊤, D) by Lemma 2.3  ← KEY STEP, uses A3a
Step 5: r(D, ⊤, C) by Lemma 2.3  ← KEY STEP, uses A3a dual
Step 6: B', B'' ← extend B to R(A, B', D), R(D, B'', C) via Zorn
```

### Comparison: What Each Step Requires Under Strict Semantics

| Step | Burgess (A3a/A4a) | Strict Semantics (BX) |
|------|-------------------|-----------------------|
| Seed consistency | A4a gives U(β∧¬δ, β) ∈ A, then A3a gives joint consistency | BX5+BX7 derivation (plan task 1.2) |
| r(A, ⊤, D) | A3a directly: p ∧ U(q,r) → U(q∧S(p,r), r) | BX4 (connect_future) + BX10 (until_F) |
| r(D, ⊤, C) | Mirror of A3a | Mirror of BX4+BX10 |

## Confidence Level

- **No alternative to Burgess exists**: HIGH
- **Xu's simplification is real and significant**: HIGH
- **Xu-style approach can be adapted to strict semantics**: MEDIUM (the BX4/BX10 substitution for Lemma 2.3 needs careful working out)
- **Two-seed approach from handoff is viable**: MEDIUM-HIGH (structurally similar to Xu, with same BX adaptation challenge)
- **Verbrugge/Venema don't help**: HIGH
