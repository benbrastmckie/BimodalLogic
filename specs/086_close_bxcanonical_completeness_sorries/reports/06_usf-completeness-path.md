# Research Report: How to Finish USF Completeness

**Task**: 86 — Close BXCanonical completeness sorries
**Date**: 2026-04-09
**Session**: sess_1775748512_e71e33
**Focus**: Detailed path to closing `usf_completeness` imp Case B at CanonicalEmbedding.lean:418

## 1. The Sorry in Precise Terms

```lean
-- CanonicalEmbedding.lean:418
-- Goal: False
-- Context:
--   w : BXPoint (MCS with psi ∈ w, chi ∉ w, (psi → chi) ∉ w)
--   h_valid : valid (psi.imp chi)
--   h_usf : untilSinceFree (psi.imp chi)
```

We must derive `False` from the contradiction: `valid (psi → chi)` yet `(psi → chi) ∉ w` for some MCS w.

The standard approach: instantiate `h_valid` with a concrete model where `psi` is true and `chi` is false, contradicting validity.

## 2. Why Constant Histories Fail

On `constant_history w` with `modal_omega w`, the bidirectional truth lemma holds for temporal-free formulas (`fragment_truth_iff`). But for G/H:

- Forward `G(α) ∈ w → truth_at G(α)` works (BX1 gives `α ∈ w`, constant history makes all times equal)
- **Backward** `truth_at G(α) → G(α) ∈ w` FAILS: truth_at G(α) on constant history just gives `α ∈ w`, but `G(α) ∈ w` requires `α ∈ v` for ALL `v` with `bx_le w v` (by `G_iff_mcs`)

The imp case of the truth lemma needs BOTH directions for sub-formulas (report 04, Section 4). So constant histories are insufficient when psi or chi contain G/H.

## 3. The Correct Architecture: Dovetailed Chain with Combined F-Seeds

### 3.1 Two-Dimensional Construction

For each `w : BXPoint`, build:

1. **Chain** `τ_w : ℤ → BXPoint` — a bx_le-monotone sequence with `τ_w(0) = w`
2. **Omega** `Ω_w` — containing chains through ALL modal-equivalents of w, at all time-shifts
3. **Bidirectional truth lemma**: `α ∈ τ_w(s).formulas ↔ truth_at canonical_valuation Ω_w τ_w s α` for all USF α

### 3.2 Chain Construction (Combined F-Seed)

**Key lemma** (prerequisite, ~50-100 LOC):

```lean
theorem combined_F_seed_consistent (w : BXPoint)
    (L : List Formula) (hL : ∀ ψ ∈ L, Formula.some_future ψ ∈ w.formulas) :
    SetConsistent (L.toFinset ∪ g_content w.formulas)
```

**Proof sketch** (Goldblatt 1992 §6.5):
1. Assume inconsistent: some finite `S ⊆ L ∪ g_content(w)` derives ⊥
2. Let `S_L = S ∩ L = {ψ₁, ..., ψₖ}` and `S_g = S ∩ g_content(w)`
3. From the derivation: `S_g ⊢ ¬ψ₁ ∨ ... ∨ ¬ψₖ`
4. By G-distribution (from BX1 temporal K): `G(¬ψ₁) ∨ ... ∨ G(¬ψₖ) ∈ w`
5. But each `F(ψᵢ) ∈ w` means `¬G(¬ψᵢ) ∈ w` (temporal duality + MCS negation completeness)
6. So `G(¬ψ₁) ∉ w, ..., G(¬ψₖ) ∉ w`, contradicting the disjunction being in w (MCS)

**Lean dependencies needed**:
- G-distribution over conjunction/disjunction — derivable from BX1 (temporal K axiom)
- Temporal duality: `F(ψ) ∈ w ↔ ¬G(¬ψ) ∈ w` — from definitions + MCS properties
- MCS disjunction property: `(α ∨ β) ∈ w → α ∈ w ∨ β ∈ w`
- Finite subset extraction from provability

**Existing infrastructure**: `forward_temporal_witness_seed_consistent` in WitnessSeed.lean:79 proves the SINGLE-target version `{ψ} ∪ g_content(M)` is consistent. The multi-target version extends this by the compactness argument above.

### 3.3 Chain Definition

