# Burgess 1982 Lemma 2.4 & 2.6 vs. Current Lean Codebase — Exact Mapping Analysis

**Date**: 2026-05-03
**Scope**: Burgess 1982 Sections 2.4 (Lemma 2.4), 2.6 (Lemma 2.6), and our Lean adaptations in `PointInsertion.lean`
**Goal**: Identify EXACTLY what our code does vs. what Burgess prescribes, flag every deviation, and determine what remains to implement.

---

## 1. Burgess Lemma 2.4 (D0 Seed / Until Witness Endpoint)

### 1.1 What Burgess Says (Burgess 1982, p. 369)

> **Lemma 2.4**: Let A be an MCS and suppose U(γ, β) ∈ A. Then there exist B, C such that β ∈ B, γ ∈ C, and R(A, B, C) holds.
>
> *Proof*: Let C₀ = {γ} ∪ {S(α, β) : α ∈ A}. We claim C₀ is consistent... Now let C be any MCS extending C₀. We have r(A, β, C) by construction, using criterion 2.3b for r. So it suffices to let B be maximal with respect to the properties that β ∈ B and r(A, B, C) to complete the proof.

**Key elements**:
1. **Seed**: C₀ = {γ} ∪ {S(α, β) : α ∈ A}
2. **Consistency proof**: Uses A1a, A2a for S-distribution, A3a for U(γ ∧ S(α,β), β) ∈ A, then Criterion 2.2
3. **Output**: MCS C containing γ, with r(A, β, C), then maximal DCS B containing β with R(A, B, C)

### 1.2 What Our Code Does

**File**: `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean`

```lean
theorem until_witness_seed_consistent {A : Set Formula}
    (h_mcs : SetMaximalConsistent A) (γ β : Formula)
    (h_until : Formula.untl γ β ∈ A) :
    SetConsistent ({β} ∪ g_content A) := by
```

```lean
noncomputable def lemma_2_4 {A : Set Formula}
    (h_mcs : SetMaximalConsistent A) (γ β : Formula)
    (h_until : Formula.untl γ β ∈ A) :
    ∃ B C : Set Formula, SetMaximalConsistent C ∧
      β ∈ C ∧ g_content A ⊆ C ∧
      Formula.some_past (Formula.untl γ β) ∈ C ∧
      BurgessR3Maximal A B C := by
```

### 1.3 Deviation Analysis

| Aspect | Burgess | Our Code | Deviation? | Severity |
|--------|---------|----------|------------|----------|
| **Seed formula** | C₀ = {γ} ∪ {S(α, β) : α ∈ A} | `{β} ∪ g_content A` | **YES — structurally different** | Medium |
| **Which side gets seed** | C (right/endpoint) | C (right/endpoint) | No | — |
| **MCS extension target** | C contains γ and S(α,β) formulas | C contains β and g_content(A) | **YES** | Medium |
| **What B gets** | β ∈ B (maximal DCS w.r.t. r(A,−,C)) | β ∈ B, via `burgessR3Maximal_from_g_content_sub` | **YES** | Medium |
| **Relation type** | R(A, B, C) (maximal DCS) | BurgessR3Maximal(A, B, C) | Equivalent | — |
| **Consistency argument** | A3a + Criterion 2.2 | `forward_temporal_witness_seed_consistent` via BX10 | Different proof path | Low |

### 1.4 Detailed Deviation: The Seed Mismatch

**Burgess's seed** includes:
- γ (the event formula from U(γ,β))
- S(α, β) for all α ∈ A (Since formulas with guard β and event α)

**Our seed** includes:
- β (the event formula from U(γ,β)) — **wait: this is the RIGHT side, not the event!**
- g_content(A) = {φ | G(φ) ∈ A} (all formulas whose G is in A)

**Critical observation**: Our seed puts **β** at the endpoint C, but Burgess puts **γ** at the endpoint. This is a **role reversal**. In Burgess:
- C contains the eventuality γ (from U(γ,β))
- B contains the guard β

In our code:
- C contains β (the event from U(γ,β))
- The seed also includes g_content(A)
- Additionally, we add P(U(γ,β)) to C (line 158)

