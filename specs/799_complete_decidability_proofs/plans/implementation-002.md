# Implementation Plan: Task #799 (Revised)

- **Task**: 799 - Complete Decidability proofs
- **Status**: [NOT STARTED]
- **Version**: 002
- **Effort**: 7-8 hours
- **Dependencies**: None (builds on existing FMP infrastructure)
- **Research Inputs**:
  - specs/799_complete_decidability_proofs/reports/research-001.md (initial analysis)
  - specs/799_complete_decidability_proofs/reports/research-002.md (blockage diagnosis)
- **Artifacts**: plans/implementation-002.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Complete 6 remaining sorries in the Decidability module across three files. **Revision based on research-002.md**: Phase 1 was blocked because the proofs require a specific decomposition strategy using helper lemmas. The key insight is to work with witnesses rather than reasoning about `findSome?` directly.

### Key Changes from v001

1. **Phase 1 restructured**: Now includes explicit helper lemma steps before main theorems
2. **New proof strategy**: Use `List.findSome?_isSome_iff` to extract witnesses, then show they remain valid in extended lists
3. **Updated time estimates**: Phase 1 increased from 1.5 hours to 2.5 hours based on blockage analysis
4. **Added Phase 0**: Verification of required Mathlib lemmas before implementation

## Goals & Non-Goals

**Goals**:
- Complete all 6 sorries in Decidability module
- Build proof infrastructure incrementally (helper lemmas → main theorems)
- Maintain clean builds with no new sorries introduced

**Non-Goals**:
- Refactoring existing definition structure
- Changing the API of closure detection functions

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `List.findSome?_isSome_iff` not available | Medium | Low | Prove from first principles (~10 lines) |
| Helper lemmas more complex than expected | Low | Low | Strategy is well-understood from research |
| FMP integration for Phase 4 | High | Medium | Defer to later; focus on Phases 1-3 first |

## Implementation Phases

### Phase 0: Verify Prerequisites [NOT STARTED]

**Goal**: Verify required Mathlib lemmas exist and understand their signatures

**Estimated effort**: 15 minutes

**Objectives**:
1. Verify `List.any_of_mem` exists in Mathlib
2. Verify `List.mem_cons_of_mem` exists
3. Check if `List.findSome?_isSome_iff` exists or needs to be proved

**Steps**:
1. Use `lean_local_search` for `any_of_mem`
2. Use `lean_hover_info` to get exact signatures
3. If `findSome?_isSome_iff` missing, plan to prove it first

**Verification**:
- Document which lemmas exist vs need to be added

---

### Phase 1: Closure.lean Helper Lemmas [NOT STARTED]

**Goal**: Build the monotonicity infrastructure required for main theorems

**Estimated effort**: 1 hour

**Objectives**:
1. Prove `findSome?_isSome_iff` (if not in Mathlib)
2. Prove `hasNeg_mono`: `hasNeg b φ → hasNeg (x :: b) φ`
3. Prove `hasPos_mono`: `hasPos b φ → hasPos (x :: b) φ`
4. Prove `hasBotPos_mono`: `hasBotPos b → hasBotPos (x :: b)`

**Files to modify**:
- `Theories/Bimodal/Metalogic/Decidability/Closure.lean`

**Steps**:

1. **Add `findSome?_isSome_iff`** (if needed):
   ```lean
   theorem findSome?_isSome_iff {f : α → Option β} {l : List α} :
       (l.findSome? f).isSome ↔ ∃ a ∈ l, (f a).isSome := by
     induction l with
     | nil => simp [List.findSome?]
     | cons x xs ih =>
       simp only [List.findSome?]
       cases hf : f x with
       | none => simp [hf, ih, List.mem_cons, or_and_right, exists_or]
       | some b => simp [hf]
   ```

2. **Add `hasNeg_mono`**:
   ```lean
   theorem hasNeg_mono (b : Branch) (x : SignedFormula) (φ : Formula) :
       hasNeg b φ → hasNeg (x :: b) φ := by
     intro h
     simp only [hasNeg, List.any_cons]
     exact Or.inr h
   ```

3. **Add `hasPos_mono`** (same structure as `hasNeg_mono`)