```lean
noncomputable def dovetail_chain (w : BXPoint) : ℤ → BXPoint
-- Positive direction:
-- dovetail_chain w 0 = w
-- dovetail_chain w (n+1) = Lindenbaum extension of:
--   {ψ | F(ψ) ∈ (dovetail_chain w n).formulas ∧ ψ ∉ (dovetail_chain w n).formulas}
--   ∪ g_content((dovetail_chain w n).formulas)
--   ∪ box_content((dovetail_chain w n).formulas)
-- (this is the "combined F-seed" — ALL pending F-obligations at once)
--
-- Negative direction (mirror for H):
-- dovetail_chain w (-n-1) = Lindenbaum extension of:
--   {ψ | P(ψ) ∈ (dovetail_chain w (-n)).formulas ∧ ψ ∉ (dovetail_chain w (-n)).formulas}
--   ∪ h_content((dovetail_chain w (-n)).formulas)
--   ∪ box_content((dovetail_chain w (-n)).formulas)
```

**Key property by construction**: `forward_F` holds trivially — if `F(ψ) ∈ chain(t)` and `ψ ∉ chain(t)`, then ψ is in the seed at step t+1, so `ψ ∈ chain(t+1)`.

### 3.4 Chain Properties to Prove

| Property | Statement | Proof Strategy |
|----------|-----------|----------------|
| `chain_zero` | `dovetail_chain w 0 = w` | By definition |
| `chain_monotone` | `0 ≤ m ≤ n → bx_le (chain w m) (chain w n)` | Induction: g_content(chain(n)) ⊆ chain(n+1) by seed construction |
| `chain_forward_F` | `F(ψ) ∈ chain(t) → ∃ r > t, ψ ∈ chain(r)` | By construction: if ψ ∉ chain(t), ψ is in seed at t+1 |
| `chain_forward_G` | `G(α) ∈ chain(t) → ∀ r ≥ t, α ∈ chain(r)` | Induction: G(α) propagates through g_content ⊆ seed |
| `chain_G_contrapositive` | `G(α) ∉ chain(s) → ∃ r > s, α ∉ chain(r)` | Temporal duality + chain_forward_F |
| `chain_box_preserved` | `□ψ ∈ chain(s) ↔ □ψ ∈ chain(r)` | From `box_preserved_along_bx_le` (Phase 1, sorry-free) |
| Mirror properties for negative direction (H, P) | | |

### 3.5 Omega Construction

```lean
def dovetail_omega (w : BXPoint) : Set (WorldHistory canonical_task_frame) :=
  { σ | ∃ v : BXPoint, bx_modal_equiv w v ∧ ∃ δ : ℤ,
    σ = time_shift (dovetail_history v) δ }
```

where `dovetail_history v` wraps `dovetail_chain v` into a `WorldHistory`.

**Properties to prove**:
- `shift_closed`: By construction (shifts of shifts are shifts)
- `self_mem`: `dovetail_history w ∈ dovetail_omega w` (take v = w, δ = 0)
- `modal_equiv_mem`: `v ~ w → dovetail_history v ∈ dovetail_omega w`

### 3.6 Respects_task Obligation

`dovetail_history v` must satisfy `respects_task` for `canonical_task_frame`. The canonical task frame has permissive `task_rel`: `d ≠ 0 ∨ states agree`. For `d ≠ 0`, this is trivially satisfied. For `d = 0`, chain(t) = chain(t) so states agree. Full domain (`domain = fun _ => True`) makes convexity trivial.

## 4. The Bidirectional Truth Lemma

**Statement**: For all USF `α`, all `v ~ w`, all `s : ℤ`:
```
α ∈ (dovetail_chain v s).formulas ↔ truth_at canonical_valuation (dovetail_omega w) (dovetail_history v) s α
```

**Proof by structural induction on α** (well-founded since USF has no Until/Since):

### 4.1 Case: atom p
- Forward: `atom p ∈ chain(s)` → `canonical_valuation (chain s) p` → `truth_at (atom p)` (domain always True)
- Backward: `truth_at (atom p)` → `canonical_valuation (chain s) p` → `atom p ∈ chain(s)`

### 4.2 Case: ⊥
- Both sides False (bot_not_in_mcs / truth_at bot = False)

### 4.3 Case: ψ → χ
- Forward: `(ψ → χ) ∈ chain(s)`. Suppose `truth_at ψ`. By IH backward: `ψ ∈ chain(s)`. By `imp_iff_mcs`: `χ ∈ chain(s)`. By IH forward: `truth_at χ`.
- Backward: `truth_at (ψ → χ)`. Suppose `ψ ∈ chain(s)`. By IH forward: `truth_at ψ`. Then `truth_at χ`. By IH backward: `χ ∈ chain(s)`. By `imp_iff_mcs`: `(ψ → χ) ∈ chain(s)`.

