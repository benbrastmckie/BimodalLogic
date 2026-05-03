# Research Report: Remaining Phases for Task OC_107

**Date**: 2026-05-03
**Report Version**: 54
**Purpose**: Map all 22 remaining sorries to Burgess 1982 sections, provide proof sketches, identify blockers/dependencies, and recommend execution order.

---

## 1. Current State Summary

**Plan**: `plans/53_implementation-plan.md` — 7 phases (2 through 5c)
**Completion**: Phase 2 marked [COMPLETED]; Phase 3 marked [IN PROGRESS]
**Actual**: 22 active sorries across 3 files:

| File | Sorries | Phase |
|------|---------|-------|
| `PointInsertion.lean` | 4 | Phases 2, 3 |
| `CounterexampleElimination.lean` | 16 | Phase 4 |
| `ChronicleToCountermodel.lean` | 2 | Phase 5 |

---

## 2. Key Definitions Verified

### 2.1 `BurgessR3Maximal` (ChronicleTypes.lean:320-323)

```lean
def BurgessR3Maximal (A B C : Set Formula) : Prop :=
  SetDeductivelyClosed B ∧
  burgessR3 A B C ∧
  ∀ D, SetDeductivelyClosed D → B ⊂ D → ¬burgessR3 A D C
```

Where `burgessR3 A B C := burgessRSet A B C ∧ burgessRSetSince C B A`.

**Status**: Correctly matches Burgess Definition 2.5 (R-maximality). B is a maximal DCS satisfying the three-argument r-relation with endpoints A, C.

### 2.2 `EliminationResult` (CounterexampleElimination.lean:693-721)

```lean
structure EliminationResult (χ : Chronicle) (pc : PotentialCounterexample) where
  val : Chronicle
  dom_sub : χ.dom ⊆ val.dom
  c0 : val.c0
  f_agrees : ∀ x ∈ χ.dom, val.f x = χ.f x
  g_agrees : ∀ a b, a ∈ χ.dom → b ∈ χ.dom → val.g a b = χ.g a b
  c2' : val.c2'                           -- ← SORRY SITES (all 10 c2')
  c5_forward_witness : ... → ∃ y ...      -- ← used, compiles
  c5_backward_witness : ... → ∃ y ...     -- ← used, compiles
  c4_forward_witness : ... → ∃ z ...      -- ← used, compiles
  c4_backward_witness : ... → ∃ z ...     -- ← used, compiles
  density_witness : ... → ∃ z ...         -- ← used, compiles
```

**Critical finding**: The `c2'` field is NEWLY ADDED (per the plan) but all 10 construction sites have sorries. The witness fields (`c5_forward_witness`, etc.) already compile correctly — only `c2'` proofs are missing. This confirms the plan's diagnosis that Phase 4 is about threading `BurgessR3Maximal` proofs, not about witness generation.

### 2.3 `c2'` Property (ChronicleTypes.lean:372-374)

```lean
def Chronicle.c2' (χ : Chronicle) : Prop :=
  ∀ x y : Rat, Adjacent χ.dom x y →
    BurgessR3Maximal (χ.f x) (χ.g x y) (χ.f y)
```

At the limit: vacuously true (dense domain has no adjacent pairs per `LimitAdjacent`).

### 2.4 `limit_f` and `limit_g` (ChronicleConstruction.lean)

- **`limit_f`** (line 490): At limit, `limit_f A h_mcs x` = the MCS at x from omega-chain union. Well-defined because once x enters domain at stage n, it persists with same MCS.
- **`limit_g`** (line 837): Defined as `{φ | ∀ y ∈ limit_dom, x < y < z → φ ∈ limit_f y}`. This is the C3-derived g: the formulas holding at ALL intermediate limit points.
- **`limit_c3`** (line 852): **PROVED sorry-free**. `limit_g(x,z) = limit_g(x,y) ∩ limit_f(y) ∩ limit_g(y,z)` via trichotomy reasoning.
- **`limit_c3_interval_subset_point`** (line 877): **PROVED sorry-free**. `limit_g(x,z) ⊆ limit_f(y)` for intermediate y.

### 2.5 BX7 (`linear_until`)

**Axioms.lean:230**:
```
| linear_until (φ ψ χ θ : Formula) : 
    |- (φ U ψ ∧ χ U θ) → ((φ∧χ) U (ψ∧θ) ∨ (φ∧χ) U (ψ∧χ) ∨ (φ∧χ) U (φ∧θ))
```

Fully proven valid under open-guard semantics in Soundness.lean:741. Available as `Axiom.linear_until` and used in MCS-level derivations via `theorem_in_mcs`. Used in `RRelation.lean:938` for the `burgessR3_absorption` lemma.

**Note**: The `linear_until_mcs` helper referenced in the plan exists as a private definition in PointInsertion.lean but the plan and handoffs reveal it's incomplete. However, BX7 can be applied directly via `theorem_in_mcs` — no special wrapper is needed since BX7 is an implication (conjunction of two Until to three-way disjunction).

---

## 3. Sorries Categorized by Burgess Paper Section

### Category A: Phase 2 — D₀ Seed Consistency (Inconsistent Case)

**Burgess Reference**: Section 2.6, p. 370 (Lemma 2.6)

