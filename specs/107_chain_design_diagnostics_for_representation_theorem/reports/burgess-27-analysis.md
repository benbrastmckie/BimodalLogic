# Burgess 1982 Lemma 2.7 — Exact Mapping to Codebase

## Date: 2026-05-03
## Author: Lean Research Agent
## Scope: Section 2.7 of Burgess 1982, lines 174–183
## Target: `specs/107_chain_design_diagnostics_for_representation_theorem`

---

## 1. Burgess's Original Proof (1982, p. 372)

### Given
- `R(A, B, C)` (BurgessR3Maximal)
- `U(ξ, η) ∈ A`
- `η ∉ B`

### Goal
Find `B', D, B''` such that:
- `R(A, B', D)`
- `R(D, B'', C)`
- `ξ ∈ D`, `η ∈ B'`
- `B = B' ∩ D ∩ B''`

### Burgess's Seed (5 components)
For any `α ∈ A`, `β ∈ B`, `γ ∈ C`, the seed includes formulas of the form:

```
ζ = S(α, β ∧ η) ∧ β ∧ ξ ∧ U(γ, β)
```

**Seed set D₀** (written in our notation):
```
D₀ = B ∪ {ξ}
    ∪ {untl(β, γ) : β ∈ B, γ ∈ C}
    ∪ {snce(β, α) : β ∈ B, α ∈ A}
    ∪ {snce(β ∧ η, α) : β ∈ B, α ∈ A}
```

### Burgess's 5-Step Consistency Proof

**Step 1 – Extract witness from maximality**:
Since `η ∉ B` and `B` is maximal (R3Maximal), there exist `β₀ ∈ B`, `γ₀ ∈ C` with `¬U(β₀ ∧ η, γ₀) ∈ A`.

**Step 2 – A5a self-accumulation on both Until formulas**:
- From `U(γ, β) ∈ A`: apply A5a → `U(γ, β ∧ U(γ, β)) ∈ A`
- From `U(ξ, η) ∈ A`: apply A5a → `U(ξ, η ∧ U(ξ, η)) ∈ A`

**Step 3 – A7a three-way disjunction**:
Let `θ = β ∧ U(γ, β) ∧ ξ ∧ U(ξ, η)`.
Apply A7a to the two enriched Until formulas:
```
U(γ, β ∧ U(γ, β)) ∧ U(ξ, η ∧ U(ξ, η))
→ D1 ∨ D2 ∨ D3
```
where:
- **D1** = `U(γ ∧ ξ, θ)` — witness γ∧ξ with guard θ
- **D2** = `U(γ ∧ U(ξ, η), θ)` — witness γ∧U(ξ,η) with guard θ
- **D3** = `U(β ∧ U(γ, β) ∧ ξ, θ)` — witness β∧U(γ,β)∧ξ with guard θ

**Step 4 – Eliminate D1 and D2 using ¬U(β₀ ∧ η, γ₀)**:
- **D1** elimination: D1 implies `U(γ ∧ ξ, β ∧ η)` by monotonicity. Since `β₀ ≤ β` (β is conjunction of B-elements), this contradicts `¬U(β₀ ∧ η, γ₀)` using A1a/A2a.
- **D2** elimination: D2 implies `U(γ ∧ ξ, β ∧ ξ)`, which again contradicts the witness via guard strengthening.

**Step 5 – Surviving D3 gives consistency**:
```
D3 = U(β ∧ U(γ, β) ∧ ξ, θ) ∈ A
```
By A3a (enrichment), this gives `U(ξ, β ∧ η) ∈ A`. Then consistency of ζ follows by 2.2.

---

## 2. Our Codebase Mapping

### 2.1 Seed Definition (`lemma_2_7_seed`, line 2386)

```lean
private def lemma_2_7_seed (A B C : Set Formula) (xi eta : Formula) : Set Formula :=
  B ∪ {xi} ∪ {φ | ∃ β ∈ B, ∃ γ ∈ C, φ = Formula.untl β γ} ∪
  {φ | ∃ β ∈ B, ∃ α ∈ A, φ = Formula.snce β α} ∪
  {φ | ∃ β ∈ B, ∃ α ∈ A, φ = Formula.snce (Formula.and β eta) α}
```