4. **Add `hasBotPos_mono`**:
   ```lean
   theorem hasBotPos_mono (b : Branch) (x : SignedFormula) :
       hasBotPos b → hasBotPos (x :: b) := by
     intro h
     simp only [hasBotPos, List.any_cons]
     exact Or.inr h
   ```

**Verification**:
- Each helper lemma compiles without sorry
- Use `lean_goal` to verify proof states

---

### Phase 2: Closure.lean Check Function Monotonicity [NOT STARTED]

**Goal**: Prove monotonicity for `checkBotPos`, `checkContradiction`, `checkAxiomNeg`

**Estimated effort**: 1 hour

**Objectives**:
1. Prove `checkBotPos_mono`
2. Prove `checkContradiction_mono`
3. Prove `checkAxiomNeg_mono`

**Files to modify**:
- `Theories/Bimodal/Metalogic/Decidability/Closure.lean`

**Steps**:

1. **Add `checkBotPos_mono`**:
   ```lean
   theorem checkBotPos_mono (b : Branch) (x : SignedFormula) :
       (checkBotPos b).isSome → (checkBotPos (x :: b)).isSome := by
     intro h
     simp only [checkBotPos] at h ⊢
     -- Use hasBotPos_mono
     exact hasBotPos_mono b x (by simpa using h)
   ```

2. **Add `checkContradiction_mono`** (key theorem):
   ```lean
   theorem checkContradiction_mono (b : Branch) (x : SignedFormula) :
       (checkContradiction b).isSome → (checkContradiction (x :: b)).isSome := by
     intro h
     simp only [checkContradiction, findSome?_isSome_iff] at h ⊢
     obtain ⟨sf, hsf_mem, hsf_cond⟩ := h
     refine ⟨sf, List.mem_cons_of_mem x hsf_mem, ?_⟩
     simp only [Bool.and_eq_true] at hsf_cond ⊢
     obtain ⟨hpos, hneg⟩ := hsf_cond
     exact ⟨hpos, hasNeg_mono b x sf.formula hneg⟩
   ```

3. **Add `checkAxiomNeg_mono`** (similar to `checkContradiction_mono`)

**Verification**:
- `lake build Bimodal.Metalogic.Decidability.Closure` compiles

---

### Phase 3: Closure.lean Main Theorems [NOT STARTED]

**Goal**: Complete `closed_extend_closed` and `add_neg_causes_closure`

**Estimated effort**: 30 minutes

**Objectives**:
1. Complete `closed_extend_closed` using check function monotonicity lemmas
2. Complete `add_neg_causes_closure` by direct construction

**Files to modify**:
- `Theories/Bimodal/Metalogic/Decidability/Closure.lean` - Lines 175-195

**Steps**:

1. **Complete `closed_extend_closed`**:
   ```lean
   theorem closed_extend_closed (b : Branch) (sf : SignedFormula) :
       isClosed b → isClosed (sf :: b) := by
     intro h
     simp only [isClosed, findClosure] at h ⊢
     cases hbot : checkBotPos b with
     | some reason =>
       have := checkBotPos_mono b sf (by simp [hbot])
       simp [Option.isSome_iff_exists] at this
       obtain ⟨r, hr⟩ := this
       simp [List.findSome?_cons, hr]
     | none =>
       cases hcontra : checkContradiction b with
       | some reason =>
         have := checkContradiction_mono b sf (by simp [hcontra])
         -- Continue case analysis...
       | none =>
         cases hax : checkAxiomNeg b with
         | some reason => -- Use checkAxiomNeg_mono
         | none => simp [hbot, hcontra, hax] at h
   ```

2. **Complete `add_neg_causes_closure`**:
   ```lean
   theorem add_neg_causes_closure (b : Branch) (φ : Formula) :
       b.hasPos φ → isClosed (SignedFormula.neg φ :: b) := by
     intro hpos
     -- The negation at head creates contradiction with positive in body
     simp only [isClosed, findClosure]
     -- Direct construction showing checkContradiction finds the witness
     sorry -- Fill in details based on definition unfolding
   ```

**Verification**:
- `lake build Bimodal.Metalogic.Decidability.Closure` succeeds with no sorries
- Sorry count in Closure.lean: 2 → 0