| # | File:Line | Lemma | Burgess Section | Difficulty | Effort |
|---|-----------|-------|-----------------|------------|--------|
| A1 | PointInsertion.lean:1411 | `d0_a_event_list_mem` | — (infrastructure) | Easy | 1h |
| A2 | PointInsertion.lean:1858 | `h_ev_b` | 2.6 compression | Medium | 2h |
| A3 | PointInsertion.lean:1859 | `h_ev_untl` | 2.6 compression | Medium | 2h |

**A1: `d0_a_event_list_mem`** — This is a structural lemma: if `α ∈ d0_a_event_list β L hL`, prove `α ∈ A`. The function `d0_a_event_list` filters L using `Classical.choose` to extract α from `S(β', α)` formulas. The proof needs:
1. From `hα : α ∈ d0_a_event_list β L hL`, use `List.mem_filterMap` to get a source φ ∈ L
2. `hL φ ...` gives φ ∈ `burgess_D0_seed A B C β`
3. The D₀ seed definition puts `S(β', α)` in the set `{S(β', α) | β' ∈ B, α ∈ A}`, so α ∈ A
4. Use `Classical.choose_spec` to complete

**A2/A3: `h_ev_b` and `h_ev_untl`** — In the inconsistent case BX chain, after BX5 + BX13 enrichment + BX10, we have `F(event) ∈ A` and `event → γ_hat`. We also need `event → b` and `event → untl(b, γ_hat)` to show event implies every L-element. The plan (lines 487-492) says: "Event guard includes b (via BX13 enrichment with collect_guards) ... event guard includes b ∧ untl(b, γ_hat) (from BX5 output)."

**Proof approach**: Both follow from the structure of `iterated_enrichment`. The enrichment produces an event where:
- `h_untl_event : untl(event, γ_hat) ∈ A` (BX5 + enrichment preserves)
- `h_event_impl_γhat` : event implies γ_hat
- The event's guard includes `b ∧ untl(b, γ_hat)` from the BX5 self-accumulation

Key fact: `event → γ_hat` is available from enrichment output (`evt.h_impl`). What's missing is `event → b`. This can be derived from the fact that `event` is built by BX13 from `q = b ∧ untl(b, γ_hat)`. BX13 preserves the left conjunct, so `event → b` follows by propositional simplification (`lce_imp`).

For `event → untl(b, γ_hat)`: since `event → b ∧ untl(b, γ_hat)` (event carries q in its guard) and `h_untl_event` gives `untl(event, γ_hat)`, we can use propositional reasoning. Alternative: since `h_untl_event` and `h_event_impl_γhat`, we have `event → untl(b, γ_hat)` if we can connect event to b. The fact that event's construction starts from `q = b ∧ untl(b, γ_hat)` means its guard components include both.

**Assessment**: Viable. The enrichment function structure needs inspection (not done yet) but the mathematical reasoning is sound per Burgess.

### Category B: Phase 3 — Lemma 2.7 BX7 Chain

**Burgess Reference**: Section 2.7, p. 372

| # | File:Line | Lemma | Burgess Section | Difficulty | Effort |
|---|-----------|-------|-----------------|------------|--------|
| B1 | PointInsertion.lean:2400 | `lemma_2_7_seed_consistent` | 2.7 p.372 | Hard | 5h |

**Actual state**: The plan lists 5 sorries (2280, 2293, 2305, 2316, 2338) but the handoff files show that the D1/D2 elimination lemmas (2293, 2305) have their proof structures complete but have inner sorries requiring caller context. `lemma_2_7_neg_untl_exists` (2280) has one sub-sorry remaining. The main theorem at 2400 is the full sorry.

**Revised assessment**: The 5 inner sorries from the plan are partially addressed:
- `lemma_2_7_neg_untl_exists` (Task 3.1): Structure complete, one consistency subproof remaining per handoff
- `linear_until_mcs` (Task 3.2): May be trivial (BX7 is already an implication; use `theorem_in_mcs` + `conj_mcs`)
- D1/D2 elimination (Tasks 3.3-3.4): Structures complete, inner sorries need `burgessR3Maximal` context
- `lemma_2_7_seed_consistent` (Task 3.5): Full sorry

**The 10-step Burgess proof** (as outlined in plan lines 498-526):

1. Extract witness: β₀ ∈ B, γ₀ ∈ C with `¬untl(β₀ ∧ eta, γ₀) ∈ A` ✓ (in progress)
2. BX5 on `untl(b, γ_hat)`: `untl(b ∧ untl(b, γ_hat), γ_hat) ∈ A` — straightforward via `self_accum_until_mcs`
3. BX5 on `untl(xi, eta)`: `untl(xi ∧ untl(xi, eta), eta) ∈ A` — same
4. BX7 three-way disjunction — apply `Axiom.linear_until` via `theorem_in_mcs` to the conjunction of Step 2 + Step 3 results
5. Eliminate D1: `untl(b∧xi, γ_hat∧eta)` — via monotonicity + witness from step 1
6. Eliminate D2: `untl(b∧xi, γ_hat∧xi)` — same pattern
7. Surviving D3: `untl(b∧xi, b∧eta)` — this is the good disjunct
8. BX14 separation (if needed): Separate `neg(β₀∧eta)` from guard
9. BX13 iterated enrichment: Pack `snce(guard, alpha_j)` for each α_j
10. BX10 F-extraction + contradiction