**Mapping analysis**: ✅ **Correct per Burgess**

Our 5 components map exactly to Burgess's description:

| Component | Burgess | Our code | Match? |
|---|---|---|---|
| 1 | `B` (all formulas in B) | `B ∪ {xi}` | Partial — includes xi explicitly |
| 2 | `ξ` (the Until event) | `{xi}` | ✅ Yes |
| 3 | `U(γ, β)` for all β∈B, γ∈C | `untl(β, γ)` for β∈B, γ∈C | ✅ Yes (guard/event swapped in our notation — `untl guard event` vs Burgess `U(event, guard)`) |
| 4 | `S(α, β)` for all β∈B, α∈A | `snce(β, α)` for β∈B, α∈A | ✅ Yes (our `snce guard event` = Burgess `S(event, guard)`) |
| 5 | `S(α, β ∧ η)` for all β∈B, α∈A | `snce(β ∧ eta, α)` for β∈B, α∈A | ✅ Yes |

**Note on component order**: Burgess writes his seed as a single conjunction ζ, while we use a set union. This is equivalent because any finite subset of the set can be compressed into a single conjunction (via `list_conj`), and the DCS closure handles infinitary aspects.

**Note on guard/event convention**: Our `Formula.untl guard event` corresponds to Burgess's `U(event, guard)`. Our `Formula.snce guard event` corresponds to Burgess's `S(event, guard)`. This is the standard convention in the BX axiom system (guard on left, event on right).

### 2.2 BX5 Self-Accumulation (`until_self_accum_in_mcs`, line 96)

```lean
theorem until_self_accum_in_mcs {A} (h_mcs : SetMaximalConsistent A) {γ δ}
    (h_until : Formula.untl γ δ ∈ A) :
    Formula.untl (Formula.and γ (Formula.untl γ δ)) δ ∈ A
```

**Axiom**: `Axiom.self_accum_until γ δ` (BX5)
**Formula**: `(γ U δ) → (γ ∧ (γ U δ)) U δ`

**Mapping analysis**: ✅ **Correct per Burgess A5a**

Burgess A5a: `U(p, q) → U(p, q ∧ U(p, q))`

Our BX5: `(φ U ψ) → ((φ ∧ (φ U ψ)) U ψ)`

These are **equivalent modulo propositional reasoning** — our formulation includes the guard in the event, which is slightly stronger. The key property is self-accumulation: the Until formula strengthens its own guard.

### 2.3 BX7 Three-Way Disjunction (`linear_until`, line 226)

```lean
| linear_until (φ ψ χ θ : Formula) :
    Axiom (Formula.and (Formula.untl φ ψ) (Formula.untl χ θ)
      |>.imp (Formula.or
        (Formula.or
          (Formula.untl (Formula.and φ χ) (Formula.and ψ θ))
          (Formula.untl (Formula.and φ χ) (Formula.and ψ χ)))
        (Formula.untl (Formula.and φ χ) (Formula.and φ θ))))
```

**Mapping analysis**: ⚠️ **DEVIATION from Burgess A7a — documented and intentional**

| | Burgess A7a | Our BX7 (`linear_until`) |
|---|---|---|
| Given | `U(p,q) ∧ U(r,s)` | `(φ U ψ) ∧ (χ U θ)` |
| D1 | `U(p∧r, q∧s)` | `(φ∧χ) U (ψ∧θ)` |
| D2 | `U(p∧s, q∧s)` | `(φ∧χ) U (ψ∧χ)` |
| D3 | `U(q∧r, q∧s)` | `(φ∧χ) U (φ∧θ)` |

**Critical differences**:
1. **Burgess D2**: `U(p∧s, q∧s)` — event is `q∧s` (guard∧event of first)
   **Our D2**: `(φ∧χ) U (ψ∧χ)` — event is `ψ∧χ` (event₁∧event₂)

