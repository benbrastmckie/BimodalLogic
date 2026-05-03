# Implementation Plan: Task #107 -- Burgess Chronicle Construction for BX Representation Theorem

- **Task**: 107 - Chain design diagnostics for representation theorem
- **Status**: [NOT STARTED]
- **Effort**: 37-47 hours
- **Dependencies**: Task 113 [COMPLETED] (open-guard semantics)
- **Research Inputs**: `reports/53_team-research.md` (master synthesis), `reports/53_teammate-a-phase2-inconsistent.md`, `reports/53_teammate-b-phase3-lemma27.md`, `reports/53_teammate-c-phase4-c2-threading.md`, `reports/53_teammate-d-phase5-fuc-fsc.md`
- **Artifacts**: plans/53_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true
- **Plan Version**: 53
- **Complexity**: complex

## Overview

This plan provides a comprehensive, no-compromises approach to achieving a sorry-free `dd_countermodel_chronicle` for the BX completeness representation theorem. The plan implements the full Burgess 1982 chronicle construction (Sections 2.6-2.11), systematically closing all 16 remaining sorry sites across four files.

**Definition of Done**: `#print axioms dd_countermodel_chronicle` shows no `sorryAx`; `lake build` succeeds; `grep -rn "sorry" Theories/Bimodal/Metalogic/BXCanonical/Chronicle/` returns only comments.

### Research Integration

