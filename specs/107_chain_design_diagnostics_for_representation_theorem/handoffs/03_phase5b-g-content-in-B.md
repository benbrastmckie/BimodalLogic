# Handoff: Phase 5b — g_content(A) ⊆ B Breakthrough and Seed Consistency

## Session
- **Date**: 2026-04-29
- **Agent**: lean-implementation-agent (sess_1777475840_92906b)
- **Status**: Agent exhausted usage before implementing; key insight discovered but not yet coded

## The Single Remaining Sorry

```lean
-- PointInsertion.lean:306
private theorem splitting_seed_consistent {A B C : Set Formula}
    (h_mcs_A : SetMaximalConsistent A) (h_mcs_C : SetMaximalConsistent C)
    (h_r3m : BurgessR3Maximal A B C)
    (h_gc : g_content A ⊆ C)
    (β : Formula) (h_β_not_B : β ∉ B) :
    SetConsistent ({β.neg} ∪ g_content A ∪ h_content C) := by
  sorry
```

## Key Insight: g_content(A) ⊆ B via Maximality Argument

The agent discovered that `g_content(A) ⊆ B` is likely PROVABLE from `BurgessR3Maximal(A, B, C)`, which would make the seed trivially consistent since `g_content(A) ⊆ B ⊆ D`.

### The Argument

For any φ ∈ g_content(A) (i.e., G(φ) ∈ A), suppose φ ∉ B. Two cases:

**Case 1: {φ} ∪ B is inconsistent.** Then φ.neg is derivable from B, so φ.neg ∈ B (B is DCS).

**Case 2: {φ} ∪ B is consistent.** Then DC({φ} ∪ B) is a DCS properly extending B. Show it satisfies `burgessR3(A, DC({φ}∪B), C)`:

- **burgessRSet direction**: For any ψ ∈ DC({φ}∪B) and γ ∈ C, need `untl(ψ, γ) ∈ A`.
  - For ψ ∈ B: `untl(ψ, γ) ∈ A` from existing burgessRSet(A, B, C). ✓
  - For ψ derived from {φ}∪B: by `dc_delta_B_controlled`, ψ is equivalent to some (β₁ ∧ φ) where β₁ ∈ B. From `untl(β₁, γ) ∈ A` (burgessRSet) and `G(φ) ∈ A`, derive `untl(β₁ ∧ φ, γ) ∈ A` via **guard enrichment** (BX2 left monotonicity with G(φ)).

  Guard enrichment: `G(φ → (β₁ → β₁∧φ))` is a theorem (since `β₁ → (φ → β₁∧φ)` is propositional tautology, lift through G). Combined with `G(φ) ∈ A` and `untl(β₁, γ) ∈ A`: by BX2, `untl(β₁∧φ, γ) ∈ A`. Then by BX2 monotonicity (since `(β₁∧φ) → ψ`): `untl(ψ, γ) ∈ A`. ✓

- **burgessRSetSince direction**: By `burgessR_implies_burgessRSince` (Burgess Lemma 2.3, sorry-free in codebase), this follows automatically from the burgessRSet direction. ✓

So DC({φ}∪B) satisfies burgessR3(A, -, C), contradicting B's R3-maximality. Therefore {φ}∪B must be inconsistent, i.e., **φ.neg ∈ B**.

But φ.neg ∈ B gives: `untl(φ.neg, γ) ∈ A` for all γ ∈ C (burgessRSet). Combined with `G(φ) ∈ A`, guard enrichment gives `untl(φ.neg ∧ φ, γ) ∈ A`, i.e., `untl(⊥, γ) ∈ A`. By BX10: `F(γ) ∈ A` — fine. But `untl(⊥, γ)` means "eventually γ with ⊥ throughout the interval", which is satisfiable only if γ is at the immediate next point (empty guard). This is consistent but weird.

**Wait — the contradiction is that DC({φ}∪B) extends B AND satisfies burgessR3, violating maximality. So Case 2 is impossible. Therefore Case 1 holds: {φ}∪B is inconsistent, so φ.neg ∈ B.**

**But this means g_content(A) ⊄ B** when some φ ∈ g_content(A) has φ.neg ∈ B. This doesn't give φ ∈ B; it gives φ.neg ∈ B. So g_content(A) ⊆ B is NOT what we proved — we proved that for φ ∈ g_content(A), either φ ∈ B or φ.neg ∈ B (always the latter by the maximality argument).

