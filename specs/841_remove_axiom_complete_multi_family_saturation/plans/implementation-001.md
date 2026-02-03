# Implementation Plan: Task #841

- **Task**: 841 - Remove axiom from task 827 via complete multi-family saturation construction
- **Status**: [PARTIAL]
- **Effort**: 18-24 hours
- **Dependencies**: Task #827 completed infrastructure
- **Research Inputs**: specs/841_remove_axiom_complete_multi_family_saturation/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**:
  - .claude/context/core/standards/plan.md
  - .claude/context/core/standards/status-markers.md
  - .claude/context/core/system/artifact-management.md
  - .claude/context/core/standards/tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This implementation removes the `singleFamily_modal_backward_axiom` from SaturatedConstruction.lean by constructing a provably saturated multi-family BMCS using well-founded recursion. The approach leverages the finite subformula closure to bound iteration count, enabling termination proof via Finset.card decrease.

### Research Integration

Key findings from research-001.md:
- Existing `closure_saturation_implies_modal_backward_for_closure` theorem proves modal_backward follows from saturation
- `constructWitnessFamily` and `diamond_implies_psi_consistent` provide witness construction primitives
- Termination measure: `(diamondSubformulas phi \ satisfiedDiamonds).card` strictly decreases
- Need `box_coherence` field for modal_forward to propagate across families

## Goals & Non-Goals

**Goals**:
- Remove `singleFamily_modal_backward_axiom` from SaturatedConstruction.lean
- Implement `saturateFamilies` with well-founded termination proof
- Prove `modal_forward` in FamilyCollection.toBMCS (add box_coherence field)
- Prove `modal_backward` in FamilyCollection.toBMCS using existing theorem
- Achieve sorry-free completeness path for closure formulas

**Non-Goals**:
- Full modal saturation for arbitrary formulas (only closure needed)
- Modifying existing proven theorems (reuse them)
- Eliminating the axiom in Construction.lean (only SaturatedConstruction.lean)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Termination proof complexity | High | Medium | Use Finset.strongInduction as fallback, proven pattern in Mathlib |
| Box coherence too restrictive | Medium | Low | Weaken to closure-restricted coherence if needed |
| Witness construction needs new lemmas | Medium | Medium | Reuse existing diamond_implies_psi_consistent |
| Integration breaks existing proofs | Low | Low | Add new construction, don't modify existing code |
| Type unification issues | Medium | Medium | Use explicit type annotations, lean_hover_info for debugging |

## Sorry Characterization

### Pre-existing Sorries
- `FamilyCollection.toBMCS.modal_forward` (SaturatedConstruction.lean:279)
- `FamilyCollection.toBMCS.modal_backward` (SaturatedConstruction.lean:284)

### Expected Resolution
- Phase 1 resolves modal_forward sorry via box_coherence field
- Phase 2 resolves modal_backward sorry via closure_saturation_implies_modal_backward_for_closure
- Phase 3 implements saturateFamilies with proven termination
- Phase 4 removes axiom via integration

### New Sorries
- None expected. If proof complexity requires temporary sorry, will document with remediation timeline.

### Remaining Debt
After this implementation:
- 0 sorries expected in FamilyCollection.toBMCS
- `singleFamily_modal_backward_axiom` removed from SaturatedConstruction.lean
- Axiom remains in Construction.lean (separate task scope)

## Implementation Phases

### Phase 1: Add box_coherence field to FamilyCollection [COMPLETED]

**Goal**: Extend FamilyCollection structure to track that boxed formulas propagate across all families, enabling modal_forward proof.

**Tasks**:
- [ ] Add `box_coherence` field to FamilyCollection structure with type:
  ```lean
  box_coherence : ∀ fam ∈ families, ∀ phi t,
    Formula.box phi ∈ fam.mcs t → ∀ fam' ∈ families, phi ∈ fam'.mcs t
  ```
- [ ] Verify FamilyCollection still compiles with new field
- [ ] Update `FamilyCollection.toBMCS.modal_forward` to use box_coherence field directly
- [ ] Run `lake build` to verify the sorry is eliminated

**Timing**: 2-3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SaturatedConstruction.lean` - FamilyCollection structure and toBMCS.modal_forward

**Verification**:
- `lake build` succeeds with no sorry in modal_forward
- FamilyCollection structure accepts the new field

---

### Phase 2: Prove modal_backward in toBMCS [IN PROGRESS]

**Goal**: Connect FamilyCollection.isSaturated to closure_saturation_implies_modal_backward_for_closure theorem.

**Tasks**:
- [ ] Analyze signature of `closure_saturation_implies_modal_backward_for_closure` for preconditions
- [ ] Verify that isSaturated implies the hypotheses needed for the theorem
- [ ] Add `closure_phi : Formula` parameter to FamilyCollection if needed to track which formula's closure is being saturated
- [ ] Implement modal_backward proof:
  ```lean
  modal_backward := fun fam hfam psi t h_all => by
    -- Apply closure_saturation_implies_modal_backward_for_closure
    -- Requires: psi ∈ subformulaClosure phi AND neg psi ∈ subformulaClosure phi
    -- For closure formulas, use closureWithNeg property
    sorry -- will be completed
  ```
- [ ] Handle case when psi is NOT in closure (may need to restrict or use different approach)
- [ ] Run `lake build` to verify compilation

**Timing**: 3-4 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SaturatedConstruction.lean` - FamilyCollection.toBMCS.modal_backward