The master synthesis from four parallel research teammates (53_team-research.md) confirmed:
- **Phase 2** (inconsistent case): 3 sorries at PointInsertion.lean lines 1411, 1858-1859 require restructuring L-membership proofs
- **Phase 3** (Lemma 2.7): 1 sorry at line 2400 requires implementing BX7 MCS wrapper (`linear_until_mcs`) and 10-step chain per Burgess p.372
- **Phase 4** (c2' threading): 10 sorries at CounterexampleElimination.lean lines 756-931 require making g a first-class object with BurgessR3Maximal at adjacent pairs
- **Phase 5** (FUC/FSC): 2 sorries at ChronicleToCountermodel.lean lines 615, 619 require `limit_satisfies_c5_full` with complete guard propagation

### Mathematical Foundation

All proofs follow Burgess 1982 "Axioms for Tense Logic: Since and Until" (Notre Dame Journal, Vol. 23, No. 4, pp. 367-374):
- **Section 2.6** (p. 170): Lemma 2.6 - D0 seed consistency for point insertion
- **Section 2.7** (p. 372): Lemma 2.7 - BX7 chain for 5-component seed
- **Section 2.9** (p. 374): Lemma 2.9 - C4 counterexample elimination  
- **Section 2.10** (p. 374-375): Lemma 2.10 - C5 counterexample elimination
- **Section 2.11** (p. 373-374): Claim 2.11 - Truth lemma establishing FUC/FSC coherence

### Critical Mathematical Notes

1. **BX7 ≠ A7a**: Burgess's A7a was removed as unsound under open guard semantics. Our BX7 (`linear_until`) has different disjuncts valid under open guard.

2. **Formula Constructor Injectivity**: `Formula.untl.injEq` and `Formula.snce.injEq` are critical for `Classical.choose` determinism in D0 seed construction.

3. **g-Value Propagation**: The key insight for Phase 5 is that C5 at finite stages carries full guard information, and g-values persist through omega-chain via c2' maximality (C3).

## Goals & Non-Goals

**Goals**:
- Close all 3 sorries in Phase 2 (PointInsertion.lean: lines 1411, 1858-1859)
- Close the 1 sorry in Phase 3 (PointInsertion.lean: line 2400 - `lemma_2_7_seed_consistent`)
- Implement `linear_until_mcs` (BX7 MCS wrapper) and complete 10-step BX7 chain
- Close all 10 sorries in Phase 4 (CounterexampleElimination.lean: lines 756-931)
- Thread c2' (BurgessR3Maximal at adjacent pairs) through omega_chain
- Close both sorries in Phase 5 (ChronicleToCountermodel.lean: lines 615, 619)
- Prove `limit_satisfies_c5_full` with complete guard propagation
- Achieve sorry-free `dd_countermodel_chronicle`
- Maintain `lake build` at each phase boundary

**Non-Goals**:
- Generalizing beyond D=Rat to arbitrary ordered groups
- Optimizing proof term sizes or compilation speed
- Refactoring Chronicle type hierarchy beyond c2' addition
- Addressing sorry sites outside the Chronicle/ directory
- Implementing Lemma 2.8 (depends on D2-style reasoning, not needed for completeness)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `linear_until_mcs` implementation proves complex | Critical | Low | BX7 axiom already exists in Axioms.lean (line 230); MCS wrapper is straightforward derivation |
| D2 elimination in Lemma 2.7 fails | High | Medium | Follow Burgess p.372 literally; use `neg(untl(beta0 AND eta, gamma0))` with monotonicity |
| Lemma 2.6 splitting (Phase 2) blocks Phase 4 | Critical | Low | Phase 2 must complete first; if blocked, use alternative approach with weaker invariant |
| c2' threading breaks existing proofs | High | Low | Refactor is additive (new fields), not destructive; maintain backward compatibility |
| g-value persistence in Phase 5 fails | High | Medium | Fallback: prove `limit_satisfies_c5_full` directly from omega_chain construction |
| Formula injectivity missing | Medium | Low | Derive `Formula.untl.injEq` and `Formula.snce.injEq` from `DecidableEq` or constructor injectivity |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 2 (inconsistent case) | -- |
| 2 | 3 (Lemma 2.7 BX7 chain) | 2 |
| 3 | 4a (c2' infrastructure), 4b (C5/C5' g-values) | 2, 3 |
| 4 | 4c (C4/C4' hard cases), 4d (density g-values) | 4a, 4b |
| 5 | 4e (omega_chain c2' threading) | 4c, 4d |
| 6 | 5a (limit_satisfies_c5_full) | 4e |
| 7 | 5b (FUC/FSC closure), 5c (final audit) | 5a |

Phases within the same wave can execute in parallel where marked as independent.

---

### Phase 2: Complete D0 Seed Consistency (Inconsistent Case) [PARTIAL]

**Goal**: Close the 3 remaining sorries in `burgess_D0_finite_subset_consistent_incons` (lines 1411, 1858-1859) by restructuring L-membership proofs to avoid direct dependence on `h_ev_b` and `h_ev_untl`.

**Tasks**:
- [ ] **Task 2.1**: Complete `d0_a_event_list_mem` (line 1411) - Use pattern matching instead of `Classical.choose` to extract α' from `snce(beta', alpha') ∈ L`. Prove `α' ∈ A` directly via `d0_a_event_list_α_mem` helper.

- [ ] **Task 2.2**: Restructure `h_ev_b` derivation (line 1858) - The enrichment provides `event → γ_hat`, but proof requires `event → b`. Strategy: Use `collect_guards_mem_of_B` to show `b ∈ collect_guards output`, then `list_conj_implies_elem` gives `b_list → b`, and by transitivity with `event → b_list` (via BX13 enrichment), we get `event → b`.

- [ ] **Task 2.3**: Restructure `h_ev_untl` derivation (line 1859) - Need `event → untl(b, γ_hat)`. Strategy: From BX5 (`self_accum_until_mcs`), we have `untl(b AND untl(b, γ_hat), γ_hat) ∈ A`. The event contains `b AND untl(b, γ_hat)` in its guard (via BX13 enrichment), so `event → untl(b AND untl(b, γ_hat), γ_hat)`. Apply `untl_left_mono_deriv` with `b → b` (refl) and `untl(b, γ_hat) → untl(b, γ_hat)` (from guard), then use `untl_right_mono_deriv` with `γ_hat → γ_hat` (refl).

- [ ] **Task 2.4**: Verify complete proof - Ensure `burgess_D0_finite_subset_consistent_incons` compiles sorry-free with all cases (β.neg ∈ B) working correctly.

- [ ] **Task 2.5**: Run `lake build` - Verify no regressions in existing sorry-free lemmas (`lemma_2_6_splitting`, `lemma_2_6`, etc.).

**Timing**: 4-6 hours

**Depends on**: Phase 1 (helper lemmas, already COMPLETED)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` -- complete `d0_a_event_list_mem` (~30 lines), restructure `h_ev_b` and `h_ev_untl` derivations (~80 lines)

**Verification**:
- `burgess_D0_finite_subset_consistent_incons` compiles sorry-free
- `burgess_D0_seed_consistent` remains sorry-free
- PointInsertion.lean sorry count: 1 (Phase 3: `lemma_2_7_seed_consistent`)
- `lake build` succeeds

---

### Phase 3: Implement Lemma 2.7 with BX7 Chain [PARTIAL]

**Goal**: Close the sorry in `lemma_2_7_seed_consistent` (line 2400) using the full Burgess Lemma 2.7 proof with BX7 (linear_until) for the 5th seed component.

**Tasks**:
- [ ] **Task 3.1**: Implement `lemma_2_7_neg_untl_exists` (~40 lines) - Extract β₀ ∈ B, γ₀ ∈ C with `¬untl(β₀ ∧ eta, γ₀) ∈ A` from `h_eta_not_B` and `BurgessR3Maximal_extension_fails`. Proof: By maximality of B with respect to r(A, -, C), since eta ∉ B, there exists β ∈ B such that r(A, β ∧ eta, C) fails. By criterion 2.3(a), there exists γ ∈ C with `¬U(γ, β ∧ eta) ∈ A`. Take β₀ = β, γ₀ = γ.

- [ ] **Task 3.2**: Implement `linear_until_mcs` (BX7 MCS wrapper, ~15 lines) - Given `untl(φ₁, ψ₁) ∈ A` and `untl(φ₂, ψ₂) ∈ A` with `SetMaximalConsistent A`, prove:
  ```lean
  theorem linear_until_mcs {A : Set Formula} (h_mcs : SetMaximalConsistent A)
      {φ₁ ψ₁ φ₂ ψ₂ : Formula}
      (h_u1 : Formula.untl φ₁ ψ₁ ∈ A) (h_u2 : Formula.untl φ₂ ψ₂ ∈ A) :
      Formula.or (Formula.or
        (Formula.untl (Formula.and φ₁ φ₂) (Formula.and ψ₁ ψ₂))
        (Formula.untl (Formula.and φ₁ φ₂) (Formula.and ψ₁ φ₂)))
        (Formula.untl (Formula.and φ₁ φ₂) (Formula.and φ₁ ψ₂)) ∈ A := by
    have h_ax := DerivationTree.axiom [] _ (Axiom.linear_until φ₁ ψ₁ φ₂ ψ₂)
    have h_and := DerivationTree.and_intro _ _ _ (DerivationTree.assumption _ _ _) (DerivationTree.assumption _ _ _)
    exact DerivationTree.modus_ponens _ _ _ h_and h_ax
  ```

- [ ] **Task 3.3**: Implement `lemma_2_7_disjunct_elim_D1` (~25 lines) - Show D1 (`untl(ξ∧γ, θ)` where θ contains eta) contradicts `¬untl(β₀∧eta, γ₀) ∈ A` via left/right monotonicity.

- [ ] **Task 3.4**: Implement `lemma_2_7_disjunct_elim_D2` (~25 lines) - Show D2 (`untl(ξ∧γ, ψ∧γ)`) contradicts `¬untl(β₀∧eta, γ₀) ∈ A` similarly.

- [ ] **Task 3.5**: Implement main BX7 chain in `lemma_2_7_seed_consistent` (~80 lines):
  1. Extract neg-until witness: `lemma_2_7_neg_untl_exists` → β₀ ∈ B, γ₀ ∈ C, `¬untl(β₀∧eta, γ₀) ∈ A`
  2. BX5 on `untl(b, γ_hat)`: `untl(b ∧ untl(b, γ_hat), γ_hat) ∈ A` via `self_accum_until_mcs`
  3. BX5 on `untl(xi, eta)`: `untl(xi ∧ untl(xi, eta), eta) ∈ A` via `self_accum_until_mcs`
  4. BX7 three-way disjunction: `linear_until_mcs` on steps 2-3 → D1 ∨ D2 ∨ D3 ∈ A
  5. Eliminate D1: `lemma_2_7_disjunct_elim_D1` → contradiction
  6. Eliminate D2: `lemma_2_7_disjunct_elim_D2` → contradiction
  7. Surviving D3: `untl(b ∧ untl(b, γ_hat) ∧ xi, θ) ∈ A` where θ = `b ∧ untl(b, γ_hat) ∧ xi ∧ eta`
  8. BX14 separation (if needed): Separate neg(beta₀ ∧ eta) from the guard
  9. BX13 iterated enrichment: Pack `snce(guard, alpha_j)` for each alpha_j ∈ a_list
  10. BX10 F-extraction: `F(event) ∈ A` → event is consistent
  11. Event implies all 5 seed components (component 5 uses guard containing eta from BX7)

- [ ] **Task 3.6**: Verify `lemma_2_7` theorem compiles sorry-free (depends on `lemma_2_7_seed_consistent`).

- [ ] **Task 3.7**: Run `lake build` - Verify Phase 3 complete, PointInsertion.lean sorry count = 0.

**Timing**: 5-7 hours

**Depends on**: Phase 2 (same helper infrastructure, D0 seed consistency proof pattern)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` -- add `lemma_2_7_neg_untl_exists` (~40 lines), `linear_until_mcs` (~15 lines), `lemma_2_7_disjunct_elim_D1/D2` (~50 lines), complete `lemma_2_7_seed_consistent` (~80 lines)

**Verification**:
- `lemma_2_7_seed_consistent` compiles sorry-free
- `lemma_2_7` compiles sorry-free
- PointInsertion.lean sorry count: 0
- `lake build` succeeds

---

### Phase 4a: Refactor EliminationResult to Carry c2' [NOT STARTED]

**Goal**: Add c2' field to EliminationResult structure to track BurgessR3Maximal at adjacent pairs, enabling proper g-value assignment during counterexample elimination.

**Tasks**:
- [ ] **Task 4a.1**: Add `c2'` field to `EliminationResult` structure:
  ```lean
  (c2' : ∀ x y : Rat, Adjacent χ.dom x y → 
         BurgessR3Maximal (χ.f x) (χ.g x y) (χ.f y))
  ```
  Location: `ChronicleTypes.lean` or `CounterexampleElimination.lean` (where EliminationResult is defined).

- [ ] **Task 4a.2**: Add `h_c2'` hypothesis to `eliminate_potential_counterexample` signature alongside existing `h_c0`.

- [ ] **Task 4a.3**: Update all call sites that construct EliminationResult to provide c2' proof. This includes:
  - `eliminate_C5_counterexample` 
  - `eliminate_C5'_counterexample`
  - `eliminate_C4_counterexample`
  - `eliminate_C4'_counterexample`
  - Density elimination case

- [ ] **Task 4a.4**: Run `lake build` to identify all type errors from signature changes.

**Timing**: 2-3 hours

**Depends on**: Phase 2, 3 (lemma_2_6_splitting and lemma_2_7 must be sorry-free)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleTypes.lean` or `CounterexampleElimination.lean` -- add c2' field to EliminationResult
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` -- update all EliminationResult constructions

**Verification**:
- All EliminationResult constructions type-check with c2' field
- `lake build` succeeds (may have remaining sorries at c2' proof sites)

---

### Phase 4b: Modify C5/C5' Elimination to Assign g-Values [NOT STARTED]

**Goal**: Use lemma_2_4 output (B from BurgessR3Maximal) to assign proper g-values when eliminating C5/C5' counterexamples.

**Tasks**:
- [ ] **Task 4b.1**: In `eliminate_C5_counterexample`: Capture B from `lemma_2_4` output (currently discarded). Construct g' that assigns B to the new adjacent pair (x, y). Prove c2' for the new chronicle: old pairs have unchanged g (from h_c2'), new pair has BurgessR3Maximal from lemma_2_4 construction.

- [ ] **Task 4b.2**: Mirror for `eliminate_C5'_counterexample` (Since direction).

- [ ] **Task 4b.3**: Close C5 forward sorry (line 756) - Use lemma_2_4 output B as g(x, y) for the new adjacent pair created by C5 elimination.

- [ ] **Task 4b.4**: Close C5 backward sorry (line 794) - Mirror of Task 4b.3 for Since direction.

- [ ] **Task 4b.5**: Close "no elimination" sorries (lines 768, 806) - c2' preserved trivially when no elimination occurs (chronicle unchanged).

**Timing**: 2-3 hours

**Depends on**: Phase 4a (c2' field exists in EliminationResult)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` -- modify C5/C5' elimination functions, close 4 sorries

**Verification**:
- C5/C5' elimination functions compile with proper g-value assignment
- Sorries at lines 756, 768, 794, 806 closed
- `lake build` succeeds

---

### Phase 4c: Modify C4/C4' Elimination to Assign g-Values [NOT STARTED]

**Goal**: Close the hard C4/C4' sorries (lines 834, 872) by using lemma_2_6_splitting to split g(x,y) into B', D, B'' with proper g-value assignment.

**Tasks**:
- [ ] **Task 4c.1**: In `eliminate_C4_counterexample` hard case (line 834): Call `lemma_2_6_splitting` to get B', D, B''. Assign g'(w, z) = B' and g'(z, w_next) = B''. The splitting point D has neg-gamma in D. Prove c2': old pairs unchanged, new pairs (w,z) and (z,w_next) have BurgessR3Maximal from `lemma_2_6_splitting` output.

- [ ] **Task 4c.2**: Mirror for `eliminate_C4'_counterexample` hard case (line 872) using Since-direction splitting.

- [ ] **Task 4c.3**: Close C4 forward sorry (line 834) - Use lemma_2_6 output to construct g' with proper splitting.

- [ ] **Task 4c.4**: Close C4 backward sorry (line 872) - Mirror of Task 4c.3.

- [ ] **Task 4c.5**: Close "no elimination" sorries (lines 845, 883) - c2' preserved trivially.

**Timing**: 2-3 hours

**Depends on**: Phase 2 (lemma_2_6_splitting sorry-free), Phase 4a (c2' field)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` -- modify C4/C4' elimination functions, close 4 sorries

**Verification**:
- C4/C4' elimination functions compile with proper g-value assignment
- Sorries at lines 834, 845, 872, 883 closed
- `lake build` succeeds

---

### Phase 4d: Modify Density Elimination to Assign g-Values [NOT STARTED]

**Goal**: When inserting midpoint z between x and y, split g(x,y) into g'(x,z) and g'(z,y) using BurgessR3Maximal from lemma_2_6_splitting.

**Tasks**:
- [ ] **Task 4d.1**: In density elimination case: When inserting midpoint z between x and y, split g(x,y) into g'(x,z) and g'(z,y) using `lemma_2_6_splitting` with arbitrary δ (since we're just breaking adjacency, not eliminating a specific counterexample).

- [ ] **Task 4d.2**: Close density sorries (lines 918, 931) - Prove c2' for new adjacent pairs (x,z) and (z,y).

- [ ] **Task 4d.3**: Run `lake build` - Verify all 10 c2' sorries in Phase 4 are closed.

**Timing**: 1-2 hours

**Depends on**: Phase 4a (c2' field), Phase 2 (lemma_2_6_splitting)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` -- modify density elimination, close 2 sorries

**Verification**:
- All 10 c2' sorries closed (lines 756, 768, 794, 806, 834, 845, 872, 883, 918, 931)
- CounterexampleElimination.lean sorry count: 0
- `lake build` succeeds

---

### Phase 4e: Thread c2' Through omega_chain [NOT STARTED]

**Goal**: Change omega_chain return type to carry both c0 and c2' as joint invariant, ensuring g-values persist through the limit construction.

**Tasks**:
- [ ] **Task 4e.1**: Change `omega_chain` return type to include both c0 and c2' accessors. Update the type signature to return a structure with `omega_chain_c0` and `omega_chain_c2'` fields.

- [ ] **Task 4e.2**: Update base case: singleton chronicle satisfies c2' vacuously (no adjacent pairs).

- [ ] **Task 4e.3**: Update step case: Use c2' field from EliminationResult (obtained from Phases 4b-4d).

- [ ] **Task 4e.4**: Add `omega_chain_c2'` accessor alongside existing `omega_chain_c0`.

- [ ] **Task 4e.5**: Run `lake build` - Verify omega_chain correctly threads c2' through all elimination steps.

**Timing**: 2-3 hours

**Depends on**: Phase 4a-4d (all elimination functions provide c2' proofs)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` -- thread c2' through omega_chain (~80 lines)

**Verification**:
- omega_chain carries c0 + c2' joint invariant
- All elimination steps preserve c2'
- `lake build` succeeds

---

### Phase 5a: Prove limit_satisfies_c5_full [NOT STARTED]

**Goal**: Strengthen C5 from weak (endpoint only) to full (endpoint plus guard at all intermediate points), enabling the truth lemma for Until formulas.

**Tasks**:
- [ ] **Task 5a.1**: Prove g-value propagation lemma (~4-6 hours, ~100 lines): At finite stage n, if C5 elimination at step k placed ξ in g_k(x,y), then ξ in g_n(x,y) for all subsequent stages where (x,y) remains adjacent. Uses: c2' maximality ensures g-values persist; C3 ensures g(x,y) ⊆ f(z) for intermediate z.

- [ ] **Task 5a.2**: Prove `limit_satisfies_c5_full` (~4-6 hours, ~120 lines):
  ```lean
  theorem limit_satisfies_c5_full (A : Set Formula) (h_mcs : SetMaximalConsistent A)
      (x : Rat) (hx : x ∈ limit_dom A h_mcs) (ξ η : Formula)
      (h_until : Formula.untl ξ η ∈ limit_f A h_mcs x) :
      ∃ y ∈ limit_dom A h_mcs, x < y ∧ η ∈ limit_f A h_mcs y ∧
        ∀ z ∈ limit_dom A h_mcs, x < z → z < y → ξ ∈ limit_f A h_mcs z := by
    -- From h_until, extract witness at finite stage
    -- C5 elimination gives ξ in g(x,y) at finite stage
    -- g-value propagates to limit (Task 5a.1)
    -- limit_g(x,y) inherits; C3 gives limit_g(x,y) ⊆ limit_f(z) for intermediate z
  ```

- [ ] **Task 5a.3**: Mirror for Since direction: `limit_satisfies_c5'_full`.

- [ ] **Task 5a.4**: Run `lake build` - Verify `limit_satisfies_c5_full` compiles sorry-free.

**Timing**: 8-12 hours

**Depends on**: Phase 4e (c2' available from omega_chain, g-values assigned at finite stages)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` -- prove g-value propagation and `limit_satisfies_c5_full` (~220 lines)

**Verification**:
- `limit_satisfies_c5_full` proved sorry-free
- `limit_satisfies_c5'_full` proved sorry-free (mirror)
- `lake build` succeeds

---

### Phase 5b: Close FUC/FSC Sorries [NOT STARTED]

**Goal**: Close the 2 sorries in ChronicleToCountermodel.lean (lines 615, 619) for forward Until and Since coherence via Burgess Claim 2.11.

**Tasks**:
- [ ] **Task 5b.1**: Inspect FUC sorry at line 615 with `lean_goal` to understand exact proof obligation.

- [ ] **Task 5b.2**: Connect `limit_satisfies_c5_full` to the Cantor-based BFMCS structure. Map the limit C5 witness through the Cantor isomorphism:
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
      have h_until' : Formula.untl φ ψ ∈ limit_f N h_N _
      -- Apply limit_satisfies_c5_full (from Phase 5a)
      obtain ⟨y, hy_dom, hy_lt, hy_ψ, h_guard⟩ := 
        limit_satisfies_c5_full N h_N _ _ h_until'
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

- [ ] **Task 5b.3**: Close FUC sorry (line 615) using the proof structure above.

- [ ] **Task 5b.4**: Inspect FSC sorry at line 619 with `lean_goal`.

- [ ] **Task 5b.5**: Close FSC sorry (line 619) using mirror of FUC proof with `limit_satisfies_c5'_full`.

- [ ] **Task 5b.6**: Run `lake build` - Verify ChronicleToCountermodel.lean compiles sorry-free.

**Timing**: 4-6 hours

**Depends on**: Phase 5a (limit_satisfies_c5_full available)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- close 2 sorries (~160 lines)

**Verification**:
- ChronicleToCountermodel.lean sorry count: 0
- `cantor_bfmcs_restricted_fuc` compiles sorry-free
- `lake build` succeeds

---

### Phase 5c: Final Audit and Verification [NOT STARTED]

**Goal**: Perform comprehensive audit to ensure all sorries are closed and no regressions exist.

**Tasks**:
- [ ] **Task 5c.1**: Run `#print axioms dd_countermodel_chronicle` - Verify no `sorryAx` appears.

- [ ] **Task 5c.2**: Run `grep -rn "sorry" Theories/Bimodal/Metalogic/BXCanonical/Chronicle/` - Verify only comments/docstrings contain "sorry".

- [ ] **Task 5c.3**: Verify all previously sorry-free lemmas remain sorry-free (no regressions):
  - `lemma_2_6_splitting`
  - `lemma_2_6`
  - `lemma_2_4`
  - `lemma_2_5b`
  - All helper lemmas from Phase 1

- [ ] **Task 5c.4**: Run full `lake build` - Clean build with no errors.

- [ ] **Task 5c.5**: Update module docstrings in Chronicle/ files to reflect final proof structure (reference Burgess 1982 sections).

- [ ] **Task 5c.6**: Create summary artifact at `specs/107_chain_design_diagnostics_for_representation_theorem/summaries/53_implementation-summary.md`.

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

- [ ] **Phase 2**: `burgess_D0_finite_subset_consistent_incons` compiles sorry-free; PointInsertion.lean sorry count = 1
- [ ] **Phase 3**: `lemma_2_7_seed_consistent` compiles sorry-free; PointInsertion.lean sorry count = 0; `lake build` succeeds
- [ ] **Phase 4a**: EliminationResult carries c2' field; all constructions type-check
- [ ] **Phase 4b**: C5/C5' elimination assigns proper g-values; sorries at 756, 768, 794, 806 closed
- [ ] **Phase 4c**: C4/C4' elimination assigns proper g-values; sorries at 834, 845, 872, 883 closed
- [ ] **Phase 4d**: Density elimination assigns g-values; sorries at 918, 931 closed
- [ ] **Phase 4e**: omega_chain carries c0 + c2' joint invariant; `lake build` succeeds
- [ ] **Phase 5a**: `limit_satisfies_c5_full` proved sorry-free; g-value propagation verified
- [ ] **Phase 5b**: ChronicleToCountermodel.lean sorry count = 0; FUC/FSC sorries closed
- [ ] **Phase 5c**: `#print axioms dd_countermodel_chronicle` shows no `sorryAx`; full audit passes

## Artifacts & Outputs

- `plans/53_implementation-plan.md` (this file)
- Modified `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` (close 4 sorries, add BX7 helpers)
- Modified `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` (add c2' field, close 10 sorries)
- Modified `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` (thread c2', prove `limit_satisfies_c5_full`)
- Modified `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` (close 2 FUC/FSC sorries)
- Modified `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleTypes.lean` (add c2' to EliminationResult if defined there)
- Sorry-free `dd_countermodel_chronicle`
- Summary artifact: `summaries/53_implementation-summary.md`

## Rollback/Contingency

- **Phase 2 (D0 inconsistent case)**: Each sorry is independently closeable. If one blocks, commit the others and document the blocker. The inconsistent case is fully independent from the consistent case.

- **Phase 3 (BX7 chain)**: If BX7 three-way disjunction elimination is too complex, implement the 4-component version first (without 5th component), mark `lemma_2_7_seed_consistent` with a weakened sorry documenting what remains. Fallback: Use a two-step BX7 derivation as insurance.

- **Phase 4a-4d (c2' threading)**: The refactor is additive. If threading c2' through all elimination branches is prohibitive, thread it only through C5/C5' and C4/C4' branches (the ones that need it), and have density/G-propagation branches use trivial c2' proofs.

- **Phase 4e (omega_chain c2')**: If modifying omega_chain return type is too invasive, add c2' as a separate theorem proved by induction on the chain, without changing the main definition.

- **Phase 5a (limit_satisfies_c5_full)**: If g-value propagation from finite stages to limit is blocked, use a direct argument via `limit_g` definition (intersection of intermediate f-values) to bypass finite-stage tracking. Fallback: Prove FUC/FSC using the weak C5 plus an additional lemma about guard propagation.

- **Phase 5b (FUC/FSC)**: If Cantor isomorphism mapping is problematic, work directly with the limit structure without the Cantor embedding.

- **General**: Git history preserves all prior states; each phase is independently committable. Use `git bisect` if regressions are detected.

---

## AGENT INSTRUCTIONS: Proof Architecture Reference

This section provides the exact proof structure for the implementation agent. Follow Burgess 1982 faithfully.

### The Burgess D0 Seed Compression Argument (Phase 2)

**Structure**: Given finite L ⊆ D₀ and d : DerivationTree L ⊥, derive False.

**Step 1**: Classify L elements into:
- (a) φ ∈ B
- (b) φ = β.neg
- (c) φ = untl(β', γ')
- (d) φ = snce(β', α')

**Step 2**: Form compressed conjunction:
- b = list_conj(β₀ :: b_list_raw) ∈ B (DCS closed under conjunction)
- γ_hat = list_conj(γ₀ :: c_list_raw) ∈ C (MCS closed)
- a_list = α values from Since formulas

**Step 3**: BX chain produces F(event) ∈ A:
1. BX5 (`self_accum_until_mcs`): `untl(b ∧ untl(b, γ_hat), γ_hat) ∈ A`
2. BX14 (`separation_until_mcs`): `untl(q, q ∧ (b∧β).neg) ∈ A` where q = b ∧ untl(b, γ_hat)
3. BX13 (`enrichment_until_mcs`) applied iteratively for each α_j ∈ a_list
4. BX10 (`until_implies_F_mcs`): `F(event) ∈ A`

**Step 4**: Show event implies each element of L via monotonicity derivations.

**Step 5**: `derivation_from_implied` + `consistent_of_F_mem` + `inconsistent_singleton_false` for contradiction.

### The Inconsistent Case (Phase 2, Site 4)

Same structure but simpler: β.neg ∈ B means it is just another B-element. No BX14 step needed. Use BX5 + BX13 + BX10 directly.

Key insight for `h_ev_b` and `h_ev_untl`:
- Event guard includes b (via BX13 enrichment with `collect_guards`)
- `event → b_list` via BX13 iteratively adding B-elements
- `b_list → b` via `list_conj_implies_elem`
- Therefore `event → b` by transitivity
- For `untl(b, γ_hat)`: event guard includes `b ∧ untl(b, γ_hat)` (from BX5 output), so `event → untl(b ∧ untl(b, γ_hat), γ_hat)` → `event → untl(b, γ_hat)` via monotonicity

### The Lemma 2.7 BX7 Chain (Phase 3)

Follow Burgess p.372 EXACTLY:

1. **Extract witness**: `lemma_2_7_neg_untl_exists` → β₀ ∈ B, γ₀ ∈ C, `¬untl(β₀∧eta, γ₀) ∈ A`

2. **BX5 on `untl(b, γ_hat)`**: `untl(b ∧ untl(b, γ_hat), γ_hat) ∈ A`

3. **BX5 on `untl(xi, eta)`**: `untl(xi ∧ untl(xi, eta), eta) ∈ A`

4. **BX7 three-way disjunction** (`linear_until_mcs`):
   - D1: `untl(b∧xi, γ_hat∧eta)` 
   - D2: `untl(b∧xi, γ_hat∧xi)`
   - D3: `untl(b∧xi, b∧eta)` (surviving disjunct)
   
5. **Eliminate D1**: `¬untl(β₀∧eta, γ₀) ∈ A` + monotonicity → contradiction

6. **Eliminate D2**: `¬untl(β₀∧eta, γ₀) ∈ A` + monotonicity → contradiction

7. **Surviving D3**: `untl(b ∧ untl(b, γ_hat) ∧ xi, θ) ∈ A` where θ contains both b and eta

8. **BX14 separation** (if needed): Separate neg(β₀∧eta) from guard

9. **BX13 iterated enrichment**: Pack `snce(guard, alpha_j)` for each alpha_j ∈ a_list (guard now contains eta from BX7)

10. **BX10 F-extraction**: `F(event) ∈ A` → event is consistent

11. **Event implies all 5 seed components**:
    - Components 1-3 (B, xi, untl-formulas): same as Phase 2 pattern
    - Component 4 (snce(β', α)): same as Phase 2 pattern  
    - Component 5 (snce(β'∧eta, α)): event implies `snce(guard, α)` where guard contains both b and eta; apply `snce_left_mono_deriv` with `guard → β'∧eta`

12. **Contradiction**: `derivation_from_implied` + `consistent_of_F_mem` + `inconsistent_singleton_false`

### c2' Threading (Phase 4)

**Definition** (Burgess C2'):
```lean
def Chronicle.c2' (χ : Chronicle) : Prop :=
  ∀ x y : Rat, Adjacent χ.dom x y →
    BurgessR3Maximal (χ.f x) (χ.g x y) (χ.f y)
```

**g-Value Construction by Elimination Type** (from research synthesis):

| Elimination | f(new) | g(left, new) | g(new, right) | c2' Source |
|-------------|--------|--------------|---------------|------------|
| C5_forward | C (from lemma_2_4) | B (from lemma_2_4) | extend via C3 | Lemma 2.4 |
| C5_backward | C' (mirror) | B' (mirror) | extend via C3 | Lemma 2.4' |
| C4_forward | D (from lemma_2_6) | B' (from lemma_2_6) | B'' (from lemma_2_6) | Lemma 2.6 |
| C4_backward | D' (mirror) | B' (mirror) | B'' (mirror) | Lemma 2.6' |
| Density | D (from lemma_2_6) | B' (from lemma_2_6) | B'' (from lemma_2_6) | Lemma 2.6 |

### FUC/FSC Coherence (Phase 5)

**Burgess Claim 2.11** (p. 373-374): For any formula φ and any point x in the limit domain: φ ∈ f(x) iff the valuation V satisfies φ at x.

**Proof for U(φ,ψ)** (p. 246):
- If `U(φ,ψ) ∈ f(x)`, then by C5a there is y ∈ X with `ψ ∈ f(y)` and `φ ∈ g(x,y)`
- If z ∈ X and x < z < y, then by C3: `g(x,y) ⊆ f(z)`, whence `φ ∈ f(z)`
- By induction hypothesis: y ∈ V(ψ) and z ∈ V(φ) for any z with x < z < y
- Whence x ∈ V(U(φ,ψ))

**Key Insight for Full C5**:
```
C5 elimination at finite stage n
  ↓
φ ∈ g_n(x, y) for new adjacent pair (if created)
  ↓
g-values persist through omega-chain (c2' ensures maximality)
  ↓
At limit: φ ∈ limit_g(x, y) (intersection of all intermediate f-values)
  ↓
By C3: limit_g(x, y) ⊆ limit_f(z) for all z ∈ (x, y)
  ↓
Therefore: φ ∈ limit_f(z) for all intermediate z
```

**Formal Statement**:
```lean
theorem limit_satisfies_c5_full (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (x : Rat) (hx : x ∈ limit_dom A h_mcs) (ξ η : Formula)
    (h_until : Formula.untl ξ η ∈ limit_f A h_mcs x) :
    ∃ y ∈ limit_dom A h_mcs, x < y ∧ η ∈ limit_f A h_mcs y ∧
      ∀ z ∈ limit_dom A h_mcs, x < z → z < y → ξ ∈ limit_f A h_mcs z
```

---

## Reference: Burgess 1982 Key Sections

All agents MUST reference the Burgess paper at:
`/home/benjamin/Projects/ProofChecker/literature/Burgess_1982_Axioms_for_tense_logic_Since_and_Until.md`

| Section | Page | Content |
|---------|------|---------|
| 2.6 | 170 | Lemma 2.6 - D0 seed consistency |
| 2.7 | 372 | Lemma 2.7 - BX7 chain, 5-component seed |
| 2.9 | 374 | Lemma 2.9 - C4 counterexample elimination |
| 2.10 | 374-375 | Lemma 2.10 - C5 counterexample elimination |
| 2.11 | 373-374 | Claim 2.11 - Truth lemma, FUC/FSC coherence |

**BX Axiom Reference** (our sound axioms for open-guard semantics):
- BX4: `connect_future` (φ → G(P(φ)))
- BX5: `self_accum_until` (U(φ,ψ) → U(φ∧U(φ,ψ), ψ))
- BX7: `linear_until` (U(φ,ψ) ∧ U(χ,θ) → (U(φ∧χ,ψ∧θ) ∨ U(φ∧χ,ψ∧χ) ∨ U(φ∧χ,φ∧θ)))
- BX10: `until_F` (U(φ,ψ) → F(ψ))
- BX13: `enrichment_until` (iteratively adds S(φ,α) to event guard)
- BX14: `separation_until` (separates negated formulas from event guard)

---

**Plan created**: 2026-05-02
**Estimated Total Effort**: 37-47 hours
**Complexity**: Complex
**Critical Path**: Phase 2 → Phase 3 → Phase 4 (4a→4b→4c→4d→4e) → Phase 5 (5a→5b→5c)