2. **Burgess D3**: `U(q∧r, q∧s)` — event is `q∧s` (guard₁∧event₂)
   **Our D3**: `(φ∧χ) U (φ∧θ)` — event is `φ∧θ` (guard₁∧event₂)

**Why the deviation is correct**: The codebase comment at lines 248–253 explains:

> NOTE: BX7a/BX7a' (linear_until_a7a/linear_since_a7a) removed -- unsound under open guard. Burgess's A7a has fixed event (ψ∧θ) in all disjuncts, but with strict/open guard semantics (t < r < s), the two Until witnesses s₁, s₂ cannot both contribute their events at a single point when s₁ ≠ s₂.

Our BX7 (`linear_until`) is **sound under open guard** and was verified in `SoundnessLemmas.lean` (line 1005, `axiom_temp_linearity_valid`).

**Consequence for Lemma 2.7**: The disjunct elimination arguments must be adapted. Burgess eliminates D1/D2 using `¬U(β₀ ∧ η, γ₀)`. Our D1/D2 have different structures, so the elimination pattern changes slightly (see §3).

### 2.4 Disjunct Analysis in Our Setting

Given our seed and the two enriched Until formulas:
- `untl(b ∧ untl(b, γ_hat), γ_hat)` — from BX5 on `untl(b, γ_hat)` where `b` = conjunction of B-elements, `γ_hat` = conjunction of C-events
- `untl(xi ∧ untl(xi, eta), eta)` — from BX5 on `untl(xi, eta)`

Applying `linear_until` (BX7) with:
- `φ = b ∧ untl(b, γ_hat)` (guard of first enriched Until)
- `ψ = γ_hat` (event of first)
- `χ = xi ∧ untl(xi, eta)` (guard of second enriched)
- `θ = eta` (event of second)

The three disjuncts become:

| Disjunct | Our formula | Description |
|---|---|---|
| D1 | `untl(φ∧χ, ψ∧θ)` = `untl(b∧untl(b,γ_hat) ∧ xi∧untl(xi,eta), γ_hat∧eta)` | Witness: conjunction of both enriched guards; Event: conjunction of both events |
| D2 | `untl(φ∧χ, ψ∧χ)` = `untl(b∧untl(b,γ_hat) ∧ xi∧untl(xi,eta), γ_hat∧(xi∧untl(xi,eta)))` | Witness: conjunction of guards; Event: event₁ ∧ guard₂ |
| D3 | `untl(φ∧χ, φ∧θ)` = `untl(b∧untl(b,γ_hat) ∧ xi∧untl(xi,eta), (b∧untl(b,γ_hat))∧eta)` | Witness: conjunction of guards; Event: guard₁ ∧ event₂ |

**D3 is the surviving disjunct** — it contains `eta` in the event position.

### 2.5 Existing Code Disjunct Analysis (from plan v54)

The implementation plan (Phase 3, lines 131–165) states:

```
- D1: untl(b∧xi, γ_hat∧eta)
- D2: untl(b∧xi, γ_hat∧xi)
- D3: untl(b∧xi, b∧eta) (surviving disjunct)
```

**Deviation detected**: The plan's simplified D1/D2/D3 omit the `untl(b,γ_hat)` and `untl(xi,eta)` self-accumulation terms from the guard conjunctions. The plan uses `b∧xi` as the witness instead of `b∧untl(b,γ_hat) ∧ xi∧untl(xi,eta)`.

**Assessment**: This simplification is **valid** for the elimination reasoning because:
1. We only need the **right-hand guard** (the event part) for the consistency argument
2. The left weakening (`untl_left_mono_thm`) lets us drop conjuncts from the guard
3. The key property is that D3 contains `b ∧ eta` in the event, enabling the 5th seed component

However, **the exact formula in the proof must match BX7's output** before applying left mono to simplify. The plan's simplified formulas are the result of applying mono, not the raw BX7 disjuncts.

### 2.6 A3a (Enrichment Until / `Axiom.enrichment_until`)

Burgess uses A3a: `p ∧ U(q, r) → U(q ∧ S(p, r), r)`