### 4.4 Case: □ψ
- Forward: `□ψ ∈ chain_v(s)`. For any `σ ∈ Ω_w`, σ = `time_shift(chain_u, δ)` for some `u ~ w`. Need `truth_at ψ at (σ, s)` = `truth_at ψ at (chain_u, s + δ)`. By `box_preserved_along_bx_le` + `bx_modal_equiv_of_bx_le`: `□ψ ∈ chain_u(s + δ)`. By modal_t: `ψ ∈ chain_u(s + δ)`. By IH forward: `truth_at ψ at (chain_u, s + δ)`.

  Wait — this needs `□ψ ∈ chain_u(s + δ)` from `□ψ ∈ chain_v(s)`. The path: `□ψ ∈ chain_v(s)` → `□ψ ∈ v` (box_preserved along bx_le from chain_v(s) to v... actually chain_v(0) = v, not chain_v(s)). This needs more care.

  **Corrected forward**: `□ψ ∈ chain_v(s)`. By `chain_box_preserved`: `□ψ ∈ chain_v(0) = v`. Since `v ~ w` and `u ~ w`, we have `v ~ u`. So `□ψ ∈ u` (by modal equivalence). By `chain_box_preserved` in u's chain: `□ψ ∈ chain_u(r)` for all r. By modal_t: `ψ ∈ chain_u(r)`. By IH: `truth_at ψ`.

- Backward: For all `σ ∈ Ω_w`, `truth_at ψ at (σ, s)`. In particular, for each `u ~ w` and each `δ`: `truth_at ψ at (chain_u, s + δ)`. By IH backward: `ψ ∈ chain_u(s + δ)`. Taking `δ = -s`: `ψ ∈ chain_u(0) = u`. So `ψ ∈ u` for all `u ~ w`. But `chain_v(s) ~ w` (via chain_box_preserved + v ~ w). So `ψ ∈ u` for all `u ~ chain_v(s)`. By `box_iff_mcs`: `□ψ ∈ chain_v(s)`.

### 4.5 Case: G(ψ)
- Forward: `G(ψ) ∈ chain_v(s)`. For any `r ≥ s`: by `chain_forward_G`, `ψ ∈ chain_v(r)`. By IH forward: `truth_at ψ at (chain_v, r)`.
- Backward: `truth_at G(ψ)` means `∀ r ≥ s, truth_at ψ at (chain_v, r)`. By IH backward: `ψ ∈ chain_v(r)` for all `r ≥ s`. Suppose `G(ψ) ∉ chain_v(s)`. By temporal duality: `F(¬ψ) ∈ chain_v(s)`. By `chain_forward_F`: ∃ `r > s` with `¬ψ ∈ chain_v(r)`. But `ψ ∈ chain_v(r)` and `¬ψ ∈ chain_v(r)` contradicts MCS consistency. So `G(ψ) ∈ chain_v(s)`.

### 4.6 Case: H(ψ)
- Mirror of G case using negative direction of chain and `chain_backward_P`.

## 5. Closing the Sorry

With the bidirectional truth lemma proved, close CanonicalEmbedding.lean:418:

```lean
-- We have: w : BXPoint, psi ∈ w, chi ∉ w, h_valid : valid (psi → chi)
-- Instantiate h_valid with the canonical model:
have h := h_valid ℤ canonical_task_frame canonical_valuation
  (dovetail_omega w) (shift_closed_dovetail_omega w)
  (dovetail_history w) (self_mem_dovetail_omega w) 0
-- h : truth_at psi → truth_at chi  at  (Ω_w, τ_w, 0)
-- Forward: psi ∈ w = chain(0) → truth_at psi  (by truth lemma forward)
have h_psi := (chain_truth_iff w w (bx_modal_equiv_refl w) 0 psi h_usf.1).mp h_psi_in
-- Backward: truth_at chi → chi ∈ chain(0) = w  (by truth lemma backward)
have h_chi := (chain_truth_iff w w (bx_modal_equiv_refl w) 0 chi h_usf.2).mpr
-- Chain: h_psi → h h_psi → truth_at chi → chi ∈ w, contradicting h_chi_not
exact h_chi_not (h_chi (h h_psi))
```

## 6. Implementation Plan (Revised Phases 2-5)

### Phase 2: Combined F-Seed Consistency + Chain Construction (3-4 hours)

**Files**: `CanonicalEmbedding.lean` (or new `ChainConstruction.lean`)

1. Prove `combined_F_seed_consistent` (~50-100 LOC)
   - Need G-distribution lemma (derivable from BX1)
   - Need temporal duality lemma: `F(ψ) ∈ w ↔ ¬G(¬ψ) ∈ w`
   - Need MCS disjunction elimination
