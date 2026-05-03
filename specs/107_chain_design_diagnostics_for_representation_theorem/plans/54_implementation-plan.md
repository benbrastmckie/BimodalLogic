# Implementation Plan: Task #107 — Chain Design Diagnostics for Representation Theorem

- **Task**: 107 - Chain design diagnostics for representation theorem
- **Status**: [NOT STARTED]
- **Effort**: 37-50 hours
- **Dependencies**: Task 113 [COMPLETED] (open-guard semantics)
- **Research Inputs**: `reports/54_research-remaining-phases.md` (sole authority for this version)
- **Artifacts**: plans/54_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true
- **Plan Version**: 54
- **Complexity**: complex

## Overview

This plan incorporates the comprehensive v54 research report findings to achieve a sorry-free `dd_countermodel_chronicle` for the BX completeness representation theorem. The plan systematically closes all 22 active sorries across 3 files, following Burgess 1982 Sections 2.6-2.11 faithfully. The research confirms a clean DAG with no circular dependencies.

**Corrected status**: Plan v53 incorrectly marked Phase 2 as `[COMPLETED]`. Research v54 confirmed 3 Phase 2 sorries remain open. This plan represents ground truth as of 2026-05-03.

**Definition of Done**: `#print axioms dd_countermodel_chronicle` shows no `sorryAx`; `lake build` succeeds; `grep -rn "sorry" Theories/Bimodal/Metalogic/BXCanonical/Chronicle/` returns only comments.

### Research Integration

The v54 research report (single authoritative source for this plan version) confirmed:

- **Phase 2 (D0 Seed Inconsistent Case)**: 3 sorries remain (A1-A3). A1 (`d0_a_event_list_mem`) is structural/Classical.choose. A2/A3 (`h_ev_b`, `h_ev_untl`) follow from `iterated_enrichment` structure via propositional derivations. All are viable.
- **Phase 3 (Lemma 2.7 BX7 Chain)**: 1 main sorry (`lemma_2_7_seed_consistent`) with inner sub-proofs partially structured. The 10-step Burgess proof is fully viable with BX7 (`linear_until`) available via `theorem_in_mcs`.
- **Phase 4 (c2' Threading)**: 16 sorries in CounterexampleElimination.lean — 10 `c2'` field sorries in EliminationResult, 4 "no elimination" trivial cases, 2 C4 hard-case inner sorries (C11/C12).
- **Phase 5 (FUC/FSC Coherence)**: 2 sorries strictly blocked on Phase 4e (`omega_chain_c2'`).
- **Critical path**: Phase 3 → 4a → 4c → 4e → 5a → 5b (~24-33h).
- **Parallelism**: Phases 2 and 3 are independent and can execute concurrently (Phase 3 uses Lemma 2.7 seed, not D0 seed).

**Correction to plan v53**: The v53 plan said Phase 3 depends on Phase 2. The v54 research established that `lemma_2_7_seed` (line 2372) depends only on `BurgessR3Maximal`, not on Phase 2 D0 seed infrastructure. Phases 2 and 3 can proceed in parallel.

## Goals & Non-Goals

**Goals**:
- Close all 4 sorries in PointInsertion.lean (3 Phase 2 + 1 Phase 3)
- Close all 16 sorries in CounterexampleElimination.lean (Phase 4)
- Close both sorries in ChronicleToCountermodel.lean (Phase 5)
- Thread c2' (BurgessR3Maximal at adjacent pairs) through `omega_chain`
- Prove `limit_satisfies_c5_full` with complete guard propagation
- Achieve sorry-free `dd_countermodel_chronicle`
- Maintain `lake build` at each phase boundary

**Non-Goals**:
- Generalizing beyond D=Rat to arbitrary ordered groups
- Optimizing proof term sizes or compilation speed
- Refactoring Chronicle type hierarchy beyond c2' addition
- Addressing sorries outside the Chronicle/ directory
- Implementing Lemma 2.8 (not needed for completeness)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| g-value assignment in Phase 4b/c underspecified in elimination functions | High | High | Add g as proper output of elimination, or thread g through EliminationResult. Task 4b.1 constructs g' explicitly |
| `linear_until_mcs` harder than expected | Low | Low | BX7 is already an implication; `theorem_in_mcs` + `conj_mcs` suffices |
| Infinite regress in enumerating C5 counterexamples at limit | Medium | Medium | `counterexample_enum` is surjective; each `U(ξ,η)` at limit appeared at finite stage |
| Cantor isomorphism mapping in Phase 5b | Medium | Medium | Cantor isomorphism already defined and proved bijective; plan provides proof template |
| C4 hard-case inner sorries (C11/C12) require nested case analysis | High | Medium | Start with non-nested version using `burgessR3_gamma_not_in_B`; escalate to induction + BX6 if needed |
| Phase 2 sorries still open despite plan v53 `[COMPLETED]` | High | Confirmed | This plan resets Phase 2 to `[NOT STARTED]` with accurate 3-sorry count |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 2, 3 | -- |
| 2 | 4a | 3 |
| 3 | 4b, 4d | 4a |
| 4 | 4c, C11/C12 | 2, 4a |
| 5 | 4e | 4b, 4c, 4d, C11/C12 |
| 6 | 5a | 4e |
| 7 | 5b, 5c | 5a |

Phases within the same wave can execute in parallel. Waves 1-2 are shown as sequential because Phase 3 must complete for Phase 4a, but Phase 2 runs independently in parallel with Phase 3.

---

### Phase 2: Close D0 Seed Inconsistent Case Sorries [NOT STARTED]

**Goal**: Close 3 sorries in PointInsertion.lean left incomplete from plan v53. These are the D0 seed inconsistency proof infrastructure.

**Tasks**:
- [ ] **Task 2.1**: Close `d0_a_event_list_mem` (line ~1411)
  - Structural lemma using `Classical.choose` reasoning and `List.mem_filterMap`
  - Proof: from `hα : α ∈ d0_a_event_list β L hL`, use `List.mem_filterMap` to get source φ ∈ L, apply `hL φ` to get φ ∈ `burgess_D0_seed`, extract α ∈ A via D0 seed definition
  - **Difficulty**: Easy
  - **Files**: `PointInsertion.lean`

- [ ] **Task 2.2**: Close `h_ev_b` (line ~1858)
  - Derive `event → b` from `iterated_enrichment` structure
  - Proof: enrichment builds event from `q = b ∧ untl(b, γ_hat)` via BX13; BX13 preserves left conjunct; apply `lce_imp` for propositional simplification
  - **Difficulty**: Medium
  - **Files**: `PointInsertion.lean`
  - **Depends on**: inspecting `iterated_enrichment` structure

- [ ] **Task 2.3**: Close `h_ev_untl` (line ~1859)
  - Derive `event → untl(b, γ_hat)` from enrichment
  - Proof: event carries `b ∧ untl(b, γ_hat)` in its guard, so `event → untl(b, γ_hat)` by `rce_imp`; alternative: from `h_untl_event` and `h_event_impl_γhat`
  - **Difficulty**: Medium
  - **Files**: `PointInsertion.lean`

**Timing**: 2-3 hours

**Depends on**: None. Independent of Phase 3 (Lemma 2.7 seed does not use D0 seed infrastructure per v54 research).

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean`

**Verification**:
- PointInsertion.lean Phase 2 sorry count: 0 (3 sorries closed)
- `lake build` succeeds

---

### Phase 3: Implement Lemma 2.7 with BX7 Chain [NOT STARTED]

**Goal**: Close the main `lemma_2_7_seed_consistent` sorry and all inner sub-proofs, completing the Lemma 2.7 BX7 chain proof per Burgess 1982 Section 2.7, p. 372.

**Status**: The v53 implementation created full proof structure skeletons. Inner sorries remain in:
- `lemma_2_7_neg_untl_exists` (line ~2280): one consistency subproof
- `lemma_2_7_disjunct_elim_D1` (line ~2293): inner sorry requiring BurgessR3Maximal context
- `lemma_2_7_disjunct_elim_D2` (line ~2305): same pattern
- `lemma_2_7_seed_consistent` (line ~2316/2400): main orchestration sorry

**Tasks**:
- [ ] **Task 3.1**: Close `lemma_2_7_neg_untl_exists` consistency subproof
  - Extract witness: β₀ ∈ B, γ₀ ∈ C with `¬untl(β₀ ∧ eta, γ₀) ∈ A` from BurgessR3Maximal maximality
  - Uses: unfold `BurgessR3Maximal`, `extension_fails` to extract neg-until witness
  - **Difficulty**: Medium

- [ ] **Task 3.2**: Verify `linear_until_mcs` is trivial
  - BX7 (`Axiom.linear_until`) already exists as implication
  - Apply `theorem_in_mcs` + `conj_mcs` for conjunction of two Until memberships
  - If wrapper incomplete, implement trivially
  - **Difficulty**: Easy

- [ ] **Task 3.3**: Fill D1 disjunct elimination inner sorry
  - Show D1 (`untl(b∧xi, γ_hat∧eta)`) contradicts `¬untl(β₀∧eta, γ₀)`
  - Right monotonicity: `γ_hat∧eta → eta`, left monotonicity: `b → β₀` (b is conjunction of B-elements)
  - Apply `burgessR3Maximal` properties for `b ∈ B`, `γ_hat ∈ C`
  - **Difficulty**: Medium

- [ ] **Task 3.4**: Fill D2 disjunct elimination inner sorry
  - Mirror of Task 3.3: `untl(b∧xi, γ_hat∧xi)` contradicts witness
  - Right monotonicity: `γ_hat∧xi → eta` (via xi structure)
  - **Difficulty**: Medium

- [ ] **Task 3.5**: Close `lemma_2_7_seed_consistent` main proof
  - Orchestrate 10-step Burgess chain:
    1. Extract witness (Task 3.1 result)
    2. BX5 self-accumulation on `untl(b, γ_hat)`
    3. BX5 self-accumulation on `untl(xi, eta)`
    4. BX7 three-way disjunction (Task 3.2 result)
    5. Eliminate D1 (Task 3.3)
    6. Eliminate D2 (Task 3.4)
    7. Surviving D3: `untl(b∧xi, b∧eta)` — this is the good disjunct
    8. BX14 separation (if needed)
    9. BX13 iterated enrichment
    10. BX10 F-extraction + contradiction
  - **Difficulty**: Hard

**Timing**: 6-8 hours

**Depends on**: None. Independent of Phase 2 (per v54 research). Can run in parallel with Phase 2.

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean`

**Verification**:
- `lemma_2_7_seed_consistent` compiles sorry-free
- All inner helper lemmas closed
- PointInsertion.lean sorry count: 0
- `lake build` succeeds

---

### Phase 4a: Refactor EliminationResult to Carry c2' [NOT STARTED]

**Goal**: Add `c2'` field to `EliminationResult` structure and thread `h_c2'` parameter through elimination functions, enabling proper BurgessR3Maximal tracking at adjacent pairs.

**Tasks**:
- [ ] **Task 4a.1**: Add `c2'` field to `EliminationResult` structure:
  ```lean
  (c2' : ∀ x y : Rat, Adjacent val.dom x y → 
         BurgessR3Maximal (val.f x) (val.g x y) (val.f y))
  ```
  Note: domain is `val.dom` (the NEW chronicle's domain), not `χ.dom` (the old one).
  - **Files**: `CounterexampleElimination.lean` (where `EliminationResult` is defined, ~line 693)

- [ ] **Task 4a.2**: Add `(h_c2' : χ.c2')` parameter to `eliminate_potential_counterexample` signature alongside existing `h_c0`.
  - This will create type errors at ALL call sites — fix mechanically.

- [ ] **Task 4a.3**: Update all call sites to provide `c2'` proof. Sites include:
  - `eliminate_C5_counterexample` — will need Phase 4b
  - `eliminate_C5'_counterexample` — mirror
  - `eliminate_C4_counterexample` — will need Phase 4c
  - `eliminate_C4'_counterexample` — mirror
  - Density elimination case — will need Phase 4d

- [ ] **Task 4a.4**: Run `lake build` to identify all type errors from signature changes.

**Timing**: 1-2 hours

**Depends on**: Phase 3 (`lemma_2_7` must be sorry-free, since `lemma_2_4` used in C5 elimination depends on it).

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean`

**Verification**:
- `EliminationResult` carries `c2'` field
- All constructions type-check with updated signatures
- `lake build` succeeds (may have sorries at c2' proof sites — resolved in 4b-4d)

---

### Phase 4b: Prove c2' for C5/C5' Elimination Branches [NOT STARTED]

**Goal**: Close 4 sorries in C5/C5' elimination branches by proving `BurgessR3Maximal` for each adjacent pair in the eliminated chronicle.

**Tasks**:
- [ ] **Task 4b.1**: Close C5 forward elimination c2' (line ~756)
  - New chronicle χ' from `eliminate_C5_counterexample`
  - Two cases for adjacent (x', y'):
    - **Old adjacent pair** (both in χ.dom): g unchanged, f agrees → reuse `h_c2'` from χ
    - **New adjacent pair** (involves y, the new endpoint): endpoints are f(prev_max) and C; Lemma 2.4 gives `BurgessR3Maximal(f(prev_max), B, C)` for some B; prove c2' using this B (g-value assignment may require separate handling if g is placeholder)
  - **Difficulty**: Medium

- [ ] **Task 4b.2**: Close C5 forward no-elimination c2' (line ~768)
  - Trivial: chronicle unchanged, c2' is just `h_c2'`
  - **Difficulty**: Trivial

- [ ] **Task 4b.3**: Close C5 backward elimination c2' (line ~794)
  - Mirror of Task 4b.1 for Since direction
  - **Difficulty**: Medium

- [ ] **Task 4b.4**: Close C5 backward no-elimination c2' (line ~806)
  - Mirror of Task 4b.2
  - **Difficulty**: Trivial

**Timing**: 3-4 hours

**Depends on**: Phase 4a (c2' field + h_c2' parameter exist), Phase 3 (lemma_2_4 available)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean`

**Verification**:
- 4 C5-related sorries closed (lines ~756, 768, 794, 806)
- `lake build` succeeds

---

### Phase 4c: Prove c2' for C4/C4' Elimination Branches [NOT STARTED]

**Goal**: Close 4 sorries in C4/C4' elimination branches using `lemma_2_6_splitting` to construct proper g-values and c2' proofs.

**Tasks**:
- [ ] **Task 4c.1**: Close C4 forward elimination c2' (line ~834)
  - New chronicle χ' from `eliminate_C4_counterexample` inserts midpoint z
  - New adjacent pairs: (prev, z) and (z, next)
  - Apply `lemma_2_6_splitting` with `β = γ` to get B', D, B''
  - For old pairs: reuse `h_c2'` from χ; for new pairs: BurgessR3Maximal from splitting lemma output
  - **Difficulty**: Hard

- [ ] **Task 4c.2**: Close C4 forward no-elimination c2' (line ~845)
  - Trivial: chronicle unchanged
  - **Difficulty**: Trivial

- [ ] **Task 4c.3**: Close C4 backward elimination c2' (line ~872)
  - Mirror of Task 4c.1 for Since direction using `burgessR3_gamma_not_in_B_since`
  - **Difficulty**: Hard

- [ ] **Task 4c.4**: Close C4 backward no-elimination c2' (line ~883)
  - Mirror of Task 4c.2
  - **Difficulty**: Trivial

**Timing**: 3-4 hours

**Depends on**: Phase 2 (`lemma_2_6_splitting` must be sorry-free), Phase 4a (c2' infrastructure)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean`

**Verification**:
- 4 C4-related sorries closed (lines ~834, 845, 872, 883)
- `lake build` succeeds

---

### Phase 4d: Prove c2' for Density Elimination [NOT STARTED]

**Goal**: Close 2 sorries in density elimination by constructing c2' proofs when inserting a midpoint without a specific counterexample.

**Tasks**:
- [ ] **Task 4d.1**: Close density elimination c2' (line ~918)
  - Midpoint z inserted between x and y
  - New adjacent pairs: (x, z) and (z, y)
  - Use `burgessR3Maximal_from_g_content_sub` to construct maximal DCS from g_content inclusion (simpler than splitting — density doesn't have a specific δ)
  - **Difficulty**: Easy

- [ ] **Task 4d.2**: Close density no-elimination c2' (line ~931)
  - Trivial: chronicle unchanged
  - **Difficulty**: Trivial

**Timing**: 1-2 hours

**Depends on**: Phase 4a (c2' infrastructure)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean`

**Verification**:
- 2 density sorries closed (lines ~918, 931)
- `lake build` succeeds

---

### C4 Hard-Case Inner Sorries (C11/C12) [NOT STARTED]

**Goal**: Close the 2 hard-case inner sorries in C4/C4' elimination functions. These are pre-existing sorries separate from the c2' field threading.

**Tasks**:
- [ ] **Task C11**: Close C4 hard case (line ~412)
  - Situation: `γ ∈ f(w) ∧ γ ∈ f(w_next)` with `neg(untl(γ,δ)) ∈ f(w)`
  - The code finds adjacent pair (w, w_next) where `neg(untl(γ,δ)) ∈ f(w)`; at w_next, either `w_next = y` (so δ ∈ f(y)) or `untl(γ,δ) ∈ f(w_next)`
  - Apply: `burgessR3_gamma_not_in_B` to get γ ∉ g(w, w_next)
  - Then: `lemma_2_6_splitting` with `β = γ` to get B', D, B'' — D becomes f(z)
  - **Difficulty**: Hard

- [ ] **Task C12**: Close C4' hard case mirror (line ~510)
  - Mirror using `burgessR3_gamma_not_in_B_since`
  - **Difficulty**: Hard

**Timing**: 6 hours (3h each)

**Depends on**: Phase 2 (`lemma_2_6_splitting` + `burgessR3_gamma_not_in_B` must be sorry-free), Phase 4a (caller context)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean`

**Verification**:
- C4/C4' hard-case sorries closed (lines ~412, ~510)
- `lake build` succeeds

---

### Phase 4e: Thread c2' Through omega_chain [NOT STARTED]

**Goal**: Change `omega_chain` return type to carry both c0 and c2' as joint invariant, ensuring g-values persist through the limit construction.

**Tasks**:
- [ ] **Task 4e.1**: Change `omega_chain` return type to include `omega_chain_c2'` accessor alongside existing `omega_chain_c0`
  - `ChronicleConstruction.lean`

- [ ] **Task 4e.2**: Update base case: singleton chronicle satisfies c2' vacuously (no adjacent pairs in singleton domain)
  - Standard proof: `∀ x y, Adjacent {a} x y → ...` is vacuously true

- [ ] **Task 4e.3**: Update step case: Use `c2'` field from `EliminationResult` (obtained from Phases 4b-4d)
  - Induction: assume `omega_chain_c2'` for stage n, apply `eliminate_potential_counterexample` with `h_c2'` from induction hypothesis, extract `c2'` from result

- [ ] **Task 4e.4**: Add `omega_chain_c2'` accessor lemma:
  ```lean
  lemma omega_chain_c2' (A : Set Formula) (h_mcs : SetMaximalConsistent A) (n : ℕ) :
    (omega_chain_val A h_mcs n).c2'
  ```

- [ ] **Task 4e.5**: Run `lake build` — verify omega_chain correctly threads c2' through all elimination steps

**Timing**: 2-3 hours

**Depends on**: Phase 4a-4d (all elimination functions provide c2' proofs), C11/C12

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean`

**Verification**:
- `omega_chain` carries c0 + c2' joint invariant
- All elimination steps preserve c2' through induction
- `lake build` succeeds

---

### Phase 5a: Prove limit_satisfies_c5_full [NOT STARTED]

**Goal**: Strengthen C5 from weak (endpoint only) to full (endpoint plus guard at all intermediate points), enabling the truth lemma for Until formulas.

**Tasks**:
- [ ] **Task 5a.1**: Prove g-value propagation lemma (~100 lines, ~4-6 hours)
  - At finite stage n, if C5 elimination at step k placed ξ in g_k(x,y), then ξ ∈ g_n(x,y) for all subsequent stages where (x,y) remains adjacent
  - Uses: c2' maximality ensures g-values persist; if ξ could be lost, some proper extension of g would also satisfy burgessR3, contradicting maximality

- [ ] **Task 5a.2**: Prove `limit_satisfies_c5_full` (~120 lines, ~4-6 hours):
  ```lean
  theorem limit_satisfies_c5_full (A : Set Formula) (h_mcs : SetMaximalConsistent A)
      (x : Rat) (hx : x ∈ limit_dom A h_mcs) (ξ η : Formula)
      (h_until : Formula.untl ξ η ∈ limit_f A h_mcs x) :
      ∃ y ∈ limit_dom A h_mcs, x < y ∧ η ∈ limit_f A h_mcs y ∧
        ∀ z ∈ limit_dom A h_mcs, x < z → z < y → ξ ∈ limit_f A h_mcs z := by
    -- Step 1: x enters domain at some finite stage n_x
    -- Step 2: h_until at limit means h_until at some finite stage ≥ n_x
    -- Step 3: counterexample_enum (surjective) presents U(ξ,η) as C5 at some stage m
    -- Step 4: C5 elimination gives witness y with η ∈ f_{m+1}(y)
    -- Step 5: From omega_chain_c2' (Phase 4e): at stage m+1, (x,y) adjacent and c2' holds
    -- Step 6: C5 elimination placed ξ ∈ g(x,y) at finite stage
    -- Step 7: g-value propagates to limit (Task 5a.1): ξ ∈ limit_g(x,y)
    -- Step 8: By limit_c3_interval_subset_point (already sorry-free): ∀ z, x < z < y → ξ ∈ limit_f(z)
  ```

- [ ] **Task 5a.3**: Mirror for Since direction: `limit_satisfies_c5'_full`

- [ ] **Task 5a.4**: Run `lake build` — verify both compile sorry-free

**Timing**: 8-10 hours

**Depends on**: Phase 4e (c2' available from omega_chain, g-values assigned at finite stages)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean`

**Verification**:
- `limit_satisfies_c5_full` proved sorry-free
- `limit_satisfies_c5'_full` proved sorry-free (mirror)
- `lake build` succeeds

---

### Phase 5b: Close FUC/FSC Sorries [NOT STARTED]

**Goal**: Close the 2 sorries in ChronicleToCountermodel.lean (lines 615, 619) for forward Until and Since coherence via Burgess Claim 2.11.

**Tasks**:
- [ ] **Task 5b.1**: Inspect FUC sorry at line 615 with `lean_goal` for exact proof obligation

- [ ] **Task 5b.2**: Connect `limit_satisfies_c5_full` to Cantor-based BFMCS structure
  - Map limit C5 witness through Cantor isomorphism:
  ```lean
  theorem cantor_bfmcs_restricted_fuc (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
      (root : Formula) :
      (cantor_bfmcs M₀ h₀).restricted_forward_until_since_coherent root := by
    intro fam hfam
    constructor
    · -- Forward Until: U(φ,ψ) ∈ mcs(t) → ∃ s > t, ψ ∈ mcs(s) ∧ guard
      intro t φ ψ _h_sub h_until
      obtain ⟨N, h_N, s, h_eqN, rfl⟩ := hfam
      set offset := s - cantor_zero N h_N
      have h_until' : Formula.untl φ ψ ∈ limit_f N h_N offset := ...
      -- Apply limit_satisfies_c5_full (from Phase 5a)
      obtain ⟨y, hy_dom, hy_lt, hy_ψ, h_guard⟩ := 
        limit_satisfies_c5_full N h_N offset (by ...) φ ψ h_until'
      -- Transfer witness back to rational coordinates
      set y_rat := (cantor_iso N h_N) ⟨y, hy_dom⟩ + offset
      have hy_rat_lt : t < y_rat := by ...
      have hy_ψ_rat : ψ ∈ (rooted_cantor_fmcs N h_N s).mcs y_rat := by ...
      have h_guard_rat : ∀ r : Rat, t < r → r < y_rat → 
        φ ∈ (rooted_cantor_fmcs N h_N s).mcs r := by ...
      exact ⟨y_rat, hy_rat_lt, hy_ψ_rat, h_guard_rat⟩
    · -- Forward Since: mirror using limit_satisfies_c5'_full
      ...
  ```

- [ ] **Task 5b.3**: Close FUC sorry (line 615)

- [ ] **Task 5b.4**: Inspect FSC sorry at line 619 with `lean_goal`

- [ ] **Task 5b.5**: Close FSC sorry (line 619) using mirror with `limit_satisfies_c5'_full`

- [ ] **Task 5b.6**: Run `lake build` — verify ChronicleToCountermodel.lean compiles sorry-free

**Timing**: 4-6 hours

**Depends on**: Phase 5a (`limit_satisfies_c5_full` available)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean`

**Verification**:
- ChronicleToCountermodel.lean sorry count: 0
- `cantor_bfmcs_restricted_fuc` compiles sorry-free
- `lake build` succeeds

---

### Phase 5c: Final Audit and Verification [NOT STARTED]

**Goal**: Perform comprehensive audit to ensure all sorries are closed and no regressions exist.

**Tasks**:
- [ ] **Task 5c.1**: Run `#print axioms dd_countermodel_chronicle` — verify no `sorryAx` appears

- [ ] **Task 5c.2**: Run `grep -rn "sorry" Theories/Bimodal/Metalogic/BXCanonical/Chronicle/` — verify only comments contain "sorry"

- [ ] **Task 5c.3**: Verify all previously sorry-free lemmas remain sorry-free (no regressions):
  - `lemma_2_6_splitting`, `lemma_2_6`, `lemma_2_4`, `lemma_2_5b`
  - All Phase 1 helper lemmas

- [ ] **Task 5c.4**: Run full `lake build` — clean build with no errors

- [ ] **Task 5c.5**: Update module docstrings in Chronicle/ files to reflect final proof structure

- [ ] **Task 5c.6**: Create summary artifact at `specs/107_chain_design_diagnostics_for_representation_theorem/summaries/54_implementation-summary.md`

**Timing**: 1-2 hours

**Depends on**: Phase 5a, 5b (all proofs complete)

**Verification**:
- `#print axioms dd_countermodel_chronicle` shows no `sorryAx`
- `grep -rn "sorry" Theories/Bimodal/Metalogic/BXCanonical/Chronicle/` returns only comments
- Full `lake build` clean
- All previously sorry-free lemmas remain sorry-free
- Summary artifact created

---

## Testing & Validation

- [ ] **Phase 2**: PointInsertion.lean Phase 2 sorry count: 0; `lake build` succeeds
- [ ] **Phase 3**: `lemma_2_7_seed_consistent` compiles sorry-free; PointInsertion.lean total sorry count: 0
- [ ] **Phase 4a**: `EliminationResult` carries c2' field; all constructions type-check
- [ ] **Phase 4b**: C5/C5' c2' sorries closed (lines 756, 768, 794, 806)
- [ ] **Phase 4c**: C4/C4' c2' sorries closed (lines 834, 845, 872, 883)
- [ ] **Phase 4d**: Density c2' sorries closed (lines 918, 931)
- [ ] **C11/C12**: C4 hard-case sorries closed (lines ~412, ~510)
- [ ] **Phase 4e**: `omega_chain_c2'` accessor compiles; `lake build` succeeds
- [ ] **Phase 5a**: `limit_satisfies_c5_full` proved sorry-free; g-value propagation verified
- [ ] **Phase 5b**: ChronicleToCountermodel.lean sorry count: 0; FUC/FSC sorries closed
- [ ] **Phase 5c**: `#print axioms dd_countermodel_chronicle` shows no `sorryAx`; full audit passes

## Artifacts & Outputs

- `plans/54_implementation-plan.md` (this file)
- Modified `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` (close 4 sorries)
- Modified `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` (add c2' field, close 16 sorries)
- Modified `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` (thread c2', prove `limit_satisfies_c5_full`)
- Modified `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` (close 2 FUC/FSC sorries)
- Sorry-free `dd_countermodel_chronicle`
- Summary artifact: `summaries/54_implementation-summary.md`

## Rollback/Contingency

- **Phase 2 (D0 inconsistent case)**: Each sorry independently closeable. If one blocks, commit others and document blocker. Inconsistent case is fully independent from consistent case.

- **Phase 3 (BX7 chain)**: If BX7 three-way disjunction elimination too complex, implement 4-component version first without 5th seed component (`snce(β'∧eta, α)`). Fallback: use two-step BX7 derivation.

- **Phase 4a-4d (c2' threading)**: Refactor is additive. If threading c2' through all elimination branches is prohibitive, thread only through C5/C5' and C4/C4' branches, use trivial c2' for density and no-elimination cases.

- **Phase 4e (omega_chain c2')**: If modifying omega_chain return type too invasive, add c2' as separate theorem proved by induction without changing main definition.

- **C11/C12 (C4 hard cases)**: If nested case needed and complex, start with simpler non-nested version. Escalate to induction + BX6 only if required.

- **Phase 5a (limit_satisfies_c5_full)**: If g-value propagation from finite stages to limit is blocked, use direct argument via `limit_g` definition (intersection of intermediate f-values) to bypass finite-stage tracking.

- **Phase 5b (FUC/FSC)**: If Cantor isomorphism mapping problematic, work directly with limit structure without Cantor embedding.

- **General**: Git history preserves all prior states; each phase is independently committable.

---

## AGENT INSTRUCTIONS: Proof Architecture Reference

### The Lemma 2.7 BX7 Chain (Phase 3)

Follow Burgess 1982 p. 372 exactly:

1. **Extract witness**: `lemma_2_7_neg_untl_exists` → β₀ ∈ B, γ₀ ∈ C, `¬untl(β₀∧eta, γ₀) ∈ A`

2. **BX5 self-accumulation**: `untl(b ∧ untl(b, γ_hat), γ_hat) ∈ A` and `untl(xi ∧ untl(xi, eta), eta) ∈ A`

3. **BX7 three-way disjunction** (`linear_until_mcs`):
   - D1: `untl(b∧xi, γ_hat∧eta)` 
   - D2: `untl(b∧xi, γ_hat∧xi)`
   - D3: `untl(b∧xi, b∧eta)` (surviving disjunct)
   
4. **Eliminate D1/D2**: `¬untl(β₀∧eta, γ₀) ∈ A` + left/right monotonicity → contradiction via `burgessR3Maximal` properties

5. **Surviving D3**: Contains eta in right-hand side → enables 5th seed component via BX13/BX10 chain

### c2' Threading (Phase 4)

**g-Value Construction by Elimination Type**:

| Elimination | f(new) | g(left, new) | g(new, right) | c2' Source |
|-------------|--------|--------------|---------------|------------|
| C5_forward | C (lemma_2_4) | B (lemma_2_4) | extend via C3 | Lemma 2.4 |
| C5_backward | C' (mirror) | B' (mirror) | extend via C3 | Lemma 2.4' |
| C4_forward | D (lemma_2_6) | B' (lemma_2_6) | B'' (lemma_2_6) | Lemma 2.6 |
| C4_backward | D' (mirror) | B' (mirror) | B'' (mirror) | Lemma 2.6' |
| Density | D | B' (exists via Zorn) | B'' (exists via Zorn) | burgessR3Maximal_from_g_content_sub |

### FUC/FSC (Phase 5)

**Forward Until Coherence** (Burgess Claim 2.11):
```
U(φ,ψ) ∈ mcs(t) at Cantor point t
  → U(φ,ψ) ∈ limit_f(x) at limit coordinate x
  → limit_satisfies_c5_full gives y with ψ ∈ limit_f(y) and ∀z∈(x,y): φ ∈ limit_f(z)
  → Cantor isomorphism maps y back to rational t' > t
  → ψ ∈ mcs(t') and ∀r∈(t,t'): φ ∈ mcs(r)
```

**Key Lemma Chain**:
```
C5 elimination at stage n places φ ∈ g_n(x, y)
  → c2' (maximality) ensures g-values persist
  → omega_chain_c2' threads to all later stages
  → limit_g(x, y) inherits φ
  → limit_c3_interval_subset_point: φ ∈ limit_f(z) for all intermediate z
```

---

## Reference: Burgess 1982 Key Sections

All agents reference the Burgess paper at:
`literature/Burgess_1982_Axioms_for_tense_logic_Since_and_Until.md`

| Section | Content |
|---------|---------|
| 2.6, p. 370 | Lemma 2.6 — D0 seed consistency |
| 2.7, p. 372 | Lemma 2.7 — BX7 chain, 5-component seed |
| 2.9, p. 374 | Lemma 2.9 — C4 counterexample elimination |
| 2.10, pp. 374-375 | Lemma 2.10 — C5 counterexample elimination |
| 2.11, pp. 373-374 | Claim 2.11 — Truth lemma, FUC/FSC coherence |

## Key Formula Constructor Properties

**Formula injectivity**: `Formula.untl.injEq` and `Formula.snce.injEq` are critical for `Classical.choose` determinism in D0 seed construction. These derive from `DecidableEq` or constructor injectivity.

## Critical Mathematical Notes

1. **BX7 ≠ A7a**: Burgess's original A7a removed as unsound under open guard semantics. Our BX7 (`linear_until`) has different disjuncts valid under open guard.

2. **g-Value Propagation**: The key insight for Phase 5 is that C5 at finite stages carries full guard information, and g-values persist through omega-chain via c2' maximality.

3. **limit_c3_interval_subset_point** (ChronicleConstruction.lean:877): Already proved sorry-free. This is the bridge from `limit_g(x,y)` to `limit_f(z)` for intermediate z.

4. **limit_c3** (ChronicleConstruction.lean:852): Already proved sorry-free. This gives the C3 decomposition of limit_g at intermediate points.

---

**Plan created**: 2026-05-03
**Estimated Total Effort**: 37-50 hours
**Complexity**: Complex
**Critical Path**: Phase 3 (6-8h) → Phase 4a (1-2h) → Phase 4c (3-4h) → Phase 4e (2-3h) → Phase 5a (8-10h) → Phase 5b (4-6h) = ~24-33h