### Revised Understanding

The maximality argument shows: **for φ ∉ B, the guard enrichment argument works and DC({φ}∪B) satisfies burgessR3, contradicting maximality — UNLESS the guard enrichment step fails**.

The guard enrichment step uses: from `untl(β₁, γ) ∈ A` and `G(φ) ∈ A`, derive `untl(β₁∧φ, γ) ∈ A`.

This requires BX2: `(φ → χ) ∧ G(φ → χ) → (untl(φ, ψ) → untl(χ, ψ))`. With φ = β₁, χ = β₁∧φ_gc, ψ = γ. Need `(β₁ → β₁∧φ_gc)` and `G(β₁ → β₁∧φ_gc)` in A. The pointwise implication `β₁ → β₁∧φ_gc` requires `φ_gc` at the current point. But we only have `G(φ_gc) ∈ A` (strict future), NOT `φ_gc ∈ A`.

**This is the same gap that blocked the Xu approach**: BX2 requires BOTH pointwise AND G-prefixed implications, but under irreflexive semantics we only have the G-prefix.

### The Real Blocker (Confirmed)

The guard enrichment `untl(β₁, γ) ∈ A ∧ G(φ) ∈ A → untl(β₁∧φ, γ) ∈ A` is equivalent to `left_mono_until_G` — the same axiom that was identified as missing in handoff 02_phase5b-blocker.md. Without it (or A4a as substitute), the maximality argument cannot show DC({φ}∪B) satisfies burgessR3.

### Connection to A4a

A4a (separation_until) provides a different route to the same goal. Instead of guard enrichment, Burgess's proof:

1. Extracts a maximality failure witness: β₀ ∈ B, γ₀ ∈ C with `¬untl(β₀∧β, γ₀) ∈ A`
2. Has `untl(β₀, γ₀) ∈ A` from burgessRSet
3. Applies BX5: `untl(β₀ ∧ untl(β₀, γ₀), γ₀) ∈ A`
4. Applies A4a to `untl(β₀ ∧ untl(β₀, γ₀), γ₀)` and `¬untl(β₀∧β, γ₀)`:
   - In BX convention: `untl(β₀∧untl(β₀,γ₀), γ₀) ∧ ¬untl(β₀∧β, γ₀) → untl(β₀∧untl(β₀,γ₀), (β₀∧untl(β₀,γ₀)) ∧ ¬(β₀∧β))`
   - Simplify: `untl(β₀∧untl(β₀,γ₀), β₀ ∧ untl(β₀,γ₀) ∧ β.neg) ∈ A`
5. Weakens guard via BX2: `untl(β₀, β₀ ∧ β.neg) ∈ A`
6. BX10: `F(β₀ ∧ β.neg) ∈ A`
7. Uses `forward_temporal_witness_seed_consistent` or `enriched_resolving_seed_consistent` with `F(β₀ ∧ β.neg) ∈ A` to show `{β.neg, β₀} ∪ g_content(A)` is consistent
8. BX13 (enrichment_until) folds h_content(C) elements into the seed

### Step-by-Step with BX Convention (Corrected)

**CRITICAL**: In BX convention, `untl(guard, event)`. Burgess uses `U(event, guard)`. Arguments swapped.

- Burgess `U(γ₀, β₀)` = BX `untl(β₀, γ₀)` — guard β₀, event γ₀
- Burgess `U(γ₀, β₀ ∧ β)` = BX `untl(β₀ ∧ β, γ₀)`
- BX5 on `untl(β₀, γ₀)`: `untl(β₀ ∧ untl(β₀, γ₀), γ₀)` — enriched guard
- A4a on `untl(β₀ ∧ untl(β₀,γ₀), γ₀)` and `¬untl(β₀∧β, γ₀)`:
  - A4a schema: `untl(q, p) ∧ ¬untl(r, p) → untl(q, q ∧ ¬r)`
  - With q = β₀ ∧ untl(β₀,γ₀), p = γ₀, r = β₀ ∧ β
  - Conclusion: `untl(β₀ ∧ untl(β₀,γ₀), (β₀ ∧ untl(β₀,γ₀)) ∧ ¬(β₀∧β))`
  - `= untl(β₀ ∧ untl(β₀,γ₀), β₀ ∧ untl(β₀,γ₀) ∧ β.neg)` (since β₀ ∧ ¬(β₀∧β) ↔ β₀ ∧ β.neg when β₀ is present)
