# Implementation Plan: Task #979 (v2)

- **Task**: 979 - remove_discrete_icc_finite_axiom_prove_stage_bounding
- **Status**: [IMPLEMENTING]
- **Effort**: 8-12 hours
- **Dependencies**: Task 974 [COMPLETED], Task 980 [COMPLETED]
- **Research Inputs**:
  - specs/979_remove_discrete_icc_finite_axiom_prove_stage_bounding/reports/research-001.md (team research)
  - specs/979_remove_discrete_icc_finite_axiom_prove_stage_bounding/reports/research-002.md (DN tech debt analysis)
  - specs/979_remove_discrete_icc_finite_axiom_prove_stage_bounding/reports/research-003.md (post-980 analysis)
- **Artifacts**: plans/implementation-002.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md, proof-debt-policy.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This revised plan removes the `discrete_Icc_finite_axiom` from `DiscreteTimeline.lean` by proving interval finiteness via the covering lemma approach. The previous plan's Phase 2 was blocked; this revision restructures the approach with detailed sub-phases based on research-003.md insights.

**Key insight from research-003**: The DF frame condition `(F top and phi and H phi) -> F(H phi)` constrains which MCS can exist between a source and its forward witness. The proof requires showing that if K is between M and W, then a contradiction arises from DF applied to H-formulas.

**Approach**: No compromises, no escape valves. The covering lemma will be proven structurally.

## Goals & Non-Goals

**Goals**:
- Remove `discrete_Icc_finite_axiom` (line 244) entirely
- Prove the covering lemma `df_frame_condition_canonical` connecting DF semantics to MCS order
- Derive LocallyFiniteOrder from covering + NoMaxOrder
- Maintain zero axioms and zero sorries in `DiscreteTimeline.lean`
- Support task 978's typeclass architecture with clean abstractions

**Non-Goals**:
- Stage-bounding approach (proven mathematically flawed)
- Partial proofs or escape valves
- Generic `Antisymmetrization.locallyFiniteOrder` instance

## Axiom & Sorry Policy

### Pre-existing
- 1 axiom: `discrete_Icc_finite_axiom` (DiscreteTimeline.lean:244)
- 0 sorries

### Target
- 0 axioms in DiscreteTimeline.lean (complete elimination)
- 0 sorries

### Constraint
- **NEVER introduce new axioms**
- **NEVER introduce sorries**
- If proof cannot be completed, mark [BLOCKED] with full documentation of the specific gap

---

## Implementation Phases

### Phase 1: Infrastructure Audit and Lemma Inventory [COMPLETED]

- **Dependencies:** None (restarts fresh from Phase 1)
- **Goal:** Verify task 980 infrastructure and document reusable lemmas

**Tasks:**
- [ ] Verify task 980 MCS Richness lemmas compile and are accessible
- [ ] Inventory reusable lemmas from task 980:
  - `G_bot_not_in`, `H_bot_not_in` (negation completeness)
  - `F_or_atom_in`, `P_or_atom_in` (specific F/P formulas in MCS)
  - `mcs_has_large_F_formula`, `mcs_has_large_P_formula` (seriality without DN)
- [ ] Document the DF soundness infrastructure in Soundness.lean
- [ ] Verify `discreteness_forward_valid` theorem signature and proof technique
- [ ] Run `lake build` to confirm baseline compiles

**Files to examine:**
- `Theories/Bimodal/Metalogic/StagedConstruction/CantorPrereqs.lean` (post-980)
- `Theories/Bimodal/Metalogic/Soundness.lean`
- `Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean`

**Timing:** 1 hour

**Verification:**
- All task 980 lemmas accessible
- DF soundness theorem documented
- `lake build` passes

**Progress:**

**Session: 2026-03-16, sess_1773698234_dfbb66**
- Verified: task 980 MCS Richness lemmas (G_bot_not_in, H_bot_not_in, F_or_atom_in, P_or_atom_in, mcs_has_large_F_formula, mcs_has_large_P_formula)
- Verified: DF soundness (discreteness_forward_valid in Soundness.lean)
- Verified: CanonicalR infrastructure (g_content subset semantics)
- Verified: canonicalR_strict theorem for strictness
- Verified: StagedPoint infrastructure for discrete timeline
- Build: lake build passes (930 jobs)

---

### Phase 2: State the Covering Lemma Precisely [COMPLETED]

- **Dependencies:** Phase 1
- **Goal:** Formalize the exact statement of the covering lemma at MCS level

**Tasks:**
- [ ] Define the covering predicate for MCS:
  ```lean
  def MCS.Covers (M W : Set Formula) : Prop :=
    CanonicalR M W ∧ ∀ K, SetMaximalConsistent K →
      CanonicalR M K → CanonicalR K W → K = M ∨ K = W
  ```