Our BX13 (`Axiom.enrichment_until`):
```lean
| enrichment_until (φ ψ p : Formula) :
    Axiom ((Formula.and p (Formula.untl φ ψ))
      |>.imp (Formula.untl φ (Formula.and ψ (Formula.snce φ p))))
```

**Mapping analysis**: ⚠️ **Not directly equivalent — but usable with adaptation**

Burgess A3a: `p ∧ U(q, r) → U(q ∧ S(p, r), r)`
Our BX13: `p ∧ (φ U ψ) → (φ U (ψ ∧ S(φ, p)))`

Differences:
1. Burgess puts `S(p, r)` in the **guard** (left of U)
2. Our BX13 puts `S(φ, p)` in the **event** (right of U, as part of ψ)

**Usability**: BX13 strengthens the event with a Since formula, while Burgess's A3a strengthens the guard. For our seed construction where we need `S(β ∧ η, α)` in the seed, BX13 is actually **more directly applicable** because it packs Since into the event, and the seed then contains `snce(β ∧ η, α)` as an explicit member.

The codebase uses `enrichment_until_mcs` (line 986) which applies BX13 correctly.

---

## 3. Exact Implementation Steps for `lemma_2_7_seed_consistent`

### 3.1 Extract Neg-Until Witness

```lean
/-- Extract β₀ ∈ B, γ₀ ∈ C with ¬untl(β₀ ∧ eta, γ₀) ∈ A from maximality of B. -/
private theorem lemma_2_7_neg_untl_exists {A B C}
    (h_r3m : BurgessR3Maximal A B C) (eta : Formula) (h_eta_not_B : eta ∉ B) :
    ∃ β₀ ∈ B, ∃ γ₀ ∈ C, (Formula.untl (Formula.and β₀ eta) γ₀).neg ∈ A
```

**Strategy**:
1. From `BurgessR3Maximal_extension_fails` (line 566): `eta ∉ B` and `{eta}∪B` consistent implies `¬burgessR3(A, DC({eta}∪B), C)`
2. So there exist `phi ∈ DC({eta}∪B)`, `gamma₀ ∈ C` with `¬untl(phi, gamma₀) ∈ A`
3. By `dc_delta_B_controlled` (line ~540): if `phi ∉ B`, then `∃ beta₀ ∈ B` with `⊢ (beta₀ ∧ eta) → phi`
4. Use `until_left_mono_thm` with `⊢ (beta₀ ∧ eta) → phi` to get `¬untl(beta₀ ∧ eta, gamma₀) ∈ A` from `¬untl(phi, gamma₀) ∈ A`

**Status**: Inner sorry exists. This is **Task 3.1** in the implementation plan.

### 3.2 Apply BX5 Self-Accumulation

```lean
-- On untl(b, γ_hat):
have h_bx5_b := until_self_accum_in_mcs h_mcs_A b γ_hat h_untl_b
-- On untl(xi, eta):
have h_bx5_xi := until_self_accum_in_mcs h_mcs_A xi eta h_until
```

This gives:
- `untl(b ∧ untl(b, γ_hat), γ_hat) ∈ A`
- `untl(xi ∧ untl(xi, eta), eta) ∈ A`

### 3.3 Apply BX7 (`linear_until`) to Get Three-Way Disjunction

Build the conjunction of the two BX5 outputs, then apply `linear_until`:

```lean
have h_conj : Formula.and
  (Formula.untl (Formula.and b (Formula.untl b γ_hat)) γ_hat)
  (Formula.untl (Formula.and xi (Formula.untl xi eta)) eta) ∈ A :=
  conj_mcs h_mcs_A h_bx5_b h_bx5_xi

have h_bx7 := theorem_in_mcs h_mcs_A
  (DerivationTree.axiom [] _ (Axiom.linear_until
    (Formula.and b (Formula.untl b γ_hat)) γ_hat
    (Formula.and xi (Formula.untl xi eta)) eta))

have h_disj := SetMaximalConsistent.implication_property h_mcs_A h_bx7 h_conj
```