**Critical insight**: The D3 surviving disjunct is `untl(b∧xi, b∧eta)` = `untl(b ∧ xi, b ∧ eta)`. This contains eta in the right-hand side (the "event" position of Until). Combined with BX13 enrichment, this creates an event whose guard contains eta, which is exactly what's needed for the 5th seed component `snce(β'∧eta, α)`.

**Assessment**: **Fully viable**. The mathematical structure is clear. The main difficulty is implementing the disjunct elimination (steps 5-6) which requires:
- Connecting `untl(b∧xi, γ_hat∧eta)` to `untl(β₀∧eta, γ₀)` via BurgessR3Maximal properties
- This is monotonicity-based: `b → β₀` (b is conjunction of all B-elements including β₀) and `γ_hat → γ₀` (γ_hat is conjunction of all C-elements), so by left/right monotonicity of Until
- The same `burgessR3Maximal` context provides `b ∈ B` and `γ_hat ∈ C`

### Category C: Phase 4 — c2' Threading Through EliminationResult

**Burgess Reference**: Sections 2.9-2.10, pp. 374-375

| # | File:Line | Context | Burgess Section | Difficulty | Effort |
|---|-----------|---------|-----------------|------------|--------|
| C1 | 756 | C5_forward elimination c2' | 2.10 | Medium | 1.5h |
| C2 | 768 | C5_forward no-elimination c2' | — | Trivial | 0.25h |
| C3 | 794 | C5_backward elimination c2' | 2.10 mirror | Medium | 1.5h |
| C4 | 806 | C5_backward no-elimination c2' | — | Trivial | 0.25h |
| C5 | 834 | C4_forward elimination c2' | 2.9 | Hard | 2h |
| C6 | 845 | C4_forward no-elimination c2' | — | Trivial | 0.25h |
| C7 | 872 | C4_backward elimination c2' | 2.9 mirror | Hard | 2h |
| C8 | 883 | C4_backward no-elimination c2' | — | Trivial | 0.25h |
| C9 | 918 | Density elimination c2' | — | Easy | 0.5h |
| C10 | 931 | Density no-elimination c2' | — | Trivial | 0.25h |

Plus two C4 hard-case sorries (lines 412, 510) — separate from c2' field.

| # | File:Line | Context | Difficulty | Effort |
|---|-----------|---------|------------|--------|
| C11 | 412 | C4 hard case (γ ∈ f(x) ∧ γ ∈ f(y)) | Hard | 3h |
| C12 | 510 | C4' hard case mirror | Hard | 3h |

#### Analysis of C1-C4 (C5/C5' elimination):

**C5 forward elimination (line 756)**: The chronicle χ' is built by `eliminate_C5_counterexample`, which calls `lemma_2_4`. Lemma 2.4 returns `BurgessR3Maximal A B C` — this directly gives c2' for the new adjacent pair, since C5 adds a new point y as rightmost element, creating a new adjacency.

The elimination function at line 167-204 adds y with f'(y) = C, and keeps g unchanged. Since the new point y is the maximum domain point, the NEW adjacent pairs are:
1. If there existed a previous maximum m: (m, y) is adjacent
2. All old adjacent pairs remain adjacent (dom extended by max element)

For case 1: need `BurgessR3Maximal(f(m), g(m,y), f(y))`. The current `eliminate_C5_counterexample` returns `χ.g` unchanged. This is a gap — the g-values are not being updated.

**Key problem**: The current elimination functions (lines 167-250 for C5/C5') keep g **unchanged**. The plan says to assign g-values from Lemma 2.4 output B. This means:
- **C5 forward**: After building χ' with `lemma_2_4`, the B from lemma_2_4 output must be used as `g'(prev_max, y)` for the new adjacent pair. But the current elimination return type uses `χ.g` (placeholder).

**Strategy for resolution**: The elimination functions must be modified to return g' that extends g with proper B assignments, OR: construct a new chronicle where g is rebuilt. Looking at `ChronicleConstruction.lean`, the omega_chain already has a g-rebuild step. The simplest approach:
1. Keep elimination functions returning χ' with placeholder g
2. Thread c2' as an explicit proof that uses lemma_2_4's B output, stored separately
3. At `ChronicleConstruction` level, when rebuilding g from c2' data, construct the proper g

**Revised approach**: The c2' field in EliminationResult can be proven from lemma_2_4's output without changing g. c2' is about the existence of some DCS interval that is BurgessR3Maximal — it doesn't require g to be that DCS. The plan's approach of having c2' as a "certificate" is correct: we prove BurgessR3Maximal exists for each adjacent pair, then separately ensure g(x,y) = that maximal DCS.

**C5 forward c2' proof sketch**:
```lean
c2' := by
  intro x' y' h_adj
  have h_c0' : χ'.c0 := ...
  -- For old adjacent pairs: they were adjacent in χ, and g is unchanged
  -- but we need to show BurgessR3Maximal exists for them
  -- This requires having an h_c2' input to eliminate_potential_counterexample
  -- (currently missing!)
```

**Critical gap**: `eliminate_potential_counterexample` signature is:
```lean
def eliminate_potential_counterexample (χ : Chronicle) (h_c0 : χ.c0)
    (pc : PotentialCounterexample) : EliminationResult χ pc
```

It does NOT take an `h_c2'` hypothesis! For the old adjacent pairs, c2' of the new chronicle comes from c2' of the old chronicle (since g is unchanged and f agrees on old points). But we need the old chronicle's c2' as input.

