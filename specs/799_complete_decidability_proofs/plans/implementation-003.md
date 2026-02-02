# Implementation Plan: Task #799 (Revised v003)

- **Task**: 799 - Complete Decidability proofs
- **Status**: [PARTIAL]
- **Version**: 003
- **Effort**: 5-6 hours (reduced from 7-8 due to concrete proof sketches)
- **Dependencies**: None (builds on existing FMP infrastructure)
- **Research Inputs**:
  - specs/799_complete_decidability_proofs/reports/research-001.md (initial analysis)
  - specs/799_complete_decidability_proofs/reports/research-002.md (blockage diagnosis)
  - specs/799_complete_decidability_proofs/reports/research-003.md (blocker resolution with proof strategies)
- **Artifacts**: plans/implementation-003.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Complete 6 remaining sorries in the Decidability module across three files.

**Key Revision from v002**: The Phase 1 blocker is now fully resolved. Research-003.md provides concrete proof implementations using a witness-extraction approach with `List.findSome?_isSome_iff`. All required Mathlib lemmas have been verified.

### Key Changes from v002

1. **Blocker resolved**: Phase 1-3 now have complete proof sketches
2. **Strategy confirmed**: Witness extraction using `List.findSome?_isSome_iff` + helper lemmas
3. **Reduced effort estimate**: 5-6 hours (concrete code reduces uncertainty)
4. **Merged phases**: Phases 0-3 consolidated into logical groups

## Goals & Non-Goals

**Goals**:
- Complete all 6 sorries in Decidability module
- Build proof infrastructure incrementally (helper lemmas → check monotonicity → main theorems)
- Maintain clean builds with no new sorries introduced

**Non-Goals**:
- Refactoring existing definition structure (Strategy 1 avoids API changes)
- Changing the API of closure detection functions

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Proof sketches need adjustment | Low | Medium | Core approach verified; may need simp adjustments |
| `split_ifs` tactic interaction | Low | Low | Use `Option.isSome_iff_exists` first |
| FMP integration for Phase 4 | High | Medium | Focus on Phases 1-2 first |

## Implementation Phases

### Phase 1: Closure.lean - Helper Lemmas and Check Monotonicity [COMPLETED]

**Goal**: Implement all helper lemmas and check function monotonicity theorems

**Estimated effort**: 45 minutes

**Objectives**:
1. Add `hasNeg_mono`, `hasPos_mono`, `hasBotPos_mono` helper lemmas
2. Add `checkBotPos_mono`, `checkContradiction_mono`, `checkAxiomNeg_mono`

**Files to modify**:
- `Theories/Bimodal/Metalogic/Decidability/Closure.lean`

**Steps**:

1. **Add helper lemmas** (after the `hasNeg`/`hasPos`/`hasBotPos` definitions):

```lean
theorem hasNeg_mono (b : Branch) (x : SignedFormula) (φ : Formula) :
    Branch.hasNeg b φ → Branch.hasNeg (x :: b) φ := by
  intro h
  simp only [Branch.hasNeg, Branch.contains, List.any_cons]
  exact Or.inr h

theorem hasPos_mono (b : Branch) (x : SignedFormula) (φ : Formula) :
    Branch.hasPos b φ → Branch.hasPos (x :: b) φ := by
  intro h
  simp only [Branch.hasPos, Branch.contains, List.any_cons]
  exact Or.inr h

theorem hasBotPos_mono (b : Branch) (x : SignedFormula) :
    Branch.hasBotPos b → Branch.hasBotPos (x :: b) := by
  intro h
  simp only [Branch.hasBotPos, Branch.contains, List.any_cons]
  exact Or.inr h
```

2. **Add check function monotonicity** (after the check function definitions):