**Verification**:
- `lake build` succeeds with no sorry in modal_backward
- Both preconditions (psi and neg psi in closure) are satisfied or handled

---

### Phase 3: Implement saturateFamilies with well-founded termination [NOT STARTED]

**Goal**: Create recursive function that iteratively adds witness families until saturation is achieved, with proven termination.

**Tasks**:
- [ ] Define helper `unsatisfiedDiamonds : FamilyCollection -> Finset Formula` that computes Diamond formulas in closure without witnesses
- [ ] Define `saturateFamilies` function skeleton:
  ```lean
  noncomputable def saturateFamilies (phi : Formula) (initial : FamilyCollection D phi)
      : FamilyCollection D phi :=
    if h : (unsatisfiedDiamonds initial).Nonempty then
      let diamond := h.choose
      let inner := extractDiamondInner diamond |>.get!
      -- ... construct witness, add to collection, recurse
      saturateFamilies phi new_collection
    else
      initial
  termination_by (unsatisfiedDiamonds initial).card
  ```
- [ ] Prove `diamond_implies_psi_consistent` applies to inner formula extracted from Diamond
- [ ] Implement witness construction using `constructWitnessFamily` or similar
- [ ] Create new FamilyCollection with witness added, preserving box_coherence
- [ ] Prove `decreasing_by` obligation using `Finset.card_erase_lt_of_mem`
- [ ] Prove the resulting collection is saturated (isSaturated holds at termination)
- [ ] Run `lake build` to verify termination and correctness

**Timing**: 8-10 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SaturatedConstruction.lean` - new saturateFamilies function

**Verification**:
- `lake build` succeeds without termination errors
- `saturateFamilies` returns a collection where `isSaturated` holds
- No `sorry` in the termination or recursive calls

---

### Phase 4: Integration and axiom removal [NOT STARTED]

**Goal**: Create complete construction pipeline and remove singleFamily_modal_backward_axiom.

**Tasks**:
- [ ] Create `initialFamilyCollection` that wraps a single family with trivial saturation
- [ ] Create `construct_saturated_bmcs` function:
  ```lean
  noncomputable def construct_saturated_bmcs (Gamma : List Formula)
      (h_cons : ContextConsistent Gamma) (phi : Formula) : BMCS D :=
    let initial := initialFamilyCollection phi (lindenbaumMCS Gamma h_cons) ...
    let saturated := saturateFamilies phi initial
    saturated.toBMCS (by exact saturateFamilies_isSaturated ...)
  ```
- [ ] Prove `construct_saturated_bmcs_contains_context` for completeness theorem
- [ ] Update any references from axiom-based construction to new construction
- [ ] Comment out or remove `singleFamily_modal_backward_axiom` declaration
- [ ] Run `lake build` to verify no references to removed axiom
- [ ] Verify completeness theorem still works with new construction

**Timing**: 3-4 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SaturatedConstruction.lean` - new functions, remove axiom
- Possibly `Theories/Bimodal/Metalogic/Bundle/Completeness.lean` if it references the axiom

**Verification**:
- Axiom declaration removed or commented
- `lake build` succeeds with no sorry in SaturatedConstruction.lean
- Completeness theorem compiles without the axiom

---

### Phase 5: Verification and cleanup [NOT STARTED]

**Goal**: Final verification that all sorries are eliminated and code is clean.

**Tasks**:
- [ ] Run `grep -r "sorry" Theories/Bimodal/Metalogic/Bundle/SaturatedConstruction.lean` - should return nothing
- [ ] Run `grep -r "axiom singleFamily" Theories/` - should return nothing
- [ ] Run full `lake build` to verify project compiles
- [ ] Review code for any remaining FIXMEs or TODOs
- [ ] Update module documentation to reflect new construction approach
- [ ] Document the mathematical approach in module header comment

**Timing**: 1-2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SaturatedConstruction.lean` - documentation updates

**Verification**:
- Zero sorry occurrences in SaturatedConstruction.lean
- Zero axiom declarations for modal_backward in active code
- Full `lake build` succeeds

## Testing & Validation

- [ ] `lake build` succeeds with no errors
- [ ] `grep -r "sorry" Theories/Bimodal/Metalogic/Bundle/SaturatedConstruction.lean` returns empty
- [ ] `grep -r "axiom singleFamily" Theories/` returns empty (or only in Boneyard/)
- [ ] Completeness theorem compiles without axiom reference
- [ ] All FamilyCollection operations preserve box_coherence invariant

## Artifacts & Outputs

- plans/implementation-001.md (this file)
- summaries/implementation-summary-YYYYMMDD.md (on completion)
- Modified file: Theories/Bimodal/Metalogic/Bundle/SaturatedConstruction.lean

## Rollback/Contingency

If implementation encounters blocking issues:
1. Keep axiom-based construction (`singleFamilyBMCS_withAxiom`) as fallback
2. Mark new construction as experimental with `#check` statements
3. Document specific blocker in implementation summary
4. Create follow-up task for resolving blocker

The existing axiom-based approach remains mathematically sound and can be preserved as an alternative if the termination proof becomes intractable.