**The plan's Task 4a.2 says**: "Add `h_c2'` hypothesis to `eliminate_potential_counterexample` signature." This confirms the gap. The function needs to accept `h_c2' : χ.c2'`.

**For new adjacent pairs from C5**: Lemma 2.4 already returns a `BurgessR3Maximal A B C`. If we can show that C5 adds at most one new adjacent pair, and the endpoints are f(prev_max) and C, and B is maximal between them, we're done. The construction ensures:
- f'(prev_max) = χ.f(prev_max) (by f_agrees)
- f'(y) = C (by construction)
- There exists B with BurgessR3Maximal(f(prev_max), B, C) from lemma_2_4

So we prove `val.c2'` by case-splitting on whether (x',y') is the new adjacent pair or an old pair.

#### Analysis of C5-C8 (C4/C4' elimination):

**C4 forward elimination (line 834)**: Same pattern as C5. `eliminate_C4_counterexample` inserts a midpoint z. The new adjacent pairs are (prev, z) and (z, next). The hard case (lines 340-412) already has adjacency identified. What's needed:
- `BurgessR3Maximal(f(prev), B', D)` for the left new pair
- `BurgessR3Maximal(D, B'', f(next))` for the right new pair

The plan says to get B', D, B'' from `lemma_2_6_splitting`. Lemma 2.6 splitting (PointInsertion.lean:2307-2317) does exactly this: given `BurgessR3Maximal(A, B, C)` and `β ∉ B`, produce D, B', B'' with the desired maximality relations.

**The C4 hard case at line 412** requires finding these B', D, B''. The code at lines 407-412 finds the adjacent pair (w, w_next) where `neg(untl(γ,δ)) ∈ f(w)` and at `w_next`, either `w_next = y` (so δ ∈ f(y)) or `untl(γ,δ) ∈ f(w_next)`. Then:
1. Apply `burgessR3_gamma_not_in_B` to get γ ∉ g(w, w_next)
2. Apply `lemma_2_6_splitting` with `β = γ` to get B', D, B''
3. D is the MCS to assign to f(z) (the new midpoint z); B' and B'' are the g-values for the new adjacent pairs

**C4' hard case (line 510)**: Mirror using `burgessR3_gamma_not_in_B_since`.

#### Analysis of C9-C10 (Density elimination):

At line 918: density insertion just duplicates f(x) at the midpoint z. The new chronicle has g unchanged. c2' must be proved for new adjacent pairs (prev_z, z) and (z, next_z). If prev_z < z < next_z:
- For (prev_z, z): endpoints are f(prev_z) and f(x) (copy). By the plan, use `lemma_2_6_splitting` with arbitrary δ to get B', D, B''. But the density case doesn't have a specific δ ∉ g(prev_z, next_z). 
- **Alternative**: Use `burgessR3Maximal_from_g_content_sub` to build a maximal DCS directly from g_content inclusion, since `g_content(f(prev_z)) ⊆ f(z)` holds (if f(z) = f(prev_z) or if g-content is included through density reasoning).

**Simpler approach**: For density, just prove BurgessR3Maximal exists. Since `g_content(f(prev_z))` is a set of formulas, we can use `burgessR3Maximal_from_g_content_sub` which constructs a maximal DCS from g_content subset. This avoids needing `lemma_2_6_splitting` for density.

### Category D: Phase 5 — FUC/FSC Coherence

**Burgess Reference**: Section 2.11, pp. 373-374 (Claim 2.11)

| # | File:Line | Context | Burgess Section | Difficulty | Effort |
|---|-----------|---------|-----------------|------------|--------|
| D1 | 615 | Forward Until coherence (FUC) | 2.11 | Hard | 4h |
| D2 | 619 | Forward Since coherence (FSC) | 2.11 mirror | Hard | 4h |

**Dependency**: Both require `limit_satisfies_c5_full`, which requires `omega_chain_c2'` (Phase 4e), which requires all 12 Phase 4 sorries (C1-C12) closed.

**FUC proof sketch** (ChronicleToCountermodel.lean:591-619):

Given `U(φ,ψ) ∈ mcs(t)` where `mcs` is the Cantor-embedded MCS from the chronicle:

1. Extract the base chronicle (N, h_N, s) from `hfam`
2. Convert to limit coordinate: `t_offset = t - cantor_zero N h_N`, then `U(φ,ψ) ∈ limit_f(N, t_offset)`
3. Apply `limit_satisfies_c5_full` to get: `∃ y ∈ limit_dom, t_offset < y ∧ ψ ∈ limit_f(y) ∧ ∀ z ∈ limit_dom, t_offset < z < y → φ ∈ limit_f(z)`
4. Map back through Cantor isomorphism: `y_rat = (cantor_iso N h_N)⟨y, hy_dom⟩ + offset`
5. Verify: `t < y_rat`, `ψ ∈ mcs(y_rat)`, and for all `r` with `t < r < y_rat`: `φ ∈ mcs(r)`

The Cantor mapping is the main technical work. The limit structure (`cantor_bfmcs`) maps Cantor space coordinates to rationals. The proof must navigate this mapping correctly.

**Can it be proved without c2' threading from Phase 4?**

**No.** The `limit_satisfies_c5_full` proof requires:
1. At a finite stage n, C5 elimination placed φ in g_n(x,y) for an adjacent pair
2. c2' (BurgessR3Maximal) ensures g_n(x,y) is maximal, so g-values persist
3. C3 at the limit (`limit_c3`) transfers: g_n(x,y) ⊆ limit_g(x,y) ⊆ limit_f(z) for intermediate z