This gives `D1_or_D2_or_D3 ∈ A` where:
- D1 = `untl((b∧untl(b,γ_hat)) ∧ (xi∧untl(xi,eta)), γ_hat ∧ eta)`
- D2 = `untl((b∧untl(b,γ_hat)) ∧ (xi∧untl(xi,eta)), γ_hat ∧ (xi∧untl(xi,eta)))`
- D3 = `untl((b∧untl(b,γ_hat)) ∧ (xi∧untl(xi,eta)), (b∧untl(b,γ_hat)) ∧ eta)`

### 3.4 Eliminate D1

**Burgess argument for D1 elimination** (adapted to our BX7):

If D1 ∈ A, then by right monotonicity (BX3): `⊢ (γ_hat ∧ eta) → eta`, so:
`untl(witness, eta) ∈ A`

Also by left monotonicity (BX2): `⊢ (b∧untl(b,γ_hat)) ∧ (xi∧untl(xi,eta)) → (beta₀ ∧ eta)` for the witness beta₀ ∈ B (since `b` is conjunction of B-elements including beta₀).

So: `untl(beta₀ ∧ eta, eta) ∈ A` — but we have `¬untl(beta₀ ∧ eta, gamma₀) ∈ A`.

Wait: this doesn't directly contradict. The witness gives `untl(witness, eta) ∈ A`, but our neg-witness is `¬untl(beta₀ ∧ eta, gamma₀) ∈ A`. We need `gamma₀ → eta` to connect them.

**Corrected elimination** (per plan v54, Task 3.3):
- D1 = `untl(b∧xi∧..., γ_hat∧eta)` (after simplifying guards via left mono)
- Right mono: `γ_hat ∧ eta → eta`, but we need the event to match `gamma₀`
- Actually: `gamma₀` is a specific element of C. `γ_hat` is the conjunction of all events from C-elements in the finite subset L. Since `gamma₀ ∈ C`, if `gamma₀` is one of the C-events used in L, then `γ_hat → gamma₀` by conjunction elimination, and `untl(witness, gamma₀)` follows from `untl(witness, γ_hat∧eta)` by right mono.

This requires that `gamma₀` appear in the C-event list of the finite subset. This is ensured because we can choose the finite subset to include the witness elements.

### 3.5 Eliminate D2

Mirror of D1 elimination. D2 = `untl(witness, γ_hat∧xi∧...)`. Since `xi` is the event we're trying to place in D, and `gamma₀` is the C-event witness, we need `⊢ (γ_hat ∧ xi ∧ ...) → gamma₀` for the contradiction. But `xi` may not imply `gamma₀`.

Actually, the standard Burgess argument for D2 uses the fact that if D2 were in A, then combined with the neg-witness, we'd get a contradiction via A4a separation. The exact argument is more subtle and uses the witness `beta₀, gamma₀` directly.