2. Define `dovetail_chain : BXPoint → ℤ → BXPoint`
3. Prove `chain_zero`, `chain_monotone`
4. Prove `chain_forward_F` (trivial by construction)
5. Prove `chain_forward_G` (induction using g_content ⊆ seed)
6. Prove `chain_G_contrapositive` (temporal duality + forward_F)
7. Prove mirror properties for H direction
8. Verify `lake build` passes

### Phase 3: History + Omega (1-2 hours)

**Files**: `CanonicalEmbedding.lean`

1. Define `dovetail_history : BXPoint → WorldHistory canonical_task_frame`
2. Prove `respects_task` obligation (trivial with permissive canonical task_rel)
3. Define `dovetail_omega : BXPoint → Set (WorldHistory canonical_task_frame)`
4. Prove `shift_closed`, `self_mem`, `modal_equiv_mem`
5. Verify `lake build` passes

### Phase 4: Bidirectional Truth Lemma (3-4 hours)

**Files**: `CanonicalEmbedding.lean`

1. State `chain_truth_iff` for USF formulas
2. Prove all 6 cases (atom, bot, imp, box, G, H) as detailed in Section 4
3. The box case requires careful use of `chain_box_preserved` + `modal_omega_eq_of_bx_le`
4. The G backward case uses `chain_G_contrapositive` (which depends on `chain_forward_F`)
5. Verify `lake build` passes

### Phase 5: Close Sorry + Verify (1 hour)

**Files**: `CanonicalEmbedding.lean`

1. Replace sorry at line 418 with proof using `chain_truth_iff` (as in Section 5)
2. Run `lake build` — verify zero errors
3. `grep sorry CanonicalEmbedding.lean` — verify only expected sorries remain
4. Update comments/docstrings

## 7. Risk Assessment

| Risk | Likelihood | Mitigation |
|------|-----------|------------|
| G-distribution lemma hard to formalize | Low | Standard derivation from BX1 (temporal K) |
| combined_F_seed_consistent proof has hidden gap | Low-Medium | Proof sketch is standard (Goldblatt 1992); single-target version already sorry-free |
| Box case of truth lemma fails | Medium | Needs careful modal_omega argument; Phase 1 lemmas should suffice |
| chain_forward_G induction step fails | Low | g_content propagation is definitional |
| respects_task obligation non-trivial | Low | Canonical task_rel is permissive |
| **Total estimated effort** | | **8-11 hours** |

## 8. What NOT To Do

1. **Do NOT pursue Frame.lean sorries** (lines 646, 668, 683, 697). They require Until/Since eventuality and are irrelevant to USF completeness.
2. **Do NOT use constant histories**. They are provably insufficient (Section 2).
3. **Do NOT attempt a one-directional truth lemma**. The imp case requires both directions (report 04, Section 4).
4. **Do NOT use simple one-at-a-time dovetail scheduling**. It does not satisfy forward_F (handoff 01).
5. **Do NOT try to make G-contrapositive hold directly** (without forward_F). It requires surjectivity onto all BXPoints, which is impossible for countable chains.

## 9. Key Dependencies (All Sorry-Free)

| Lemma | File | What It Provides |
|-------|------|-----------------|
| `G_iff_mcs` | TruthLemma.lean | `G(φ) ∈ w ↔ ∀ v ≥ w, φ ∈ v` |
| `H_iff_mcs` | TruthLemma.lean | `H(φ) ∈ w ↔ ∀ v ≤ w, φ ∈ v` |
| `box_iff_mcs` | TruthLemma.lean | `□φ ∈ w ↔ ∀ v ~ w, φ ∈ v` |
| `imp_iff_mcs` | TruthLemma.lean | `(ψ → χ) ∈ w ↔ (ψ ∈ w → χ ∈ w)` |
| `bx_G_backward` | Frame.lean | `G(α) ∉ w → ∃ v ≥ w, α ∉ v` |
| `bx_H_backward` | Frame.lean | `H(α) ∉ w → ∃ v ≤ w, α ∉ v` |
| `bx_forward_witness` | Frame.lean | `F(ψ) ∈ w → ∃ v ≥ w, ψ ∈ v` |
| `box_preserved_along_bx_le` | Frame.lean | `bx_le w v → (□φ ∈ w ↔ □φ ∈ v)` |
| `bx_modal_equiv_of_bx_le` | Frame.lean | `bx_le w v → bx_modal_equiv w v` |
| `modal_omega_eq_of_bx_le` | CanonicalEmbedding.lean | `bx_le w v → modal_omega w = modal_omega v` |
| `forward_temporal_witness_seed_consistent` | WitnessSeed.lean | `{ψ} ∪ g_content(M)` consistent (single-target) |
| `temporal_backward_G_with_fwd_F` | TemporalCoherence.lean | forward_F + all-future → G |