- [ ] State the covering existence lemma:
  ```lean
  theorem mcs_has_immediate_successor
      (M : Set Formula) (h_mcs : SetMaximalConsistent M)
      (h_serial : ∃ N, CanonicalR M N) :
      ∃ W, SetMaximalConsistent W ∧ MCS.Covers M W
  ```
- [ ] Document the relationship to DF: why DF guarantees covering
- [ ] Add placeholder proof with `sorry` (to be filled in Phase 3)

**Files to modify:**
- `Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean` (add definitions)

**Timing:** 1 hour

**Verification:**
- Definitions compile
- Lemma statement compiles with sorry
- `lake build` passes

**Progress:**

**Session: 2026-03-16, sess_1773698234_dfbb66**
- Added: `MCS.Covers` - covering predicate for MCS pairs
- Added: `mcs_has_immediate_successor` - statement with sorry placeholder
- Build: lake build passes with sorry warning

---

### Phase 3: Prove the Covering Lemma via DF Semantics [BLOCKED]

- **Dependencies:** Phase 2
- **Goal:** Complete the covering lemma proof using DF frame condition

This is the core phase. The proof follows the sketch from research-003.md.

**Sub-phase 3a: H-Formula Propagation Lemma**

- [ ] Prove that forward witness W contains specific H-formulas:
  ```lean
  theorem forward_witness_has_H_formulas
      (M W : Set Formula) (phi : Formula) (h_F : phi.some_future ∈ M)
      (h_W : W = forwardWitnessPoint M h_mcs phi h_F) :
      ∀ psi, psi ∈ W → psi.all_past ∈ W
  ```
  (This follows from W's construction as Lindenbaum of {phi} ∪ g_content(M))

**Sub-phase 3b: DF Application Lemma**

- [ ] Prove DF application at MCS level:
  ```lean
  theorem df_in_mcs_implies_fh
      (M : Set Formula) (h_mcs : SetMaximalConsistent M)
      (h_serial : ∃ N, CanonicalR M N) (phi : Formula)
      (h_phi : phi ∈ M) (h_H : phi.all_past ∈ M) :
      phi.all_past.some_future ∈ M
  ```
  (DF is a theorem, so it's in every MCS)

**Sub-phase 3c: Intermediate MCS Contradiction**

- [ ] Prove that intermediate MCS lead to contradiction:
  ```lean
  theorem no_strict_intermediate_mcs
      (M W K : Set Formula)
      (h_M_mcs : SetMaximalConsistent M) (h_W_mcs : SetMaximalConsistent W) (h_K_mcs : SetMaximalConsistent K)
      (h_MW : CanonicalR M W) (h_MK : CanonicalR M K) (h_KW : CanonicalR K W)
      (h_K_ne_M : K ≠ M) (h_K_ne_W : K ≠ W) :
      False
  ```

  **Proof sketch**:
  1. Since K ≠ W, exists chi where chi ∈ W but chi ∉ K (or vice versa)
  2. Since CanonicalR K W, we have g_content K ⊆ W, so G(neg chi) ∈ K → G(neg chi) ∈ W → contradiction with chi ∈ W
  3. So chi ∈ W but F(chi) ∉ K (otherwise K would witness it)
  4. Since CanonicalR M K, we have g_content M ⊆ K
  5. Use DF: if some specific H-formula is in W (from M's construction), then F(H-formula) must be in M
  6. This F-obligation must be witnessed by some successor of M
  7. But the witness is W (by construction), and K is between M and W
  8. This contradicts K not having the H-formula

- [ ] Fill in the details of the proof, using MCS properties and DF membership

**Sub-phase 3d: Complete Covering Lemma**

- [ ] Prove the main lemma using sub-phases 3a-3c:
  ```lean
  theorem mcs_has_immediate_successor
      (M : Set Formula) (h_mcs : SetMaximalConsistent M)
      (h_serial : ∃ N, CanonicalR M N) :
      ∃ W, SetMaximalConsistent W ∧ MCS.Covers M W := by
    -- Get forward witness W for some F-formula in M
    obtain ⟨phi, h_F⟩ := h_serial.some_spec
    let W := forwardWitnessPoint M h_mcs phi h_F
    use W
    constructor
    · exact forwardWitnessPoint_is_mcs ...
    · constructor
      · exact forwardWitnessPoint_canonical_R ...
      · intro K h_K_mcs h_MK h_KW
        by_contra h_ne
        push_neg at h_ne
        exact no_strict_intermediate_mcs M W K ... h_ne.1 h_ne.2
  ```

**Files to modify:**
- `Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean` (add lemmas and proof)

**Timing:** 4-6 hours

**Verification:**
- All lemmas compile without sorry
- `lake build` passes

**Progress:**

**Session: 2026-03-16, sess_1773698234_dfbb66**
- Added: `mcs_has_immediate_successor` theorem statement with proof structure
- Attempted: Using DF membership to constrain intermediate MCS
- Attempted: Using g_content_subset_implies_h_content_reverse for backwards propagation
- Attempted: Finding distinguishing formula for K != W case
- BLOCKED: Cannot derive contradiction from K being strictly between M and W
- The DF axiom membership constrains what formulas are in M, but does not directly imply covering
- See docstring in DiscreteTimeline.lean for detailed analysis
- Build: lake build passes with sorry (1 sorry in mcs_has_immediate_successor)

**Blocker Analysis:**
- The covering lemma requires showing that if K is strictly between M and W (MCS with
  CanonicalR M K and CanonicalR K W, but K != M and K != W), then we get a contradiction
- DF axiom `(F⊤ ∧ φ ∧ Hφ) → F(Hφ)` is in every MCS, but this constrains formula membership
  in the source MCS, not the order structure
- The gap is connecting DF membership (syntactic) to covering (structural property)
- Lindenbaum extension is non-deterministic, so W is not uniquely determined
- research-003.md identified this as mathematically deep; no simple resolution found

---

### Phase 4: Define Direct Successor Function [NOT STARTED]

- **Dependencies:** Phase 3
- **Goal:** Define `discreteSuccFn_direct` using the covering lemma

**Tasks:**
- [ ] Define successor on StagedPoint level:
  ```lean
  noncomputable def stagedImmediateSucc (p : StagedPoint) : StagedPoint :=
    let ⟨W, h_W_mcs, h_covers⟩ := mcs_has_immediate_successor p.mcs p.h_mcs p.h_serial
    ⟨maxStage ..., W, h_W_mcs, ...⟩
  ```

- [ ] Prove well-definedness on quotient:
  ```lean
  theorem stagedImmediateSucc_respects_equiv :
      ∀ p q, StagedPoint.equiv p q →
        StagedPoint.equiv (stagedImmediateSucc p) (stagedImmediateSucc q)
  ```
  (Same g_content → same successor class)

- [ ] Lift to quotient:
  ```lean
  noncomputable def discreteSuccFn_direct (a : DiscreteTimelineQuot) : DiscreteTimelineQuot :=
    Quotient.liftOn a (fun p => ⟦stagedImmediateSucc p⟧) stagedImmediateSucc_respects_equiv
  ```

**Files to modify:**
- `Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean`

**Timing:** 1.5 hours

**Verification:**
- `discreteSuccFn_direct` compiles
- `lake build` passes

---

### Phase 5: Prove SuccOrder Properties from Covering [NOT STARTED]

- **Dependencies:** Phase 4
- **Goal:** Prove SuccOrder axioms for `discreteSuccFn_direct`

**Tasks:**
- [ ] Prove successor is strictly greater:
  ```lean
  theorem discreteSuccFn_direct_lt (a : DiscreteTimelineQuot) :
      a < discreteSuccFn_direct a
  ```
  (From CanonicalR being strict ordering)

- [ ] Prove successor is covering:
  ```lean
  theorem discreteSuccFn_direct_covBy (a : DiscreteTimelineQuot) :
      a ⋖ discreteSuccFn_direct a
  ```
  (From MCS.Covers property)

- [ ] Prove successor is minimal among greater elements:
  ```lean
  theorem discreteSuccFn_direct_le_of_lt (a b : DiscreteTimelineQuot) (h : a < b) :
      discreteSuccFn_direct a ≤ b
  ```
  (From covering: no element strictly between a and succ a)

- [ ] Instantiate SuccOrder:
  ```lean
  noncomputable instance : SuccOrder DiscreteTimelineQuot where
    succ := discreteSuccFn_direct
    le_succ a := le_of_lt (discreteSuccFn_direct_lt a)
    max_of_succ_le := ... -- From NoMaxOrder + covering
    succ_le_of_lt := discreteSuccFn_direct_le_of_lt
  ```

**Files to modify:**
- `Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean`

**Timing:** 1.5 hours

**Verification:**
- SuccOrder instance compiles
- `lake build` passes

---

### Phase 6: Derive LocallyFiniteOrder from SuccOrder [NOT STARTED]

- **Dependencies:** Phase 5
- **Goal:** Prove interval finiteness using SuccOrder + covering

**Tasks:**
- [ ] Prove interval finiteness via induction on successor chain:
  ```lean
  theorem discrete_Icc_finite_from_covering (a b : DiscreteTimelineQuot) :
      (Set.Icc a b).Finite := by
    by_cases h : a ≤ b
    · -- Induct on the covering chain from a to b
      -- Base: a = b → singleton
      -- Step: a < b → Icc a b = {a} ∪ Icc (succ a) b
      -- Termination: IsSuccArchimedean guarantees reaching b
      induction' (well_founded_lt.wf.apply (b - a)) using Nat.strong_induction_on with n ih
      ...
    · simp [Set.Icc_eq_empty (le_of_not_le h)]
  ```

- [ ] Instantiate LocallyFiniteOrder:
  ```lean
  noncomputable instance : LocallyFiniteOrder DiscreteTimelineQuot :=
    LocallyFiniteOrder.ofFiniteIcc (fun a b => discrete_Icc_finite_from_covering a b)
  ```

- [ ] Verify IsSuccArchimedean derives automatically:
  ```lean
  #check (inferInstance : IsSuccArchimedean DiscreteTimelineQuot)
  ```

**Files to modify:**
- `Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean`

**Timing:** 1.5 hours

**Verification:**
- LocallyFiniteOrder instance compiles
- IsSuccArchimedean available
- `lake build` passes

---

### Phase 7: Remove Axiom and Refactor [NOT STARTED]

- **Dependencies:** Phase 6
- **Goal:** Remove the axiom and update all dependent code

**Tasks:**
- [ ] Remove `discrete_Icc_finite_axiom` declaration (line 244)
- [ ] Update `discrete_Icc_finite` to use `discrete_Icc_finite_from_covering`
- [ ] Remove old `LocallyFiniteOrder` instance using axiom
- [ ] Remove old `SuccOrder` instance using `LinearLocallyFiniteOrder`
- [ ] Update docstrings to document the covering-based approach
- [ ] Remove "AXIOM (Technical Debt)" comment block

**Files to modify:**
- `Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean`

**Timing:** 45 minutes

**Verification:**
- `grep -n "^axiom " DiscreteTimeline.lean` returns empty
- `grep -n "\bsorry\b" DiscreteTimeline.lean` returns empty
- `lake build` passes

---

### Phase 8: Final Verification and Task 978 Preparation [NOT STARTED]

- **Dependencies:** Phase 7
- **Goal:** Complete verification and document for task 978

**Tasks:**
- [ ] Run `lake build` for full project verification
- [ ] Verify all instances work:
  - SuccOrder, PredOrder, LocallyFiniteOrder, IsSuccArchimedean
  - NoMaxOrder, NoMinOrder
  - discreteCanonicalTaskFrame
- [ ] Document the covering lemma approach for task 978:
  - Add module docstring explaining the proof technique
  - Note that DiscreteFrame typeclass can require LocallyFiniteOrder
  - Explain how DF frame condition yields covering
- [ ] Check dependent files compile
- [ ] Create implementation summary

**Files to modify:**
- `Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean` (docstrings)

**Timing:** 45 minutes

**Verification:**
- Zero axioms in DiscreteTimeline.lean
- Zero sorries in DiscreteTimeline.lean
- `lake build` passes completely
- All dependent files compile
- Summary created

---

## Testing & Validation

### Required Checks
- [ ] `lake build` passes with no errors
- [ ] `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean` returns empty
- [ ] `grep -n "^axiom " Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean` returns empty
- [ ] All proofs verified with `lean_goal` showing "no goals"

### Key Lemmas to Verify
| Lemma | Expected State |
|-------|---------------|
| `mcs_has_immediate_successor` | Proven (no sorry) |
| `no_strict_intermediate_mcs` | Proven (no sorry) |
| `discreteSuccFn_direct` | Defined |
| `discrete_Icc_finite_from_covering` | Proven (no sorry) |
| `discreteCanonicalTaskFrame` | Compiles |

---

## Artifacts & Outputs

- `specs/979_remove_discrete_icc_finite_axiom_prove_stage_bounding/plans/implementation-002.md` (this file)
- `specs/979_remove_discrete_icc_finite_axiom_prove_stage_bounding/summaries/implementation-summary-YYYYMMDD.md` (on completion)
- Modified: `Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean`

---

## Risk Assessment

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| no_strict_intermediate_mcs proof gap | High | Medium | Document specific gap, request user input |
| Well-definedness on quotient complex | Medium | Low | Use existing g_content equivalence machinery |
| Interval finiteness induction complex | Medium | Low | Use Mathlib well-founded induction |
| Task 978 dependency issues | Low | Low | Document interface clearly |

---

## Revision History

- **v1** (implementation-001.md): Phase 2 blocked on covering lemma; no detailed sub-phases
- **v2** (implementation-002.md): Restructured with detailed sub-phases for covering lemma proof based on research-003.md insights; no escape valves; 8 phases