Without Phase 4's c2' threading, we lose step 2 — the guarantee that g-values persist through elimination steps. The weak C5 (`limit_satisfies_c5_weak`, already proved) gives only the endpoint witness, not the intermediate-point guard.

**`limit_satisfies_c5_full` proof structure**:

```lean
theorem limit_satisfies_c5_full (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (x : Rat) (hx : x ∈ limit_dom A h_mcs) (ξ η : Formula)
    (h_until : Formula.untl ξ η ∈ limit_f A h_mcs x) :
    ∃ y ∈ limit_dom A h_mcs, x < y ∧ η ∈ limit_f A h_mcs y ∧
      ∀ z ∈ limit_dom A h_mcs, x < z → z < y → ξ ∈ limit_f A h_mcs z := by
  -- From h_until, x entered domain at some stage n_x, U(ξ,η) ∈ f_{n_x}(x)
  -- The counterexample enumeration ensures ξUη is presented as a C5 counterexample
  -- at some stage m ≥ n_x
  -- At stage m, C5 elimination produces a witness y_m with:
  --   (a) y_m ∈ dom(m+1), x < y_m, η ∈ f_{m+1}(y_m)
  --   (b) ξ ∈ g_{m}(x, y_m) (this is where c2' is needed!)
  -- From (b) + c2' + C3: ξ ∈ limit_g(x, y_m)
  -- By limit_c3_interval_subset_point: ∀ z, x < z < y_m → ξ ∈ limit_f(z)
  -- Set y := y_m (or the limit point if y_m is a finite-stage point)
```

The key sub-lemma is **g-value propagation**: once ξ enters g_n(x,y) at stage n, it remains in g_k(x,y) for all k > n (as long as (x,y) remains adjacent). This requires c2' because maximality prevents g from "forgetting" formulas — if ξ could be lost, then some proper extension of g would also satisfy burgessR3, contradicting maximality.

---

## 4. Dependency Analysis

### Phase Dependency Graph

```
Phase 2 (A1-A3) ────┐
                     ├──> Phase 4a ──> Phase 4b ──> Phase 4c ──> Phase 4d ──> Phase 4e ──> Phase 5a ──> Phase 5b
Phase 3 (B1) ───────┘
                     │
                     C11, C12 (C4 hard cases) depend on Phase 2 (lemma_2_6_splitting) + Phase 4a (c2')
```

### Exact Dependencies

| Sorries | Depends On | Provides |
|---------|------------|----------|
| A1-A3 (Phase 2) | — (independent) | `burgess_D0_finite_subset_consistent_incons`, `d0_a_event_list_mem` |
| B1 (Phase 3) | A1-A3 completed (uses D₀ infrastructure) | `lemma_2_7_seed_consistent` → `lemma_2_7` |
| C1-C4, C6, C8, C10 | Phase 4a (field addition) + Phase 2 completed | c2' for C5/C5' branches |
| C5, C7 (C4 hard) | Phase 2 (`lemma_2_6_splitting`) + c2' input | c2' for C4/C4' branches |
| C9 (density) | Phase 4a | c2' for density case |
| C11, C12 (C4 hard inner) | Phase 2 (`lemma_2_6_splitting` + `burgessR3_gamma_not_in_B`) | Complete C4 elimination |
| Phase 4e | All Phase 4 sorries closed | `omega_chain_c2'` accessor |
| Phase 5a | Phase 4e | `limit_satisfies_c5_full` |
| D1, D2 | Phase 5a | FUC/FSC coherence |

### True Blockers

1. **Phase 2 → Phase 3**: SOFT dependency. Phase 3 needs `d0_a_event_list_mem` and `burgess_D0_finite_subset_consistent_incons` to exist (even if with sorries) for the `lemma_2_7` D₀ seed. **Actually, Phase 3 uses the Lemma 2.7 seed, not the D₀ seed.** The Lemma 2.7 seed is a separate definition (line 2372) that only depends on `BurgessR3Maximal`, not on Phase 2 results. So **Phase 3 can proceed independently of Phase 2**.

2. **Phase 3 → Phase 4**: Phase 4a needs `lemma_2_7` (not just `lemma_2_7_seed_consistent`) to exist for the C4/C5 elimination cases. `lemma_2_7` is proved in terms of `lemma_2_7_seed_consistent` (lines 2402-2537) and its proof IS complete except for the single seed consistency sorry. So all of Phase 4 is blocked on Phase 3's B1.

3. **Phase 4 → Phase 5**: STRICT. All 12 Phase 4 sorries must be closed before Phase 5 can work.

4. **C11/C12 → Phase 4**: C11 and C12 are the hard-case inner sorries in C4 elimination functions. These are pre-existing sorries (not in `c2'` field) and are separate from the c2' threading. The c2' threading for C4 (C5, C7) needs the C4 result chronicle to exist, but doesn't need the hard-case sorries resolved — C5/C7 just need to prove c2' holds for χ' (the chronicle returned by `eliminate_C4_counterexample`). However, C11/C12 being open means `eliminate_C4_counterexample` returns its result via sorried classical choice, which may cause build issues.

### Can Any Phases Proceed in Parallel?

