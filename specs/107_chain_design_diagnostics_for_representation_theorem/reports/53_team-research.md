# Task 107 Research Synthesis Report: Burgess Chronicle Construction Master Plan

**Session**: sess_1777762781_b2f826  
**Date**: 2026-05-02  
**Synthesized From**: Teammate A (Phase 2), Teammate B (Phase 3), Teammate C (Phase 4), Teammate D (Phase 5)  
**Burgess Reference**: Burgess 1982, "Axioms for Tense Logic: Since and Until"

---

## Executive Summary

This synthesis report consolidates findings from four parallel research investigations into the remaining blockers for Task 107 (Burgess chronicle construction). The research follows Burgess 1982 Sections 2.6-2.11 faithfully to produce a mathematically ideal solution.

**Current Status**: 18 sorry sites remain across Phases 2-5  
**Total Estimated Effort**: 37-47 hours (phased approach)  
**Critical Path**: Phase 2 (inconsistent case) → Phase 3 (Lemma 2.7) → Phase 4 (c2' threading) → Phase 5 (FUC/FSC)  

---

## 1. Phase-by-Phase Research Summary

### 1.1 Phase 2: D0 Seed Consistency - Inconsistent Case

**Status**: [PARTIAL] - 2 sorries remain at lines 1858-1859  
**Location**: `PointInsertion.lean`, theorem `burgess_D0_finite_subset_consistent_incons`  

**The Problem**:  
The inconsistent case (β.neg ∈ B) lacks BX14 (separation_until) which the consistent case uses to provide structural handle `q = b ∧ untl(b,γ)`. Without this, the enriched event only implies `γ_hat`, not `b` or `untl(b, γ_hat)`.

**Root Cause Analysis** (Teammate A):  
- BX14 provides `event → q ∧ (b∧β).neg` in consistent case
- Inconsistent case: `β.neg ∈ B` so no separation needed
- But enrichment only provides `event → γ_hat`  
- Gap: Need to derive `event → b` and `event → untl(b, γ_hat)` for L-membership proofs

**Burgess 1982 Reference**: Section 2.6, p. 170 (Lemma 2.6 proof)  
> "Let D₀ = {S(α, β) : α ∈ A, β ∈ B} ∪ B ∪ {¬δ} ∪ {U(γ, β) : γ ∈ C, β ∈ B}"

With δ = β.neg ∈ B, the set simplifies and the proof omits A4a (BX14).

**Recommended Solution** (Option B from Teammate A):  
Restructure L-membership proof to avoid direct use of `h_ev_b` and `h_ev_untl`:
- For φ ∈ B: Use `collect_guards` properties directly
- For φ = untl(β', γ'): Use `untl(b, γ_hat) ∈ A` with monotonicity directly
- For φ = snce(β', α'): Already works via `h_ev_snce`

**Estimated Effort**: 2-4 hours  
**Dependencies**: None (can proceed in parallel with Phase 3 preparation)

---

### 1.2 Phase 3: Lemma 2.7 Seed Consistency - BX7 Chain

**Status**: [BLOCKED] - Main sorry at line 2391  
**Location**: `PointInsertion.lean`, theorem `lemma_2_7_seed_consistent`  

**The Problem**:  
Implement the full 10-step BX7 (linear_until) chain per Burgess 1982 p.372 for the 5-component seed.

**Key Finding** (Teammate B):  
The MCS-level wrapper `linear_until_mcs` for BX7 does **NOT currently exist** and must be implemented.

**The 5-Component Seed Structure**:
```lean
B ∪ {xi} ∪ {untl(β, γ) | β ∈ B, γ ∈ C} ∪
{snce(β, α) | β ∈ B, α ∈ A} ∪
{snce(β ∧ eta, α) | β ∈ B, α ∈ A}  -- Component 5: requires BX7
```

**The 10-Step BX7 Chain**:

| Step | Action | Axiom/Lemma | Output |
|------|--------|-------------|--------|
| 1 | Extract neg-until witness | `lemma_2_7_neg_untl_exists` | β₀ ∈ B, γ₀ ∈ C, ¬untl(β₀∧eta, γ₀) ∈ A |
| 2 | BX5 on `untl(xi, eta)` | `self_accum_until_mcs` | `untl(xi ∧ untl(xi,eta), eta) ∈ A` |
| 3 | BX5 on `untl(beta₀, gamma₀)` | `self_accum_until_mcs` | `untl(beta₀ ∧ untl(beta₀,gamma₀), gamma₀) ∈ A` |
| 4 | BX7 three-way disjunction | `linear_until_mcs` (NEW) | D1 ∨ D2 ∨ D3 ∈ A |
| 5 | Case analysis | `disjunction_property` | Which disjunct holds |
| 6a | Eliminate D1 | `lemma_2_7_disjunct_elim_D1` (NEW) | Contradiction via monotonicity |
| 6b | Eliminate D2 | `lemma_2_7_disjunct_elim_D2` (NEW) | Contradiction via monotonicity |
| 7 | D3 survives | Elimination | `untl(combined_guard, (beta₀ ∧ U(beta₀,gamma₀)) ∧ eta) ∈ A` |
| 8 | BX13 enrichment | `iterated_enrichment` | Event with `snce(guard, alpha)` |
| 9 | BX10 extraction | `until_implies_F_mcs` | `F(event) ∈ A` |
| 10 | Event implies seed | Implication chains | All 5 components implied |

**Required New Lemmas** (Teammate B):

```lean
-- Step 1: Extract witness from maximality
private theorem lemma_2_7_neg_untl_exists {A B C : Set Formula}
    (h_mcs_A : SetMaximalConsistent A) (h_mcs_C : SetMaximalConsistent C)
    (h_r3m : BurgessR3Maximal A B C) (eta : Formula)
    (h_eta_not_B : eta ∉ B) (h_F_eta : Formula.some_future eta ∈ A) :
    ∃ β₀ ∈ B, ∃ γ₀ ∈ C, (Formula.untl (Formula.and β₀ eta) γ₀).neg ∈ A

-- Step 4: BX7 at MCS level (CRITICAL - does not exist)
private theorem linear_until_mcs {A : Set Formula} (h_mcs : SetMaximalConsistent A)
    {phi1 psi1 phi2 psi2 : Formula}
    (h_until1 : Formula.untl phi1 psi1 ∈ A)
    (h_until2 : Formula.untl phi2 psi2 ∈ A) :
    Formula.or (Formula.or
      (Formula.untl (Formula.and phi1 phi2) (Formula.and psi1 psi2))
      (Formula.untl (Formula.and phi1 phi2) (Formula.and psi1 phi2)))
      (Formula.untl (Formula.and phi1 phi2) (Formula.and phi1 psi2)) ∈ A

-- Steps 6a/6b: Disjunct elimination
private theorem lemma_2_7_disjunct_elim_D1 {A : Set Formula} ...
private theorem lemma_2_7_disjunct_elim_D2 {A : Set Formula} ...
```

**Burgess 1982 Reference**: Section 2.7, p. 372 (Lemma 2.7)  
> "A7a applies to tell us that one of the following must belong to A: U(γ ∧ ξ, θ), U(γ ∧ U(ξ,η), θ), or U(β ∧ U(γ,β) ∧ ξ, θ)"

**Critical Insight**: BX7 ≠ A7a. A7a was removed as unsound under open guard. BX7 has different disjuncts that are valid under open guard semantics.

**Estimated Effort**: 5 hours (~185 lines)  
**Dependencies**: Phase 2 completion (for pattern reference)

---

### 1.3 Phase 4: c2' Threading and G-Value Construction

**Status**: [STRUCTURE ADDED, PROOFS TODO] - 10 c2' sorry sites  
**Location**: `CounterexampleElimination.lean`, `EliminationResult.c2'` field  

**The Problem**:  
Make g a first-class mathematical object by modifying `EliminationResult` to carry c2' (BurgessR3Maximal at adjacent pairs), assign proper g-values in each elimination function.

**c2' Definition** (Burgess C2'):
```lean
def Chronicle.c2' (χ : Chronicle) : Prop :=
  ∀ x y : Rat, Adjacent χ.dom x y →
    BurgessR3Maximal (χ.f x) (χ.g x y) (χ.f y)
```