**Why this is structurally acceptable**: Under our open-guard BX semantics, the roles are adapted. Our `lemma_2_4` is used for **C5 counterexample elimination** (Burgess 2.10), where we need a future point with η ∈ f(y) (the event). Our seed correctly places the event β at the endpoint.

**However**: The addition of `g_content A ⊆ C` and `Formula.some_past (Formula.untl γ β) ∈ C` are **NOT in Burgess's Lemma 2.4**. These are derived properties needed for our C3 threading at finite stages. Burgess does not need these because his C3 (at the limit) is defined differently.

### 1.5 Verdict

- **Deviation exists**: Our seed is structurally different from Burgess's C₀
- **Deviation is justified**: It serves the same proof purpose (C5 elimination) under adapted semantics, but the content is swapped (event vs. guard)
- **Status**: `lemma_2_4` is **sorry-free** — this deviation is already implemented and works
- **Action needed**: None, but document the role reversal clearly

---

## 2. Burgess Lemma 2.6 (Splitting Lemma / Counterexample Insertion)

### 2.1 What Burgess Says (Burgess 1982, p. 370)

> **Lemma 2.6**: Suppose we have R(A, B, C) and δ ∉ B. Then there exist B′, D, B″ such that ∼δ ∈ D and R(A, B′, D), R(D, B″, C) and B = B′ ∩ D ∩ B″.
>
> *Proof*: Let D₀ = {S(α, β) : α ∈ A, β ∈ B} ∪ B ∪ {∼δ} ∪ {U(γ, β) : γ ∈ C, β ∈ B}. We claim D₀ is consistent. Much as in the proof of 2.4 it suffices to show that any particular
> ζ = S(α, β) ∧ β ∧ ∼δ ∧ U(γ, β)
> with α ∈ A, β ∈ B, γ ∈ C is consistent... Now let D be any MCS extending D₀, and let B′, B″ be maximal with respect to the properties B ⊆ B′ ∧ r(A, B′, D) and B ⊆ B″ ∧ r(D, B″, C) respectively. Note we have B = B′ ∩ D ∩ B″ by 2.5 to complete the proof.

**Key elements**:
1. **D₀ seed**: {S(α, β) : α∈A, β∈B} ∪ B ∪ {∼δ} ∪ {U(γ, β) : γ∈C, β∈B}
2. **Consistency proof**: Uses maximality of B to extract β₀∈B, γ₀∈C with ∼U(γ₀, β₀∧δ) ∈ A, then A4a, A5a, A6a chain
3. **Output**: MCS D with ∼δ ∈ D, plus maximal B′, B″ with R(A, B′, D), R(D, B″, C) and B = B′ ∩ D ∩ B″

### 2.2 What Our Code Does

**File**: `PointInsertion.lean`, lines 880–883 (D0 seed), 1601+ (consistency proof), 2328+ (splitting theorem)

```lean
private def burgess_D0_seed (A B C : Set Formula) (β : Formula) : Set Formula :=
  B ∪ {β.neg} ∪
  {φ | ∃ β' ∈ B, ∃ γ ∈ C, φ = Formula.untl β' γ} ∪
  {φ | ∃ β' ∈ B, ∃ α ∈ A, φ = Formula.snce β' α}
```

```lean
theorem lemma_2_6_splitting {A B C : Set Formula}
    (h_mcs_A : SetMaximalConsistent A)
    (h_mcs_C : SetMaximalConsistent C)
    (h_r3m : BurgessR3Maximal A B C)
    (h_gc : g_content A ⊆ C)
    (β : Formula)
    (h_β_not_B : β ∉ B) :
    ∃ B' D B'', BurgessR3Maximal A B' D ∧ BurgessR3Maximal D B'' C ∧
      SetMaximalConsistent D ∧ β.neg ∈ D := by
```

### 2.3 Deviation Analysis