```lean
theorem checkBotPos_mono (b : Branch) (x : SignedFormula) :
    (checkBotPos b).isSome → (checkBotPos (x :: b)).isSome := by
  simp only [checkBotPos]
  intro h
  split_ifs at h ⊢
  · rfl
  · cases h
  · exact hasBotPos_mono b x ‹_›
  · cases h

theorem checkContradiction_mono (b : Branch) (x : SignedFormula) :
    (checkContradiction b).isSome → (checkContradiction (x :: b)).isSome := by
  intro h
  -- Extract the witness using findSome?_isSome_iff
  rw [checkContradiction, List.findSome?_isSome_iff] at h
  obtain ⟨sf, hsf_mem, hsf_cond⟩ := h
  -- Show the witness works for the extended branch
  rw [checkContradiction, List.findSome?_isSome_iff]
  refine ⟨sf, List.mem_cons_of_mem x hsf_mem, ?_⟩
  -- Show the condition still holds (with the new branch)
  simp only [Option.isSome_iff_exists] at hsf_cond ⊢
  obtain ⟨reason, hreason⟩ := hsf_cond
  split_ifs at hreason ⊢ with hcond hcond'
  · use reason
  · -- hcond was true in b, now false in (x :: b)? Impossible!
    obtain ⟨hpos, hneg⟩ := hcond
    have : Branch.hasNeg (x :: b) sf.formula := hasNeg_mono b x sf.formula hneg
    simp [hpos, this] at hcond'
  · cases hreason
  · cases hreason

theorem checkAxiomNeg_mono (b : Branch) (x : SignedFormula) :
    (checkAxiomNeg b).isSome → (checkAxiomNeg (x :: b)).isSome := by
  intro h
  rw [checkAxiomNeg, List.findSome?_isSome_iff] at h
  obtain ⟨sf, hsf_mem, hsf_cond⟩ := h
  rw [checkAxiomNeg, List.findSome?_isSome_iff]
  -- Witness still works: membership extends, condition is branch-independent
  exact ⟨sf, List.mem_cons_of_mem x hsf_mem, hsf_cond⟩
```

**Verification**:
- Use `lean_goal` to verify proof states at each step
- Each lemma should compile without sorry
- Run `lake build Bimodal.Metalogic.Decidability.Closure` to verify

---

### Phase 2: Closure.lean - Main Theorems [COMPLETED]

**Goal**: Complete `closed_extend_closed` and `add_neg_causes_closure`

**Estimated effort**: 45 minutes

**Objectives**:
1. Complete `closed_extend_closed` using check function monotonicity lemmas
2. Complete `add_neg_causes_closure` by witness construction

**Files to modify**:
- `Theories/Bimodal/Metalogic/Decidability/Closure.lean`

**Steps**:

1. **Complete `closed_extend_closed`**:

```lean
theorem closed_extend_closed (b : Branch) (sf : SignedFormula) :
    isClosed b → isClosed (sf :: b) := by
  intro h
  simp only [isClosed, findClosure] at h ⊢
  -- findClosure uses <|> so we case analyze on which check succeeds
  cases hbot : checkBotPos b with
  | some _ =>
    have := checkBotPos_mono b sf (by simp [hbot])
    simp [Option.isSome_iff_exists] at this
    obtain ⟨r, hr⟩ := this
    simp [hr]
  | none =>
    simp [hbot] at h
    cases hcontra : checkContradiction b with
    | some _ =>
      have := checkContradiction_mono b sf (by simp [hcontra])
      simp [Option.isSome_iff_exists] at this
      obtain ⟨r, hr⟩ := this
      simp [hr]
    | none =>
      simp [hcontra] at h
      cases hax : checkAxiomNeg b with
      | some _ =>
        have := checkAxiomNeg_mono b sf (by simp [hax])
        simp [Option.isSome_iff_exists] at this
        obtain ⟨r, hr⟩ := this
        simp [hr]
      | none =>
        simp [hbot, hcontra, hax] at h
```

2. **Complete `add_neg_causes_closure`**:

```lean
theorem add_neg_causes_closure (b : Branch) (φ : Formula) :
    Branch.hasPos b φ → isClosed (SignedFormula.neg φ :: b) := by
  intro hpos
  simp only [isClosed, findClosure]
  -- If checkBotPos succeeds, we're done. Otherwise, use checkContradiction.
  cases hbot : checkBotPos (SignedFormula.neg φ :: b) with
  | some _ => simp
  | none =>
    simp only [hbot, Option.none_or]
    -- checkContradiction will find the contradiction
    simp only [checkContradiction]
    rw [List.findSome?_isSome_iff]
    -- Extract witness from hasPos
    simp only [Branch.hasPos, Branch.contains, List.any_eq_true] at hpos
    obtain ⟨witness, hwit_mem, hwit_eq⟩ := hpos
    simp only [beq_iff_eq] at hwit_eq
    use witness
    constructor
    · exact List.mem_cons_of_mem (SignedFormula.neg φ) hwit_mem
    · -- witness.isPos ∧ (SignedFormula.neg φ :: b).hasNeg witness.formula
      simp only [Option.isSome_iff_exists]
      use ClosureReason.contradiction witness.formula
      rw [hwit_eq]
      simp only [SignedFormula.pos, SignedFormula.isPos, decide_eq_true_eq]
      split_ifs with h
      · rfl
      · exfalso
        apply h
        constructor
        · rfl
        · -- Need: (SignedFormula.neg φ :: b).hasNeg φ
          simp only [Branch.hasNeg, Branch.contains, List.any_cons]
          left
          simp [SignedFormula.neg]
```