| Phase Pair | Parallel? | Rationale |
|------------|-----------|-----------|
| Phase 2 + Phase 3 | **YES** | Lemma 2.7 seed doesn't use D₀ seed infrastructure |
| Phase 3 + Phase 4a | **NO** | Phase 4a depends on lemma_2_7 being sorry-free |
| Phase 4b + Phase 4c | **WITH CARE** | 4b is C5, 4c is C4. Different elimination branches. Can work if 4a done. |
| Phase 4d + Phase 4b/4c | **YES** | Density is independent of C4/C5 elimination logic |
| Phase 5a + 5b | Sequential only | 5b depends on 5a's `limit_satisfies_c5_full` |

### No Circular Dependencies Found

The dependency structure is a clean DAG. All phases proceed forward without needing earlier phases to be revisited. The only subtlety is that Phase 4a requires `lemma_2_7` to be sorry-free, which requires Phase 3 to be complete.

---

## 5. Proof Sketches

### 5.1 Phase 2 — Inconsistent Case Compression

**`d0_a_event_list_mem`** (A1):

```lean
theorem d0_a_event_list_mem {A B C : Set Formula}
    {β : Formula} {L : List Formula}
    {hL : ∀ φ ∈ L, φ ∈ burgess_D0_seed A B C β}
    {α : Formula} (hα : α ∈ d0_a_event_list β L hL) : α ∈ A := by
  rcases List.mem_filterMap.mp hα with ⟨φ, hφL, hφm⟩
  have hφD0 := hL φ hφL
  -- hφm: φ matches the Since case in filterMap, so φ = snce(β', α) for some β'
  -- Use D0 seed definition to extract α ∈ A
  have hφ_snce : ∃ β' ∈ B, ∃ α' ∈ A, φ = Formula.snce β' α' := ...
  obtain ⟨β', hβ'B, α', hα'A, hφ_eq⟩ := ...
  -- Also from hφm we get α = Classical.choose (Classical.choose_spec ...).2 = α'
  have h_eq_α : α = α' := ...
  rw [h_eq_α]; exact hα'A
```

**`h_ev_b` and `h_ev_untl`** (A2-A3):

The iterated_enrichment structure returns:
```lean
structure IteratedEnrichmentResult where
  event' : Formula
  h_untl : Formula.untl event' γ_hat ∈ A
  h_impl : DerivationTree [] (event'.imp γ_hat)
  h_snce : ∀ α ∈ a_list, DerivationTree [] (event'.imp (Formula.snce (b) α))
```

Need to extract: `event' → b` and `event' → untl(b, γ_hat)`.

From enrichment construction: event' is built from `q = b ∧ untl(b, γ_hat)` via BX13. BX13 adds `snce(q, α)` to the guard for each α ∈ a_list. The resulting event' has the form:
```
event' = q ∧ some_snce ∧ ...  = b ∧ untl(b, γ_hat) ∧ ...
```

So `event' → b` by `lce_imp b (untl(b, γ_hat) ∧ ...)`.

And `event' → untl(b, γ_hat)` by `rce_imp b (untl(b, γ_hat))`.

These are standard propositional derivations.

### 5.2 Phase 4b — C5 Elimination c2'

Adding `h_c2'` to `eliminate_potential_counterexample`:

```lean
noncomputable def eliminate_potential_counterexample
    (χ : Chronicle) (h_c0 : χ.c0) (h_c2' : χ.c2')  -- ← ADDED h_c2'
    (pc : PotentialCounterexample) : EliminationResult χ pc := by
```

Then at C5 forward branch (line ~751):
```lean
c2' := by
  intro x' y' h_adj
  -- x' < y', both in val.dom, Adjacent
  -- Two cases: (x', y') was adjacent in χ (old pair) or is the new pair
  have h_new_dom : val.dom = insert y χ.dom := ... (from elimination construction)
  rcases em (x' ∈ χ.dom ∧ y' ∈ χ.dom) with ⟨hx_old, hy_old⟩ | h_not_both
  · -- Old adjacent pair: g unchanged, f agrees on old points
    have h_adj_old : Adjacent χ.dom x' y' := ...
    have h_old_c2' := h_c2' x' y' h_adj_old
    have h_f_agree : val.f x' = χ.f x' := f_agrees x' hx_old
    have h_f_agree' : val.f y' = χ.f y' := f_agrees y' hy_old
    have h_g_agree : val.g x' y' = χ.g x' y' := g_agrees x' y' hx_old hy_old
    -- Rewrite using agreements
    rw [h_f_agree, h_f_agree', h_g_agree]
    exact h_old_c2'
  · -- New adjacent pair: this involves y (the new point)
    -- The only new point is y, so either y' = y or (if y was inserted as successor)
    -- From the C5 construction: the new point is y, at the end of domain
    -- Adjacent pair is (max_old, y) where max_old is max element of χ.dom
    have h_max : ∃ max_old ∈ χ.dom, x' = max_old ∧ y' = y := ...
    obtain ⟨max_old, hmax, hx_eq, hy_eq⟩ := h_max
    subst hx_eq; subst hy_eq
    -- x' = max_old, y' = y = the new point
    have h_f_max : val.f max_old = χ.f max_old := f_agrees max_old hmax
    have h_f_y : val.f y = C := by simp
    -- Need: BurgessR3Maximal(χ.f max_old, g'(max_old, y), C)
    -- From lemma_2_4: there exists B with BurgessR3Maximal(χ.f max_old, B, C)
    -- We can show g'(max_old, y) = B (if g is properly assigned)
    -- OR: prove that ANY g' that equals B works
    sorry -- This is where g-value assignment is needed
```