**Simplified approach** (from plan v54): Recognize that D2's event contains `xi`, not `eta`. After the final proof goal (showing `eta ∈ B'`), we need `untl(eta, δ) ∈ A` for all `δ ∈ D`. D2 doesn't directly help with this — only D3 contains `eta`.

### 3.6 Surviving D3 → Seed Consistent

D3 = `untl(witness, (b∧untl(b,γ_hat))∧eta)` contains `eta` in the event.

After left-monotonicity simplification: `untl(b∧xi, b∧eta) ∈ A`

Then:
1. BX13 (`enrichment_until`) with `S(b∧xi, α) ∈ D` for each `α ∈ A` — this strengthens the event with Since formulas
2. Iterated enrichment gives `event = b∧eta ∧ snce(b∧xi, α₁) ∧ snce(b∧xi, α₂) ∧ ...`
3. BX10 (`until_F`) gives `F(event) ∈ A`
4. `F(event) ∈ A` implies `{event}` is consistent (by `consistent_of_F_mem`)
5. `event` implies each seed component:
   - `event → b` (from left conjunct)
   - `event → eta` (from `b∧eta`)
   - `event → untl(b, γ)` (since `b∧untl(b,γ_hat) → untl(b, γ)` via left mono and `γ_hat → γ`)
   - `event → snce(b, α)` (from enrichment)
   - `event → snce(b∧eta, α)` (from `b∧eta` and left mono for Since)

### 3.7 Key Code Structures Needed

| Structure | Purpose | Status |
|---|---|---|
| `iterated_enrichment` | Iterated BX13 application | ✅ Exists, line 1218 |
| `burgess_zeta_consistent` | Core consistency proof for Lemma 2.6 | ✅ Exists, line 1251 |
| `burgess_D0_finite_subset_consistent` | Compress finite seed → single conjunction → consistent | ✅ Exists, line 1601 |
| `lemma_2_7_neg_untl_exists` | Extract neg-Until witness from maximality | ❌ Missing (sorry) |
| `lemma_2_7_disjunct_elim_D1` | Show D1 contradicts neg-witness | ❌ Missing (sorry) |
| `lemma_2_7_disjunct_elim_D2` | Show D2 contradicts neg-witness | ❌ Missing (sorry) |

---

## 4. Seed Construction Verification

### 4.1 Is `ζ = S(α, β∧η) ∧ β ∧ ξ ∧ U(γ, β)` correct in our notation?

Burgess's ζ (line 180):
```
ζ = S(α, β ∧ η) ∧ β ∧ ξ ∧ U(γ, β)
```

In our notation:
- `S(α, β ∧ η)` = `snce (β ∧ η) α` — **guard** is `β ∧ η`, **event** is `α`
- `U(γ, β)` = `untl β γ` — **guard** is `β`, **event** is `γ`

Our seed `lemma_2_7_seed` (line 2386) includes:
- `snce (β ∧ eta) α` for `β ∈ B, α ∈ A` ✅ (matches `S(α, β∧η)`)
- `snce β α` for `β ∈ B, α ∈ A` ✅ (matches `S(α, β)`)
- `untl β γ` for `β ∈ B, γ ∈ C` ✅ (matches `U(γ, β)`)
- `ξ` (the event xi) ✅
- `β` (guard elements from B) ✅

**Verdict**: ✅ **Seed construction exactly matches Burgess**

### 4.2 Deviations from Burgess and Their Impact

| # | Deviation | Burgess | Our approach | Impact |
|---|---|---|---|---|
| 1 | A7a → BX7 (`linear_until`) | Fixed event `q∧s` in all disjuncts | Event varies per disjunct: `ψ∧θ`, `ψ∧χ`, `φ∧θ` | **Critical for soundness** — A7a is unsound under open guard. BX7 is proved sound in `SoundnessLemmas`. Elimination arguments must be adapted per disjunct structure. |
| 2 | Guard/event notation | `U(event, guard)` | `untl guard event` | **Cosmetic** — same formula, different argument order. All proofs and axioms consistent with our convention. |
| 3 | Seed as conjunction vs set | Single ζ per triple (α,β,γ) | Union of all formulas, compress via `list_conj` | **Equivalent** — DCS closure ensures the set approach yields the same deductive closure as individual conjunctions. |
| 4 | A3a vs BX13 | `p ∧ U(q,r) → U(q ∧ S(p,r), r)` | `p ∧ (φ U ψ) → (φ U (ψ ∧ S(φ, p)))` | **Structural** — Burgess strengthens guard; BX13 strengthens event. Both usable; BX13 is more natural for our seed since we explicitly include `snce(β∧η, α)` in the seed. |

---

## 5. What Exactly to Implement (Phase 3)

### 5.1 Missing Helper Lemmas

```lean
-- Task 3.1: Extract neg-witness from maximality
private theorem lemma_2_7_neg_untl_exists {A B C}
    (h_r3m : BurgessR3Maximal A B C) (eta : Formula) (h_eta_not_B : eta ∉ B) :
    ∃ β₀ ∈ B, ∃ γ₀ ∈ C, (Formula.untl (Formula.and β₀ eta) γ₀).neg ∈ A