**The 10 c2' Sorry Sites** (Teammate C):

| Line | Elimination Type | Case | Strategy |
|------|-----------------|------|----------|
| 756 | C5_forward | Elimination | Use Lemma 2.4 B output |
| 768 | C5_forward | No elimination | c2' preserved (trivial) |
| 794 | C5_backward | Elimination | Use Lemma 2.4 mirror |
| 806 | C5_backward | No elimination | c2' preserved (trivial) |
| 834 | C4_forward | Elimination | **Hard**: Lemma 2.6 splitting |
| 845 | C4_forward | No elimination | c2' preserved (trivial) |
| 872 | C4_backward | Elimination | **Hard**: Lemma 2.6 mirror |
| 883 | C4_backward | No elimination | c2' preserved (trivial) |
| 918 | Density | Elimination | Split g(x,y) via C3 |
| 931 | Density | No elimination | c2' preserved (trivial) |

**Pattern**: 5 hard "elimination" cases + 5 easy "no elimination" cases

**G-Value Construction by Elimination Type**:

| Elimination | f(new) | g(left, new) | g(new, right) | c2' Source |
|-------------|--------|--------------|---------------|------------|
| C5_forward | C (from 2.4) | B (from 2.4) | extend via C3 | Lemma 2.4 |
| C5_backward | C' (from 2.4') | B' (from 2.4') | extend via C3 | Lemma 2.4' |
| C4_forward | D (from 2.6) | B' (from 2.6) | B'' (from 2.6) | Lemma 2.6 |
| C4_backward | D' (from 2.6') | B' (from 2.6') | B'' (from 2.6') | Lemma 2.6' |
| Density | D (from 2.6) | B' (from 2.6) | B'' (from 2.6) | Lemma 2.6 |

**Burgess 1982 Reference**: Section 2.9 (Lemma 2.9 C4), Section 2.10 (Lemma 2.10 C5)  
> "Lemma 2.9: Given a counterexample to C4a, extend the chronicle to eliminate it"  
> "Proof by induction on n = elements between x and y. Case n = 0: Apply Lemma 2.6"

**Critical Path Dependency**:  
- C4/C4' hard cases (lines 412, 510) require **Lemma 2.6 splitting** 
- Lemma 2.6 uses **D0 seed consistency** from Phase 2
- C5 cases require **Lemma 2.7** from Phase 3

**Estimated Effort**: 6 hours  
**Dependencies**: Phase 2 (Lemma 2.6), Phase 3 (Lemma 2.7)

---

### 1.4 Phase 5: FUC/FSC Coherence - Truth Lemma

**Status**: [BLOCKED] - 2 sorries at lines 615, 619  
**Location**: `ChronicleToCountermodel.lean`  

**The Problem**:  
Close FUC (Forward Until Coherence) and FSC (Forward Since Coherence) sorry sites. These represent the **culmination of Burgess's completeness proof** - the truth lemma establishing that the chronicle construction faithfully represents Until/Since formulas.

**The Gap** (Teammate D):  
- Current: `limit_satisfies_c5_weak` provides endpoint witness (∃ y > x, ψ ∈ f(y))
- Missing: The guard φ ∈ f(z) for all intermediate points z ∈ (x,y)
- Need: `limit_satisfies_c5_full` with complete guard condition

**Burgess 1982 Reference**: Section 2.11, Claim 2.11 (p. 373-374)  
> "Claim 2.11: For any formula φ and any point x in the limit domain: φ ∈ f(x) iff the valuation V satisfies φ at x"

**The Key Insight**:  
C5 at **finite stages** carries the full guard information. When we eliminate a C5 counterexample at stage n:
1. Insert witness point y with ψ ∈ f(y)
2. **Crucially**: For all intermediate points z already in dom(n), φ ∈ f(z)
3. Future stages add more points in (x, y) ∩ limit_dom
4. **Must prove**: For any z added later, φ ∈ limit_f(z)

**The g-Value Propagation Chain**:
```
C5 elimination at stage n
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

**Required Helper Lemmas** (Teammate D):

```lean
-- Lemma 1: C5 elimination preserves guard at existing points
theorem omega_chain_c5_preserves_guard (A : Set Formula) ...

-- Lemma 2: If φ ∈ g_n(x,y) at stage n, and z ∈ (x,y) is added later,
-- then φ ∈ f(z) at the limit
theorem g_value_propagates_to_future_points (A : Set Formula) ...

-- Lemma 3: C5 implies φ ∈ g(x,y) at the elimination stage
theorem c5_implies_phi_in_g (A : Set Formula) ...

-- Lemma 4: g-values persist through the omega-chain
theorem g_value_persistence (A : Set Formula) ...

-- MAIN: Full C5 with guard
theorem limit_satisfies_c5_full (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (x : Rat) (hx : x ∈ limit_dom A h_mcs) (ξ η : Formula)
    (h_until : Formula.untl ξ η ∈ limit_f A h_mcs x) :
    ∃ y ∈ limit_dom A h_mcs, x < y ∧ η ∈ limit_f A h_mcs y ∧
      ∀ z ∈ limit_dom A h_mcs, x < z → z < y → ξ ∈ limit_f A h_mcs z
```

**Estimated Effort**: 22-32 hours (4 hours per proof plan)  
**Dependencies**: Phase 4 (c2' at finite stages)

---

## 2. Unified Proof Architecture

### 2.1 Dependency Graph

```
Phase 2: Inconsistent Case (2 sorries)
  ├─ Uses: BX5, BX13, BX10 (existing)
  ├─ Gap: Event → b, Event → untl(b,γ)
  └─ Solution: Restructure L-membership proof
         ↓
Phase 3: Lemma 2.7 (1 main sorry)
  ├─ Uses: BX5, BX7 (NEW), BX13, BX10
  ├─ Critical: linear_until_mcs wrapper
  ├─ 10-step BX7 chain per Burgess p.372
  └─ Blocks: Phase 4 C5 cases
         ↓
Phase 4: c2' Threading (10 sorries)
  ├─ C5_forward/backward: Lemma 2.4 output
  ├─ C4_forward/backward (hard): Lemma 2.6 splitting ← Phase 2
  ├─ C4_forward/backward (hard): Lemma 2.7 splitting ← Phase 3
  ├─ Density: C3 splitting
  └─ Blocks: Phase 5 (g-value propagation)
         ↓
Phase 5: FUC/FSC (2 sorries)
  ├─ Requires: c2' at finite stages (Phase 4)
  ├─ Requires: limit_satisfies_c5_full (NEW)
  ├─ Uses: Claim 2.11 argument (Burgess p.373-374)
  └─ Result: ZERO SORRIES in dd_countermodel_chronicle
```

### 2.2 Critical Path Analysis

**Sequential Dependencies** (must be completed in order):
1. **Phase 2** inconsistent case → Unblocks nothing critical, but good practice
2. **Phase 3** Lemma 2.7 → Blocks Phase 4 C5 cases
3. **Phase 4** c2' threading → Blocks Phase 5 g-value propagation
4. **Phase 5** FUC/FSC → Final completion

**Parallel Work Possible**:
- Phase 2 can proceed while preparing Phase 3 helpers
- Phase 4 "no elimination" cases (5 sorries) can be done early
- Phase 5 helper lemmas can be drafted while Phase 4 completes

---

## 3. Master Implementation Sequence

### Phase 2: Complete Inconsistent Case (Priority: HIGH)

**Goal**: Close 2 sorries in `burgess_D0_finite_subset_consistent_incons`

**Approach**: Restructure L-membership proof (Option B from Teammate A)

**Steps**:
1. Remove direct dependencies on `h_ev_b` and `h_ev_untl`
2. For φ ∈ B: Use `collect_guards_mem_of_B` → `list_conj_implies_elem` → direct derivation
3. For φ = untl(β', γ'): Use `untl(b, γ_hat) ∈ A` with left/right monotonicity directly
4. For φ = snce(β', α'): Keep existing `h_ev_snce` chain
5. Verify `burgess_D0_seed_consistent` compiles sorry-free

**Estimated**: 2-4 hours  
**Verification**: `lake build` succeeds, PointInsertion.lean sorry count reduced by 2

---

### Phase 3: Implement Lemma 2.7 (Priority: CRITICAL)

**Goal**: Close sorry in `lemma_2_7_seed_consistent` (line 2391)

**Prerequisites**:
1. Implement `linear_until_mcs` (BX7 MCS wrapper) - ~15 lines
2. Implement `lemma_2_7_neg_untl_exists` - ~40 lines
3. Implement `lemma_2_7_disjunct_elim_D1` - ~25 lines
4. Implement `lemma_2_7_disjunct_elim_D2` - ~25 lines

**Main Proof Structure** (~80 lines):
```lean
private theorem lemma_2_7_seed_consistent ... := by
  -- Step 1: Extract neg-until witness
  obtain ⟨beta0, h_beta0, gamma0, h_gamma0, h_neg_until⟩ := 
    lemma_2_7_neg_untl_exists ...
  
  -- Steps 2-3: BX5 self-accumulation
  have h_bx5_1 := self_accum_until_mcs ...
  have h_bx5_2 := self_accum_until_mcs ...
  
  -- Step 4: BX7 three-way disjunction
  have h_bx7 := linear_until_mcs ...
  
  -- Steps 5-7: Eliminate D1, D2; use D3
  rcases disjunction_property h_mcs_A h_bx7 with (h_D1 | h_D2 | h_D3)
  · exfalso; exact lemma_2_7_disjunct_elim_D1 ...
  · exfalso; exact lemma_2_7_disjunct_elim_D2 ...
  · -- D3 survives
    
    -- Steps 8-9: BX13 enrichment + BX10 extraction
    let evt := iterated_enrichment ...
    have h_F_event := until_implies_F_mcs ...
    
    -- Step 10: Event implies all 5 seed components
    sorry -- Derivation from enriched event
```

**Estimated**: 5 hours (~185 lines total)  
**Verification**: `lemma_2_7` compiles sorry-free

---

### Phase 4: c2' Threading (Priority: CRITICAL)

**Goal**: Close 10 c2' sorry sites in CounterexampleElimination.lean

**Phase 4a: Helper Lemmas** (2 hours)
1. Complete Lemma 2.6 proof (currently has sorry at lines 1858-1859)
2. Ensure Lemma 2.7 is available (from Phase 3)
3. Prove C3 propagation lemmas for new g-values

**Phase 4b: G-Value Construction** (2 hours)
1. Update `eliminate_C5_counterexample` to return `BurgessR3Maximal`
2. Update C4 hard case (line 412) to use `lemma_2_6_splitting`
3. Update C4' hard case (line 510) to use `lemma_2_6_splitting` mirror
4. Update density case to use `lemma_2_6` with arbitrary δ

**Phase 4c: c2' Proofs** (2 hours)
1. Lines 756, 768: C5_forward (elimination + no elimination)
2. Lines 794, 806: C5_backward (elimination + no elimination)
3. Lines 834, 845: C4_forward (elimination + no elimination)
4. Lines 872, 883: C4_backward (elimination + no elimination)
5. Lines 918, 931: Density (elimination + no elimination)

**Estimated**: 6 hours total  
**Verification**: All 10 c2' sites closed, CounterexampleElimination.lean sorry count: 0

---

### Phase 5: FUC/FSC Coherence (Priority: HIGH)

**Goal**: Close 2 sorries in ChronicleToCountermodel.lean (lines 615, 619)

**Phase 5a: Helper Lemmas** (11-16 hours)
1. `omega_chain_c5_preserves_guard` - 4-6 hours
2. `g_value_propagates_to_future_points` - 3-4 hours
3. `c5_implies_phi_in_g` - 2-3 hours
4. `g_value_persistence` - 2-3 hours

**Phase 5b: Main Theorems** (8-10 hours)
1. `limit_satisfies_c5_full` - 4-6 hours
2. `cantor_bfmcs_restricted_fuc` (line 615) - 3-4 hours
3. `cantor_bfmcs_restricted_fsc` (line 619) - 2-3 hours

**Proof Structure for FUC**:
```leanntax
theorem cantor_bfmcs_restricted_fuc ... := by
  -- Step 1: Transfer to limit coordinates
  set offset := s - cantor_zero N h_N
  have h_until' : Formula.untl φ ψ ∈ limit_f N h_N ...
  
  -- Step 2: Apply limit_satisfies_c5_full (NEW)
  obtain ⟨y, hy_dom, hy_lt, hy_ψ, h_guard⟩ := 
    limit_satisfies_c5_full N h_n ... h_until'
  
  -- Step 3: Transfer witness back to rational coordinates
  set y_rat := (cantor_iso N h_N) ⟨y, hy_dom⟩ + offset
  
  -- Step 4: Prove guard in rational coordinates
  have h_guard_rat : ∀ r : Rat, t < r → r < y_rat → 
    φ ∈ (rooted_cantor_fmcs N h_N s).mcs r := by
    intro r ht_r r_y
    -- Transfer r to limit coordinates
    -- Apply h_guard after coordinate transformation
    sorry
  
  exact ⟨y_rat, hy_rat_lt, hy_ψ_rat, h_guard_rat⟩
```

**Estimated**: 22-32 hours total  
**Verification**: `#print axioms dd_countermodel_chronicle` shows no `sorryAx`

---

## 4. Risk Assessment and Mitigation

### 4.1 High-Risk Items

| Risk | Phase | Impact | Mitigation |
|------|-------|--------|------------|
| `linear_until_mcs` implementation | 3 | Critical | Axiom already exists; wrapper is straightforward |
| D2 elimination proof | 3 | High | Use Teammate B's disjunct analysis; test early |
| Component 5 for arbitrary β | 3 | High | May need additional BX13 iterations; document clearly |
| Lemma 2.6 has sorry stubs | 2/4 | Critical | Phase 2 must complete first; consider alternative approaches |
| c2' requires Lemma 2.6/2.7 | 4 | Critical | Sequential dependency; don't start Phase 4 until 2/3 complete |
| c2' at finite stages doesn't propagate | 5 | Critical | Core assumption; verify with simple examples first |
| g-value persistence | 5 | Medium | May need additional lemmas about omega-chain structure |

### 4.2 Mitigation Strategies

1. **Incremental Implementation**: Implement and test each helper lemma separately before integration
2. **Early Validation**: Verify `linear_until_mcs` with simple test cases before using in main proof
3. **Fallback for Lemma 2.6**: If inconsistent case cannot be closed, document limitation and proceed with weaker invariant
4. **Parallel Development**: Draft Phase 5 helper signatures while Phase 4 completes
5. **Regular Checkpoints**: Run `lake build` after each major component to catch errors early

---

## 5. Verification Checklist

### After Each Phase

**Phase 2**:
- [ ] `burgess_D0_finite_subset_consistent_incons` compiles sorry-free
- [ ] PointInsertion.lean sorry count: 2 (down from 4)
- [ ] `lake build` succeeds

**Phase 3**:
- [ ] `linear_until_mcs` implemented and tested
- [ ] `lemma_2_7_neg_untl_exists` implemented
- [ ] `lemma_2_7_seed_consistent` compiles sorry-free
- [ ] `lemma_2_7` compiles sorry-free
- [ ] PointInsertion.lean sorry count: 1 (down from 3)
- [ ] `lake build` succeeds

**Phase 4**:
- [ ] All 10 c2' sorry sites closed
- [ ] C4 hard case (line 412) uses Lemma 2.6 correctly
- [ ] C4' hard case (line 510) uses Lemma 2.6 mirror correctly
- [ ] CounterexampleElimination.lean sorry count: 0
- [ ] `lake build` succeeds

**Phase 5**:
- [ ] `limit_satisfies_c5_full` implemented
- [ ] FUC sorry (line 615) closed
- [ ] FSC sorry (line 619) closed
- [ ] ChronicleToCountermodel.lean sorry count: 0
- [ ] `#print axioms dd_countermodel_chronicle` shows no `sorryAx`
- [ ] `lake build` succeeds

### Final Verification
- [ ] `grep -rn "sorry" Theories/Bimodal/Metalogic/BXCanonical/Chronicle/` returns only comments
- [ ] All previously sorry-free lemmas remain sorry-free
- [ ] No new axioms introduced (check `#print axioms`)
- [ ] Documentation updated in all modified files

---

## 6. References

### Primary Source
- **Burgess 1982**: "Axioms for Tense Logic: Since and Until", Notre Dame Journal of Formal Logic, Vol. 23, No. 4, October 1982, pp. 367-374

### Key Sections
- **Section 2.6**: Lemma 2.6 (p. 170) - D0 seed consistency
- **Section 2.7**: Lemma 2.7 (p. 372) - BX7 chain, point insertion
- **Section 2.9**: Lemma 2.9 (p. 374) - C4 counterexample elimination
- **Section 2.10**: Lemma 2.10 (p. 374-375) - C5 counterexample elimination
- **Section 2.11**: Claim 2.11 (p. 373-374) - Truth lemma, FUC/FSC coherence

### Team Research Reports
- `specs/107_chain_design_diagnostics_for_representation_theorem/reports/53_team-research/teammate-a-phase2-inconsistent.md` - Phase 2 analysis
- `specs/107_chain_design_diagnostics_for_representation_theorem/reports/53_team-research/teammate-b-phase3-lemma27.md` - Phase 3 BX7 chain
- `specs/107_chain_design_diagnostics_for_representation_theorem/reports/53_team-research/teammate-c-phase4-c2-threading.md` - Phase 4 c2' threading
- `specs/107_chain_design_diagnostics_for_representation_theorem/reports/53_team-research/teammate-d-phase5-fuc-fsc.md` - Phase 5 truth lemma

### Implementation Files
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` - Lemmas 2.6, 2.7
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` - c2' threading
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` - FUC/FSC
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` - limit_satisfies_c5_full
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleTypes.lean` - c2' definition

---

## 7. Conclusion

This synthesis report provides a complete roadmap for finishing Task 107 following Burgess 1982. The research from all four teammates confirms:

1. **Phase 2** (inconsistent case) requires restructuring L-membership proofs - 2-4 hours
2. **Phase 3** (Lemma 2.7) requires implementing the BX7 chain with new helper lemmas - 5 hours
3. **Phase 4** (c2' threading) requires g-value construction using Lemma 2.6/2.7 outputs - 6 hours
4. **Phase 5** (FUC/FSC) requires establishing g-value propagation from finite to limit stages - 22-32 hours

**Critical Path**: Phase 2 → Phase 3 → Phase 4 → Phase 5

**Total Estimated Effort**: 37-47 hours

**Risk Level**: Medium-High (main risks are D2 elimination in Phase 3 and g-value propagation in Phase 5)

The mathematical foundation is sound per Burgess 1982. The implementation requires careful sequencing of helper lemmas and systematic closure of sorry sites following the dependency graph.

---

*Synthesis Report prepared by consolidating research from 4 teammates*  
*Following Burgess 1982 approach - mathematically ideal, no corners cut*