**Verification**:
- `lake build Bimodal.Metalogic.Decidability.Closure` succeeds with no sorries
- Sorry count in Closure.lean: 2 → 0

---

### Phase 3: Saturation.lean - Termination Lemma [NOT STARTED]

**Goal**: Complete `expansion_decreases_measure` - the key termination lemma for tableau expansion

**Estimated effort**: 2 hours

**Objectives**:
1. Prove that applying a tableau rule decreases the `expansionMeasure`
2. Handle both `extended` (linear rule) and `split` (branching rule) cases

**Files to modify**:
- `Theories/Bimodal/Metalogic/Decidability/Saturation.lean`

**Steps**:
1. Review the `expansionMeasure` definition
2. Review `expandOnce` in Tableau.lean
3. Prove complexity decreases for each rule type
4. May need helper lemmas for formula complexity

**Verification**:
- `lake build Bimodal.Metalogic.Decidability.Saturation` succeeds with no sorries

---

### Phase 4: Correctness.lean - decide_axiom_valid [NOT STARTED]

**Goal**: Prove that axiom instances are correctly decided as valid

**Estimated effort**: 1 hour

**Objectives**:
1. Prove `decide_axiom_valid`: If phi is an axiom instance, decide returns valid

**Files to modify**:
- `Theories/Bimodal/Metalogic/Decidability/Correctness.lean`

**Steps**:
1. Read the `decide` function and `matchAxiom` in ProofSearch.lean
2. Prove `matchAxiom_correct` helper lemma
3. Complete `decide_axiom_valid`

**Verification**:
- `lake build Bimodal.Metalogic.Decidability.Correctness` compiles with this proof

---

### Phase 5: Correctness.lean - Completeness Theorems [NOT STARTED]

**Goal**: Complete `tableau_complete` and `decide_complete`

**Estimated effort**: 2 hours

**Objectives**:
1. Prove `tableau_complete`: Valid formulas have closing tableaux
2. Prove `decide_complete`: Decision procedure returns valid for valid formulas

**Files to modify**:
- `Theories/Bimodal/Metalogic/Decidability/Correctness.lean`

**Steps**:
1. Review FMP module structure
2. Prove `tableau_complete` using FMP and termination lemma
3. Prove `decide_complete` building on `tableau_complete`

**Verification**:
- `lake build Bimodal.Metalogic.Decidability.Correctness` succeeds with no sorries
- Full `lake build` passes

---

## Testing & Validation

- [ ] Phase 1: Helper lemmas and check monotonicity compile
- [ ] Phase 2: `lake build Bimodal.Metalogic.Decidability.Closure` - no sorries
- [ ] Phase 3: `lake build Bimodal.Metalogic.Decidability.Saturation` - no sorries
- [ ] Phase 4: decide_axiom_valid complete
- [ ] Phase 5: `lake build Bimodal.Metalogic.Decidability.Correctness` - no sorries
- [ ] Full `lake build` passes
- [ ] Sorry count in Decidability module: 6 → 0

## Artifacts & Outputs

- Completed proofs in:
  - `Theories/Bimodal/Metalogic/Decidability/Closure.lean`
  - `Theories/Bimodal/Metalogic/Decidability/Saturation.lean`
  - `Theories/Bimodal/Metalogic/Decidability/Correctness.lean`
- New helper lemmas:
  - hasNeg_mono, hasPos_mono, hasBotPos_mono
  - checkBotPos_mono, checkContradiction_mono, checkAxiomNeg_mono

## Rollback/Contingency

**For Phases 1-2** (Closure.lean): Now low risk with concrete proof sketches from research-003.md.

**For Phase 3** (Saturation): If termination proof is difficult:
1. Consider strengthening `expansionMeasure` definition
2. May need tracking of expanded formulas

**For Phases 4-5** (Correctness): If FMP integration proves too complex:
1. Mark completeness theorems as `axiom` with documentation
2. Focus on completing Phases 1-3 first
3. Create follow-up task for FMP integration