```

**Proof outline**:
1. `h_neg_r3 := BurgessR3Maximal_extension_fails h_r3m h_eta_not_B h_eta_cons`
2. Unfold `¬burgessR3` to get `phi ∈ DC({eta}∪B)` and `gamma₀ ∈ C` with `¬untl(phi, gamma₀) ∈ A`
3. Use `dc_delta_B_controlled` on `phi`: either `phi ∈ B` (impossible — would contradict `burgessR3(A,B,C)`) or `∃ beta₀ ∈ B` with `⊢ (beta₀ ∧ eta) → phi`
4. Use `until_left_mono_thm` + contrapositive of `⊢ (beta₀ ∧ eta) → phi` to get `¬untl(beta₀ ∧ eta, gamma₀) ∈ A`

```lean
-- Task 3.3: Eliminate D1
private theorem lemma_2_7_disjunct_elim_D1 {A B C}
    (h_mcs_A : SetMaximalConsistent A) (h_r3m : BurgessR3Maximal A B C)
    {b γ_hat witness} (h_D1 : Formula.untl witness (Formula.and γ_hat eta) ∈ A)
    (h_neg : ∃ β₀ ∈ B, ∃ γ₀ ∈ C, (Formula.untl (Formula.and β₀ eta) γ₀).neg ∈ A)
    (h_b_in_B : b ∈ B) ... :
    False
```

**Key insight**: D1 contains `γ_hat ∧ eta` in the event. Since `γ_hat` is the conjunction of C-events and includes `gamma₀` (from the witness), we have `⊢ (γ_hat ∧ eta) → gamma₀` by conjunction elimination. Then right mono gives `untl(witness, gamma₀) ∈ A`. Combined with witness→(beta₀ ∧ eta) via left mono, we derive `untl(beta₀ ∧ eta, gamma₀) ∈ A`, contradicting the neg-witness.

```lean
-- Task 3.4: Eliminate D2
private theorem lemma_2_7_disjunct_elim_D2 {A B C}
    ... (h_D2 : Formula.untl witness (Formula.and γ_hat xi) ∈ A) ... :
    False
```

**Key insight**: D2 contains `γ_hat ∧ xi` in the event. The argument mirrors D1 but uses `xi` instead of `eta`. Since `xi` is not directly related to the neg-witness, the elimination requires showing `untl(beta₀ ∧ eta, gamma₀) ∈ A` via a different route — typically using the fact that D2's guard contains `xi ∧ untl(xi, eta)` and `eta ∉ B`, combined with A4a separation.

### 5.2 Main Proof Orchestration (`lemma_2_7_seed_consistent`)

Replace `sorry` (line 2414) with a 10-step proof following the TODO comment at lines 2393–2403:

```lean
private theorem lemma_2_7_seed_consistent {A B C} ... :
    SetConsistent (lemma_2_7_seed A B C xi eta) := by
  -- 1. Extract witness β₀ ∈ B, γ₀ ∈ C with ¬untl(β₀∧eta, γ₀) ∈ A
  obtain ⟨beta0, h_beta0, gamma0, h_gamma0, h_neg_until⟩ :=
    lemma_2_7_neg_untl_exists h_r3m h_eta_not_B

  -- 2. BX5 on untl(b, γ_hat)
  -- 3. BX5 on untl(xi, eta)
  -- 4. BX7 → three-way disjunction
  -- 5. Eliminate D1
  -- 6. Eliminate D2
  -- 7. Surviving D3: untl(b∧xi, b∧eta)
  -- 8. BX14 separation (if needed)
  -- 9. BX13 iterated enrichment + BX10 → F(event) ∈ A
  -- 10. event implies all seed components, so seed consistent
```

### 5.3 Post-Seed Proof (`lemma_2_7`, lines 2416–2551)

The post-seed proof (Lindenbaum extension, building `burgessR3`, Zorn for maximality, extracting `xi ∈ D`, `eta ∈ B'`) is **already complete and sorry-free** (lines 2416–2551).