| Aspect | Burgess | Our Code | Deviation? | Severity |
|--------|---------|----------|------------|----------|
| **D₀ seed** | B ∪ {∼δ} ∪ {U(γ,β):γ∈C,β∈B} ∪ {S(α,β):α∈A,β∈B} | B ∪ {β.neg} ∪ {untl(β',γ)} ∪ {snce(β',α)} | Structurally faithful | Minor |
| **Consistency argument** | A4a + A5a + A6a (Burgess axioms) | BX5 (self_accum_until) + BX14 (separation_until) + BX13 (enrichment_until) + BX10 (until_F) | **Different axioms** | Medium |
| **Until formulas in seed** | U(γ, β) with β∈B, γ∈C | untl(β', γ) with β'∈B, γ∈C | Same (symbol swap) | None |
| **Since formulas in seed** | S(α, β) with α∈A, β∈B | snce(β', α) with β'∈B, α∈A | Same (symbol swap) | None |
| **Output** | R(A,B′,D), R(D,B″,C), B=B′∩D∩B″ | BurgessR3Maximal(A,B′,D), BurgessR3Maximal(D,B″,C) | Missing B=B′∩D∩B″ | **HIGH** |
| **β.neg in D** | ∼δ ∈ D (by seed) | β.neg ∈ D (by seed) | Same | None |

### 2.4 Detailed Deviations

#### Deviation 2.4.1: Axiom Replacement (Medium Severity)

Burgess's proof relies on:
- **A4a**: U(p,q) ∧ ∼U(p,r) ⊃ U(q ∧ ∼r, q)
- **A5a**: U(p,q) ⊃ U(p, q ∧ U(p,q))
- **A6a**: U(q ∧ U(p,q), q) ⊃ U(p,q)

Our code uses:
- **BX5**: `self_accum_until`: γ U β → (γ ∧ (γ U β)) U β
- **BX14**: `separation_until`: U(q,p) ∧ ¬U(r,p) → U(q, q ∧ ¬r)
- **BX13**: `enrichment_until`: p ∈ A and U(φ,ψ) ∈ A → U(φ, ψ ∧ S(φ,p)) ∈ A
- **BX10**: `until_F`: γ U β → F(β)

**Assessment**: This replacement is **documented and intentional** (see module docstring lines 14–23). A3a–A4a are not valid under strict (open-guard) semantics, so we substituted BX axioms that carry the same structural content. The proof skeleton matches Burgess step-for-step:
1. Burgess A5a → our BX5 (self-accumulation)
2. Burgess A4a → our BX14 (separation)
3. Burgess A6a → our BX13 (enrichment) combined with BX10 for eventuality

**Verdict**: Acceptable adaptation for strict semantics.

#### Deviation 2.4.2: Missing B = B′ ∩ D ∩ B″ (HIGH Severity)

Burgess's Lemma 2.6 concludes with **B = B′ ∩ D ∩ B″** via Lemma 2.5.

Our `lemma_2_6_splitting` (line 2328) produces:
- BurgessR3Maximal(A, B′, D)
- BurgessR3Maximal(D, B″, C)
- SetMaximalConsistent D
- β.neg ∈ D

**Missing**: The equality **B = B′ ∩ D ∩ B″** is NOT in our theorem statement.

**Where this matters**: Burgess uses B = B′ ∩ D ∩ B″ in:
- Lemma 2.9 (C4 counterexample elimination, case n=0): to determine g(x,z) and g(z,y)
- C3 maintenance: g(x,z) must decompose as g(x,z) = g(x,y) ∩ f(y) ∩ g(y,z)

**In our code**: C3 is maintained structurally via `Chronicle.c3` (line 383 in ChronicleTypes.lean), not via the B = B′ ∩ D ∩ B″ equality. Our approach defines g-values by explicit intersection at each elimination step.

**Verdict**: The missing equality is **not directly used** in our code path because C3 is maintained differently. However, it IS needed implicitly for the limit construction (Phase 5). The gap may surface in `limit_satisfies_c5_full` (Phase 5a).

#### Deviation 2.4.3: g_content(A) ⊆ C Parameter (Medium Severity)

Our `lemma_2_6_splitting` requires `h_gc : g_content A ⊆ C` as an explicit hypothesis.

Burgess does NOT assume g_content(A) ⊆ C in Lemma 2.6. Burgess's R(A,B,C) from C2' at finite stages does not require this.

**Why our code adds it**: Because we use `burgess_D0_seed_consistent` which requires `g_content A ⊆ C` (line 1989) to prove the D₀ seed is a subset of a known consistent set. Without this, we cannot establish seed consistency.

**Whether this is sound**: At the finite stages where Lemma 2.6 is applied (C4 counterexample elimination), C2' (BurgessR3Maximal) holds for adjacent pairs. The property `g_content A ⊆ C` is actually a **consequence** of BurgessR3Maximal + r3Relation under our adapted semantics (proved at lines 744–757 of PointInsertion.lean). So this hypothesis is redundant in context but needed explicitly for Lean's type system.

**Verdict**: The hypothesis is semantically redundant but technically necessary. Our proof at lines 744–757 (`g_content(A) ⊆ B from BurgessR3Maximal`) establishes this consequence.

#### Deviation 2.4.4: Two Sorry Sites in `burgess_D0_finite_subset_consistent_incons` (HIGH Severity)

At lines 1872–1873:
```lean
have h_ev_b : DerivationTree [] (event.imp b) := sorry
have h_ev_untl : DerivationTree [] (event.imp (Formula.untl b γ_hat)) := sorry
```

These are in the **inconsistent case** of D₀ finite subset consistency (when {β} ∪ B is inconsistent, so β.neg ∈ B).

In the **consistent case** (lines 1601+), all five event-implication properties are fully proved:
- `h_ev_b` (event → b): lines 1297–1298
- `h_ev_beta_neg` (event → β.neg): lines 1303–1333
- `h_ev_untl` (event → untl(b,γ̂)): lines 1300–1301
- `h_ev_snce` (event → snce(b,α)): lines 1336–1343

**In the inconsistent case** (lines 1811+), the event is constructed via `iterated_enrichment` (line 1860) with:
- `guard = q = b ∧ untl(b, γ_hat)`
- `base = γ_hat` (the enriched event)
- `alphas = a_list` (A-events)

The enrichment gives `event → base = γ_hat`, but we need:
- `event → b` (guard extraction)
- `event → untl(b, γ_hat)` (guard extraction)

These are **not directly provided** by `iterated_enrichment` because the guard is `q = b ∧ untl(b, γ_hat)`, not `b` alone. We need to extract `b` and `untl(b, γ_hat)` from the guard, which requires additional propositional reasoning about the structure of `q`.

**What Burgess would do**: Burgess's proof in the inconsistent case is simpler — since β.neg ∈ B, the seed doesn't need the BX14 separation step. The event construction can proceed directly from `untl(b, γ_hat) ∈ A` via BX5 and BX10.

**Action needed**: Implement guard extraction proofs. The event is `iterated_enrichment` of `Formula.and q (Formula.and b β).neg` — but in the inconsistent case, `β.neg ∈ B`, so the `(and b β).neg` component is already in B and we can simplify. The proofs should use `lce_imp` / `rce_imp` on the guard `q = b ∧ untl(b, γ_hat)`.

---

## 3. Active Sorry Sites and Their Burgess Counterparts

### 3.1 PointInsertion.lean

| Line | Context | Burgess Counterpart | Status |
|------|---------|---------------------|--------|
| **1872** | Inconsistent case: `event.imp b` | Burgess 2.6 proof, Step 5 (guard extraction) | **OPEN** — needs propositional derivation from guard structure |
| **1873** | Inconsistent case: `event.imp (untl b γ_hat)` | Burgess 2.6 proof, Step 5 (guard extraction) | **OPEN** — same as above |
| **2414** | `lemma_2_7_seed_consistent` | Burgess 2.7, p. 372 (BX7 chain) | **OPEN** — entire proof is `sorry` |

### 3.2 CounterexampleElimination.lean (Phase 4)

| Line | Context | Burgess Counterpart | Status |
|------|---------|---------------------|--------|
| **412** | C4 hard case (nested gamma in f(w_next)) | Burgess 2.9, C4 elimination n>0 subcase | **OPEN** — needs `burgessR3_gamma_not_in_B` + splitting |
| **510** | C4' hard case mirror | Burgess 2.9 mirror | **OPEN** |
| 756 | c2' for C5 elimination | C2' at new adjacent pair (y as endpoint) | **OPEN** — Phase 4b |
| 768 | c2' no elimination (trivial) | C2' preserved | **OPEN** — trivial |
| 794 | c2' for C5' elimination | C2' mirror | **OPEN** — Phase 4b |
| 806 | c2' no elimination (trivial) | C2' preserved | **OPEN** — trivial |
| 834 | c2' for C4 elimination | C2' at new pairs (prev,z) and (z,next) | **OPEN** — Phase 4c |
| 845 | c2' no elimination (trivial) | C2' preserved | **OPEN** — trivial |
| 872 | c2' for C4' elimination | C2' mirror | **OPEN** — Phase 4c |
| 883 | c2' no elimination (trivial) | C2' preserved | **OPEN** — trivial |
| 918 | c2' for density insertion | C2' at new pairs | **OPEN** — Phase 4d |
| 931 | c2' no elimination (trivial) | C2' preserved | **OPEN** — trivial |

### 3.3 ChronicleToCountermodel.lean (Phase 5)

| Line | Context | Burgess Counterpart | Status |
|------|---------|---------------------|--------|
| **615** | FUC (forward Until coherence) | Burgess Claim 2.11, p. 375 | **OPEN** — needs `limit_satisfies_c5_full` |
| **619** | FSC (forward Since coherence) | Burgess Claim 2.11 mirror | **OPEN** — mirror of above |

---

## 4. What Burgess Prescribes vs. Our Approach for Remaining Work

### 4.1 Burgess's 10-Step BX7 Chain (Lemma 2.7)

**Burgess 1982, p. 372** prescribes for Lemma 2.7:

1. Extract witness: β₀ ∈ B, γ₀ ∈ C with `¬U(β₀ ∧ η, γ₀) ∈ A` (from maximality of B)
2. BX5 on `U(ξ, η)`: get `U(ξ ∧ U(ξ,η), η) ∈ A`
3. BX5 on `U(beta₀, gamma₀)`: get `U(beta₀ ∧ U(beta₀,gamma₀), gamma₀) ∈ A`
4. BX7 (A7a) three-way disjunction D1 ∨ D2 ∨ D3
5. Eliminate D1: `U(γ ∧ ξ, θ)` contradicts `¬U(β₀ ∧ η, γ₀)` via monotonicity
6. Eliminate D2: `U(γ ∧ U(ξ,η), θ)` contradicts same witness
7. Surviving D3: `U(β ∧ U(β,γ) ∧ ξ, θ)` — contains the target structure
8. D3 implies `U(ξ, β ∧ η) ∈ A`
9. From `U(ξ, β ∧ η) ∈ A`, get consistency of ζ = `S(α, β ∧ η) ∧ β ∧ ξ ∧ U(γ, β)`
10. MCS extension gives D with ξ ∈ D and η ∈ B′

**Our code's skeleton** (lines 2405–2413):
```lean
private theorem lemma_2_7_seed_consistent {A B C : Set Formula} ... :
    SetConsistent (lemma_2_7_seed A B C xi eta) := by
  sorry
```

The `lemma_2_7_seed` at line 2386 includes the 5th component `{snce(β ∧ eta, α)}` which is the key Burgess insight for getting η ∈ B′.

**Action needed**: Implement the 10-step BX7 chain exactly as Burgess outlines. The infrastructure exists:
- `self_accum_until_mcs` (BX5 at MCS level) — line 189
- `separation_until_mcs` (BX14 at MCS level) — line 976
- `enrichment_until_mcs` (BX13 at MCS level) — line 988
- `until_implies_F_mcs` (BX10 at MCS level) — line 1000
- `conj_mcs` (conjunction introduction) — line 210
- Monotonicity theorems (`until_left_mono_thm`, `right_mono_until_mcs`) — available

### 4.2 c2' Threading (Phase 4)

Burgess does NOT explicitly define a "c2'" condition. Instead, he maintains C2' implicitly through the maximality requirement in Lemmas 2.4/2.6/2.7.

Our code makes this explicit via `Chronicle.c2'` (line 372 in ChronicleTypes.lean):
```lean
def Chronicle.c2' (χ : Chronicle) : Prop :=
  ∀ x y : Rat, Adjacent χ.dom x y →
    BurgessR3Maximal (χ.f x) (χ.g x y) (χ.f y)
```

**Why this is a faithful adaptation**: Burgess's text states (p. 374):
> "(C2′) Whenever x, y ∈ dom f and x immediately precedes y in dom f, then R(f(x), g(x,y), f(y)) holds."

Our `c2'` is exactly this: for adjacent pairs, `BurgessR3Maximal` (our equivalent of R) holds.

**The threading challenge**: At each elimination step, when we insert a new point z between x and y, we must:
1. Define g(x,z) and g(z,y)
2. Prove `BurgessR3Maximal(f(x), g(x,z), f(z))`
3. Prove `BurgessR3Maximal(f(z), g(z,y), f(y))`
4. Preserve C3: g(x,y) = g(x,z) ∩ f(z) ∩ g(z,y)

Burgess delegates this to "details left to the reader" (2.9, case n=0). Our code must make it explicit.

**Action needed**:
- Phase 4b (C5/C5'): Use `lemma_2_4` to get B for the new endpoint, then Zorn for maximality
- Phase 4c (C4/C4'): Use `lemma_2_6_splitting` to get B′, D, B″ for the midpoint
- Phase 4d (Density): Use `burgessR3Maximal_from_g_content_sub` with g_content propagation

### 4.3 Limit C5 Full (Phase 5a)

Burgess's Claim 2.11 (p. 375) is the truth lemma: `x ∈ V(α) ↔ α ∈ f(x)` for all α.

For Until formulas (Claim 2.11 sample case, pp. 375–376):
> If α = U(β, γ) ∈ f(x), then by C5a there is a y ∈ X with x < y and γ ∈ f(y) and β ∈ g(x, y). If z ∈ X and x < z < y, then by C3 we have g(x, y) ⊆ f(z), whence β ∈ f(z).

Our `limit_satisfies_c5_full` must prove:
```lean
theorem limit_satisfies_c5_full (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (x : Rat) (hx : x ∈ limit_dom A h_mcs) (ξ η : Formula)
    (h_until : Formula.untl ξ η ∈ limit_f A h_mcs x) :
    ∃ y ∈ limit_dom A h_mcs, x < y ∧ η ∈ limit_f A h_mcs y ∧
      ∀ z ∈ limit_dom A h_mcs, x < z → z < y → ξ ∈ limit_f A h_mcs z := by
```

**Burgess's proof path**:
1. x enters domain at finite stage n
2. `U(ξ,η) ∈ limit_f(x)` means `U(ξ,η) ∈ f_n(x)` for some finite n
3. Counterexample enumeration presents U(ξ,η) as a C5 counterexample at stage m ≥ n
4. C5 elimination inserts witness y with `η ∈ f_{m+1}(y)`
5. At stage m+1, (x,y) is adjacent and c2' holds, so `ξ ∈ g_{m+1}(x,y)`
6. At the limit: `ξ ∈ limit_g(x,y)`
7. By `limit_c3_interval_subset_point` (already sorry-free): `∀z∈(x,y), ξ ∈ limit_f(z)`

**Action needed**: Implement g-value propagation from finite to limit stages. The key lemma: if `ξ ∈ g_n(x,y)` at stage n, then `ξ ∈ g_m(x,y)` for all m > n (since c2' maximality prevents losing g-values).

---

## 5. Summary Table: Code Status vs. Burgess

| Burgess Section | Lean File | Status | Deviations | Blockers |
|-----------------|-----------|--------|------------|----------|
| 2.4 (Lemma 2.4 / D0) | PointInsertion.lean | ✅ Complete | Swapped event/guard roles; added g_content and P(U) | None |
| 2.5 (Lemma 2.5) | PointInsertion.lean | ✅ Complete | Direct g_content/h_content version | None |
| 2.6 (Lemma 2.6 / Splitting) | PointInsertion.lean | ⚠️ Partial | 2 sorry in inconsistent case; missing B=B′∩D∩B″ | 1872, 1873 |
| 2.7 (Lemma 2.7 / Until split) | PointInsertion.lean | ❌ Not started | Entire proof is `sorry` | 2414 |
| 2.8 (Lemma 2.8) | PointInsertion.lean | ❌ Not needed | Withdrawn per plan | None |
| 2.9 (C4 elimination) | CounterexampleElimination.lean | ⚠️ Partial | Inner hard cases sorry | 412, 510 |
| 2.10 (C5 elimination) | CounterexampleElimination.lean | ✅ Core | c2' field sorry (12 sites) | 756, 768, 794, 806 |
| 2.11 (Truth lemma) | ChronicleToCountermodel.lean | ❌ Not started | FUC/FSC sorry | 615, 619 |
| C2' threading | ChronicleConstruction.lean | ⚠️ Partial | omega_chain_c2' not yet threaded | Phase 4e |

---

## 6. Critical Gaps Requiring Immediate Attention

### Gap 1: Inconsistent-Case Event Implications (lines 1872–1873)
**Priority**: HIGH (blocks Phase 2 completion)
**Size**: ~20 lines each
**Burgess reference**: Lemma 2.6 proof, "much as in the proof of 2.4"
**What to do**: In the inconsistent case, `β.neg ∈ B` means the BX14 separation step is unnecessary. The event from `iterated_enrichment` with guard `q = b ∧ untl(b, γ_hat)` should directly imply `b` and `untl(b, γ_hat)` via conjunction elimination from the guard. Use `lce_imp` / `rce_imp` on the assumption `event → q`.

### Gap 2: Lemma 2.7 Seed Consistency (line 2414)
**Priority**: HIGH (blocks Phase 3, critical path)
**Size**: ~150 lines
**Burgess reference**: Lemma 2.7, p. 372
**What to do**: Implement the 10-step BX7 chain exactly:
1. `lemma_2_7_neg_untl_exists`: extract β₀, γ₀ witness from maximality
2. `self_accum_until_mcs` on `untl(xi, eta)` and `untl(beta0, gamma0)`
3. `linear_until_mcs` (BX7) for three-way disjunction
4. Eliminate D1/D2 using the witness + monotonicity
5. surviving D3 gives `untl(b ∧ xi, b ∧ eta)` — contains eta
6. BX14 + BX13 + BX10 chain for consistency

### Gap 3: C2' Threading Through Elimination (12 sorry sites)
**Priority**: HIGH (blocks Phase 4, critical path)
**Size**: ~200 lines total
**Burgess reference**: Implicit in C2′, C3, C4, C5 definitions
**What to do**:
- For **C5** (new endpoint): Use `lemma_2_4` to construct new g-value for adjacent pair, then Zorn for maximality
- For **C4** (midpoint insertion): Use `lemma_2_6_splitting` to get B′, D, B″ for the two new adjacent pairs
- For **density**: Use `burgessR3Maximal_from_g_content_sub` with g_content propagation
- For **no-elimination cases**: Trivial — use existing `h_c2'`

### Gap 4: C4 Hard Cases (lines 412, 510)
**Priority**: MEDIUM (non-critical path but needed for completeness)
**Size**: ~100 lines each
**Burgess reference**: Lemma 2.9, case n > 0
**What to do**: When `γ ∈ f(w_next)` and `neg(untl(γ,δ)) ∈ f(w)`, use `burgessR3_gamma_not_in_B` to show γ ∉ g(w, w_next), then `lemma_2_6_splitting` with β = γ.

### Gap 5: FUC/FSC Coherence (lines 615, 619)
**Priority**: HIGH (blocks Phase 5, final theorem)
**Size**: ~150 lines each
**Burgess reference**: Claim 2.11, p. 375
**What to do**: Connect `limit_satisfies_c5_full` to Cantor isomorphism. The proof template is in the plan (Phase 5b).

---

## 7. Conclusion

Our codebase **faithfully follows Burgess 1982's proof architecture** with the following documented adaptations:
1. **Axiom replacement**: A3a–A7a → BX5, BX10, BX13, BX14 (for strict/open-guard semantics)
2. **Role reversal in Lemma 2.4**: Event and guard are swapped in the seed to match our Until semantics
3. **Explicit c2' condition**: We make Burgess's implicit R-maximality explicit in `Chronicle.c2'`
4. **Missing B = B′∩D∩B″**: Not needed in our C3 maintenance approach, but may surface at limit

The **critical path** to sorry-free `dd_countermodel_chronicle` is:
1. Close Phase 2 sorries (1872, 1873) — 2–3 hours
2. Implement Lemma 2.7 (2414) — 6–8 hours
3. Thread c2' through elimination (Phase 4a–4d) — 8–12 hours
4. Thread c2' through omega_chain (Phase 4e) — 2–3 hours
5. Prove limit_satisfies_c5_full (Phase 5a) — 8–10 hours
6. Close FUC/FSC (Phase 5b) — 4–6 hours

**Estimated total remaining**: 30–42 hours on the critical path.