---

### Phase 4: Saturation.lean Termination Lemma [NOT STARTED]

**Goal**: Complete `expansion_decreases_measure` - the key termination lemma for tableau expansion

**Estimated effort**: 2 hours

**Objectives**:
1. Prove that applying a tableau rule decreases the `expansionMeasure`
2. Handle both `extended` (linear rule) and `split` (branching rule) cases

**Files to modify**:
- `Theories/Bimodal/Metalogic/Decidability/Saturation.lean`

**Steps** (unchanged from v001):
1. Review the `expansionMeasure` definition
2. Review `expandOnce` in Tableau.lean
3. Prove complexity decreases for each rule type
4. May need helper lemmas for formula complexity

**Verification**:
- `lake build Bimodal.Metalogic.Decidability.Saturation` succeeds with no sorries

---

### Phase 5: Correctness.lean - decide_axiom_valid [NOT STARTED]

**Goal**: Prove that axiom instances are correctly decided as valid

**Estimated effort**: 1 hour

**Objectives**:
1. Prove `decide_axiom_valid`: If phi is an axiom instance, decide returns valid

**Files to modify**:
- `Theories/Bimodal/Metalogic/Decidability/Correctness.lean`

**Steps** (unchanged from v001):
1. Read the `decide` function and `matchAxiom` in ProofSearch.lean
2. Prove `matchAxiom_correct` helper lemma
3. Complete `decide_axiom_valid`

**Verification**:
- `lake build Bimodal.Metalogic.Decidability.Correctness` compiles with this proof

---

### Phase 6: Correctness.lean - Completeness Theorems [NOT STARTED]

**Goal**: Complete `tableau_complete` and `decide_complete`

**Estimated effort**: 2-3 hours

**Objectives**:
1. Prove `tableau_complete`: Valid formulas have closing tableaux
2. Prove `decide_complete`: Decision procedure returns valid for valid formulas

**Files to modify**:
- `Theories/Bimodal/Metalogic/Decidability/Correctness.lean`

**Steps** (unchanged from v001):
1. Review FMP module structure
2. Prove `tableau_complete` using FMP and termination lemma
3. Prove `decide_complete` building on `tableau_complete`

**Verification**:
- `lake build Bimodal.Metalogic.Decidability.Correctness` succeeds with no sorries
- Full `lake build` passes

---

## Testing & Validation

- [ ] Phase 0: Prerequisites verified
- [ ] Phase 1: Helper lemmas compile (hasNeg_mono, hasPos_mono, hasBotPos_mono)
- [ ] Phase 2: Check function monotonicity lemmas compile
- [ ] Phase 3: `lake build Bimodal.Metalogic.Decidability.Closure` - no sorries
- [ ] Phase 4: `lake build Bimodal.Metalogic.Decidability.Saturation` - no sorries
- [ ] Phase 5: decide_axiom_valid complete
- [ ] Phase 6: `lake build Bimodal.Metalogic.Decidability.Correctness` - no sorries
- [ ] Full `lake build` passes
- [ ] Sorry count in Decidability module: 6 → 0

## Artifacts & Outputs

- Completed proofs in:
  - `Theories/Bimodal/Metalogic/Decidability/Closure.lean`
  - `Theories/Bimodal/Metalogic/Decidability/Saturation.lean`
  - `Theories/Bimodal/Metalogic/Decidability/Correctness.lean`
- New helper lemmas:
  - findSome?_isSome_iff (if needed)
  - hasNeg_mono, hasPos_mono, hasBotPos_mono
  - checkBotPos_mono, checkContradiction_mono, checkAxiomNeg_mono

## Rollback/Contingency

**For Phases 1-3** (Closure.lean): Low risk with clear strategy from research-002.md.

**For Phase 4** (Saturation): If termination proof is difficult:
1. Consider strengthening `expansionMeasure` definition
2. May need tracking of expanded formulas

**For Phases 5-6** (Correctness): If FMP integration proves too complex:
1. Mark completeness theorems as `axiom` with documentation
2. Focus on completing Phases 1-4 first
3. Create follow-up task for FMP integration