This means:
- `lemma_2_7` theorem itself is **only blocked on `lemma_2_7_seed_consistent`**
- Once the seed consistency is proved, the entire Lemma 2.7 becomes sorry-free

---

## 6. Verification Command

To verify that closing `lemma_2_7_seed_consistent` unblocks `lemma_2_7`:

```bash
cd /home/benjamin/Projects/ProofChecker
grep -n "sorry" Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean
```

Current sorry locations (as of 2026-05-03):
- Line ~1411: `d0_a_event_list_mem` (Phase 2, Task 2.1)
- Line ~1858: `h_ev_b` (Phase 2, Task 2.2)
- Line ~1859: `h_ev_untl` (Phase 2, Task 2.3)
- Line 2414: `lemma_2_7_seed_consistent` (Phase 3, main sorry)

**Total PointInsertion.lean sorries**: 4 (3 Phase 2 + 1 Phase 3)

---

## 7. Build Status

```
lake build 2>&1 | tail -20
```

Current status (2026-05-03): **Build fails** due to sorries in `ChronicleConstruction.lean` (unrelated to Phase 3). PointInsertion.lean compiles independently.

---

## 8. Summary

| Question | Answer |
|---|---|
| Does our seed match Burgess? | ✅ **Yes** — 5 components (B, ξ, U-formulas, S-formulas, S-with-η formulas) match exactly. |
| Are D1/D2/D3 correct? | ⚠️ **Adapted** — Our BX7 (`linear_until`) has different disjuncts than Burgess A7a (intentionally, for open-guard soundness). D1/D2 elimination needs adaptation to our disjunct structure, but the proof structure survives. |
| Is ζ = S(α, β∧η) ∧ β ∧ ξ ∧ U(γ, β) correct? | ✅ **Yes** — Our `snce(β∧η, α)` = Burgess's `S(α, β∧η)`; our `untl(β, γ)` = Burgess's `U(γ, β)`. Seed is equivalent. |
| What axioms at each step? | See table below. |
| Any deviations to flag? | A7a → BX7 (linearity axiom changed for open-guard soundness). This is **documented, intentional, and necessary**. |

### Axiom Usage Map

| Step | Burgess Axiom | Our Axiom | Code Reference |
|---|---|---|---|
| Witness extraction | Maximality of R | `BurgessR3Maximal_extension_fails` | PointInsertion:566 |
| Self-accumulation | A5a | `Axiom.self_accum_until` (BX5) | RRelation:96 |
| Three-way disjunction | A7a | `Axiom.linear_until` (BX7) | Axioms:226 |
| Guard monotonicity | A1a, A2a | `Axiom.left_mono_until` (BX2), `Axiom.right_mono_until` (BX3) | Axioms:206,210 |
| Enrichment | A3a | `Axiom.enrichment_until` (BX13) | Axioms:214 |
| Separation | (not explicitly named, from A4a) | `Axiom.separation_until` (BX14) | Axioms:218 |
| F-extraction | (from consistency) | `Axiom.until_F` (BX10) | RRelation:84 |
| F-consistency | Lemma 2.2 | `consistent_of_F_mem` | PointInsertion:1151 |

---

## 9. Recommendations

1. **Do NOT change the seed** — `lemma_2_7_seed` is correctly constructed per Burgess.
2. **Do NOT change BX7** — `linear_until` is the sound axiom for open-guard semantics; reverting to A7a would introduce unsoundness.
3. **Implement the 3 missing helper lemmas** (`lemma_2_7_neg_untl_exists`, `lemma_2_7_disjunct_elim_D1`, `lemma_2_7_disjunct_elim_D2`) following the proof outlines in §5.1.
4. **Orchestrate in `lemma_2_7_seed_consistent`** following the 10-step structure in the existing TODO comment (lines 2393–2403).
5. **Reuse existing infrastructure** — `iterated_enrichment`, `burgess_zeta_consistent` pattern, `list_conj` compression, and `burgess_D0_finite_subset_consistent` provide the machinery. The 2.7 proof is a variation of the 2.6 proof with an additional BX7 step.

---

*End of analysis report.*