- Weaken guard via BX2: `untl(β₀, β₀ ∧ β.neg) ∈ A` (since `β₀ ∧ untl(β₀,γ₀) → β₀`)
- Weaken event via BX3: can fold in g_content elements using G-information
- BX10: `F(β₀ ∧ β.neg) ∈ A`

### Remaining Gap: h_content(C) Inclusion

Even after establishing `F(β₀ ∧ β.neg) ∈ A`, the seed `{β.neg} ∪ g_content(A) ∪ h_content(C)` requires h_content(C) elements in D. The argument needs:

- BX13 (enrichment_until): `α ∧ untl(β₀, β₀ ∧ β.neg) → untl(β₀, (β₀ ∧ β.neg) ∧ snce(β₀, α))`
- For each α ∈ A (which includes h_content(C) ⊆ A by duality): the enriched event contains `snce(β₀, α)`
- `snce(β₀, α)` at the witness time gives P(α) at the witness — which puts α at a past time, NOT at the witness itself

This is the same gap identified in the handoff: P(h_j) ∈ D but h_j ∈ D is not guaranteed.

### Potential Resolution: Burgess's Full D₀ Seed

Burgess constructs the FULL seed D₀ = B ∪ {β.neg} ∪ {untl(β₀, γ) : β₀ ∈ B, γ ∈ C} ∪ {snce(β₁, α) : β₁ ∈ B, α ∈ A}. This seed includes the Until/Since formulas directly, not their content. The consistency of D₀ is proven via Lemma 2.2 using the enriched F-formula from A4a.

This approach avoids the g_content/h_content framework entirely — D₀ contains B (which gives the "interval" content) plus the negation β.neg plus all the r-relation formulas. The resulting MCS D has:
- B ⊆ D (gives DCS content)
- β.neg ∈ D
- untl(β₀, γ) ∈ D for all β₀ ∈ B, γ ∈ C (gives burgessRSet for D→C direction)
- snce(β₁, α) ∈ D for all β₁ ∈ B, α ∈ A (gives burgessRSetSince for A→D direction)

From these, BurgessR3Maximal(A, B', D) and BurgessR3Maximal(D, B'', C) follow by Zorn extension.

**This bypasses `burgessR3Maximal_from_g_content_sub` entirely** — instead of needing g_content(A) ⊆ D and g_content(D) ⊆ C (which require the bidirectional seed consistency), we directly place the r-relation formulas in D.

### Recommended Next Steps

1. **Restructure `lemma_2_6_splitting`** to use Burgess's D₀ seed instead of `{β.neg} ∪ g_content(A) ∪ h_content(C)`:
   - D₀ = B ∪ {β.neg} ∪ {untl(β₀, γ) : β₀ ∈ B, γ ∈ C} ∪ {snce(β₁, α) : β₁ ∈ B, α ∈ A}
   - Consistency via Lemma 2.2 + A4a enrichment
   - BurgessR3Maximal(A, B', D) via `burgessR3Maximal_exists_from_seed` with β₀ as seed (from untl(β₀, γ) ∈ D)
   - BurgessR3Maximal(D, B'', C) via `burgessR3Maximal_exists_from_seed` with β₁ as seed (from snce(β₁, α) ∈ D)

2. **Alternative**: Prove `g_content(A) ⊆ B` as a separate lemma (requires `left_mono_until_G` axiom, which is task 115's approach), then the existing seed `{β.neg} ∪ g_content(A) ∪ h_content(C)` reduces to `{β.neg} ∪ B_subset ∪ h_content(C)` where B_subset ⊆ B, making consistency trivial via `dcs_neg_union_consistent`.

3. **Alternative**: Add `left_mono_until_G` alongside A4a (both are sound). This directly enables guard enrichment and unblocks both the g_content(A) ⊆ B proof AND the Xu path.

## Files

- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean:306` — the sorry
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/RRelation.lean` — burgessR3Maximal infrastructure
- `literature/Burgess_1982_Axioms_for_tense_logic_Since_and_Until.md` — Lemma 2.6 proof