The "no-elimination" cases (C2, C4, C6, C8, C10) are trivial: chronicle unchanged, so c2' is just `h_c2'`.

### 5.3 Phase 5a — `limit_satisfies_c5_full`

```lean
theorem limit_satisfies_c5_full (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (x : Rat) (hx : x ∈ limit_dom A h_mcs) (ξ η : Formula)
    (h_until : Formula.untl ξ η ∈ limit_f A h_mcs x) :
    ∃ y ∈ limit_dom A h_mcs, x < y ∧ η ∈ limit_f A h_mcs y ∧
      ∀ z ∈ limit_dom A h_mcs, x < z → z < y → ξ ∈ limit_f A h_mcs z := by
  -- Step 1: Get finite stage n_x where x enters domain
  obtain ⟨n_x, hn_x⟩ := hx
  -- Step 2: h_until at limit means h_until at some finite stage ≥ n_x
  have h_until_n : Formula.untl ξ η ∈ (omega_chain_val A h_mcs n_x).f x := ...
  -- Step 3: The counterexample enumeration will eventually present this as C5
  -- Find stage m ≥ n_x such that counterexample_enum (Nat.unpair m).2 = (x, 0, ξ, η, c5_forward)
  -- This is guaranteed by construction (counterexample_enum is surjective onto potential counterexamples)
  -- Step 4: Apply C5 elimination at stage m
  have h_witness := omega_chain_c5_witness A h_mcs _ _ _ _ _ _ _
  obtain ⟨y, hy_dom, hx_lt_y, h_η_y⟩ := h_witness
  -- Step 5: From c2' at finite stage, get ξ ∈ g(x, y) at some stage
  -- (This requires omega_chain_c2' from Phase 4e)
  have h_c2'_m : (omega_chain_val A h_mcs m).c2' := omega_chain_c2' A h_mcs m
  -- At stage m+1: (x,y) is adjacent in dom(m+1) ← need to verify
  -- From c2': BurgessR3Maximal(f(x), g(x,y), f(y))
  -- By construction, ξ ∈ g(x,y) (C5 elimination placed it there)
  have h_ξ_g : ξ ∈ (omega_chain_val A h_mcs (m + 1)).g x y := ...
  -- Step 6: g-value propagates to limit
  have h_ξ_limit_g : ξ ∈ limit_g A h_mcs x y := ...
  -- Step 7: By limit_c3_interval_subset_point: ∀ z, x < z < y → ξ ∈ limit_f(z)
  refine ⟨y, ⟨m+1, hy_dom⟩, hx_lt_y, h_η_y, ?_⟩
  intro z ⟨n_z, hz_dom_n⟩ hxz hzy
  have hz_limit_dom : z ∈ limit_dom A h_mcs := ⟨n_z, hz_dom_n⟩
  have h_interval := limit_c3_interval_subset_point A h_mcs x z y
    (by exact ⟨n_x, hn_x⟩) (by exact ⟨n_z, hz_dom_n⟩) (by exact ⟨m+1, hy_dom⟩)
    hxz hzy
  exact h_interval h_ξ_limit_g
```

The hardest sub-proof is step 5: establishing that ξ ∈ g(x, y) at the finite stage. This requires inspecting the C5 elimination construction to confirm that the guard ξ is placed in g(x, y).

---

## 6. Updated Timeline Estimate

| Phase | Tasks | Original Est. | Revised Est. | Rationale |
|-------|-------|---------------|-------------|-----------|
| 2 | A1-A3 | 4-6h | 2-3h | Two sorries are straightforward propositional derivations; one is structural |
| 3 | B1 | 5-7h | 6-8h | Inner sub-proofs need to be filled + 10-step chain orchestration |
| 4a | Add c2' field + h_c2' param | 2-3h | 1-2h | Field addition is mechanical; h_c2' param addition is signature change |
| 4b | C1-C4 (C5/C5' c2') | 2-3h | 3-4h | g-value assignment requires understanding lemma_2_4 output structure |
| 4c | C5-C8 (C4/C4' c2') | 2-3h | 3-4h | Same as 4b but uses lemma_2_6_splitting |
| 4d | C9-C10 (density) | 1-2h | 1-2h | Relatively simple; uses Zorn existence |
| 4e | omega_chain c2' threading | 2-3h | 2-3h | Standard induction after 4a-4d complete |
| 5a | limit_satisfies_c5_full | 8-12h | 8-10h | g-value propagation is the main work |
| 5b | D1-D2 (FUC/FSC) | 4-6h | 4-6h | Cantor mapping + limit_satisfies_c5_full application |
| 5c | Final audit | 1-2h | 1-2h | Mechanical verification |
| **Total** | | **31-47h** | **31-44h** | |

Plus C11-C12 (C4 hard-case inner sorries): **6h** (not included in the plan's c2' thread estimates but are separate blocking sorries)

**Grand total**: ~37-50h remaining.

---

## 7. Recommended Execution Order

### Wave 1: Foundation (can partially parallelize)

1. **Phase 2** (Task A1-A3): ~2-3h
   - Close `d0_a_event_list_mem` first (easiest)
   - Then `h_ev_b` and `h_ev_untl` by inspecting `iterated_enrichment` structure
   
2. **Phase 3** (Task B1) — IN PARALLEL with Phase 2: ~6-8h
   - Close `lemma_2_7_neg_untl_exists` consistency subproof (handoff)
   - Implement `linear_until_mcs` (trivial — just `theorem_in_mcs` + `conj_mcs`)
   - Fill D1/D2 inner sorries using BurgessR3Maximal properties
   - Complete 10-step `lemma_2_7_seed_consistent`

### Wave 2: c2' Infrastructure (strictly sequential)

3. **Phase 4a**: ~1-2h
   - Add `(h_c2' : χ.c2')` parameter to `eliminate_potential_counterexample`
   - This will create type errors at all call sites → fix them mechanically

### Wave 3: c2' Branches (can partially parallelize)

4. **Phase 4b** (Tasks C1-C4): ~3-4h — C5/C5' c2'
5. **Phase 4d** (Tasks C9-C10): ~1-2h — Density c2' (can run parallel to 4b)
6. **Phase 4c** (Tasks C5-C8): ~3-4h — C4/C4' c2' (needs lemma_2_6_splitting from Phase 2)

### Wave 4: Hard Cases + Threading

7. **C11-C12**: ~6h — C4 hard-case inner sorries (needs Phase 4a + Phase 2)
8. **Phase 4e**: ~2-3h — omega_chain c2' threading (needs all Wave 3 complete)

### Wave 5: Limit Properties + Final

9. **Phase 5a**: ~8-10h — `limit_satisfies_c5_full`
10. **Phase 5b**: ~4-6h — FUC/FSC
11. **Phase 5c**: ~1-2h — Final audit

### Critical Path

```
Phase 3 (6-8h) → Phase 4a (1-2h) → Phase 4c (3-4h) → Phase 4e (2-3h) → Phase 5a (8-10h) → Phase 5b (4-6h)
= 24-33h critical path
```

---

## 8. Key Risks and Mitigations

### Risk 1: g-value assignment in Phase 4b/c is underspecified in elimination functions
**Severity**: HIGH — the elimination functions return `χ.g` unchanged, but c2' requires specific g-values.
**Mitigation**: Add g as a proper output of elimination, or thread g through EliminationResult. The plan already anticipates this: Task 4b.1 says "Construct g' that assigns B to the new adjacent pair."

### Risk 2: `linear_until_mcs` is harder than expected
**Severity**: LOW — BX7 is already an implication, so `theorem_in_mcs` suffices. Only need to close the conjunction of two Until formula memberships.

### Risk 3: Infinite regress in enumerating C5 counterexamples at the limit
**Severity**: MEDIUM — `limit_satisfies_c5_full` must connect `U(ξ,η) ∈ limit_f(x)` to a specific finite stage where the C5 elimination occurred.
**Mitigation**: The `counterexample_enum` is surjective onto potential counterexamples. Since `limit_f` is defined from the omega-chain union, each `U(ξ,η)` appearing at the limit appeared at some finite stage. The surjectivity ensures it was eventually eliminated.

### Risk 4: Cantor isomorphism mapping in Phase 5b
**Severity**: MEDIUM — Moving witnesses between `limit_dom` coordinates and `cantor_bfmcs` coordinates.
**Mitigation**: The proof structure in the plan (lines 330-351) provides a template. The Cantor isomorphism is already defined and proved to be a bijection.

---

## 9. Recommendations for Implementation

1. **Start with Phase 2 + Phase 3 in parallel** to build momentum. These are the oldest sorries and have the clearest proof strategies.

2. **Inspect `iterated_enrichment` before tackling A2/A3** — the proof that `event → b` depends on knowing the enrichment's structure.

3. **For Phase 4a**: Add `h_c2'` as a field to `Chronicle` rather than as a parameter to `eliminate_potential_counterexample`. This makes c2' part of the chronicle invariant (like c0) rather than threading it through every function signature. The omega_chain already carries c0 — it can carry c2' as well.

4. **For C4 hard cases (C11-C12)**: The plan says "Use burgessR3_gamma_not_in_B (or induction + BX6 for nested case)." The non-nested version is already available. Start with the simpler case and escalate if needed.

5. **For Phase 5a**: Leverage the already-proved `limit_c3_interval_subset_point` lemma. The main missing piece is the g-value propagation lemma connecting finite-stage g to limit_g.

6. **Do NOT** attempt to skip Phase 4e (omega_chain c2'). The Phase 5 proofs absolutely require finite-stage g-values to be threaded through the limit.

---

## 10. Sources

- Burgess 1982: `/home/benjamin/Projects/ProofChecker/literature/Burgess_1982_Axioms_for_tense_logic_Since_and_Until.md`
- Implementation plan: `specs/107_chain_design_diagnostics_for_representation_theorem/plans/53_implementation-plan.md`
- Handoffs: `handoffs/phase3-task3.1.md`, `handoffs/phase3-tasks3.3-3.4.md`
- Summary: `summaries/53_implementation-summary.md`
- Phase 2 research: `reports/lean-research-phase2-burgess.md`
- Source files inspected:
  - `ChronicleTypes.lean` (lines 310-389)
  - `CounterexampleElimination.lean` (lines 395-948)
  - `PointInsertion.lean` (lines 1390-2540)
  - `RRelation.lean` (lines 820-860, 1130-1180)
  - `ChronicleConstruction.lean` (lines 270-930)
  - `Axioms.lean` (line 230)
  - `Soundness.lean` (line 741)
