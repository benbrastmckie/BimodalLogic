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

### Phase 2: Prove modal_backward in toBMCS [COMPLETED]

**Goal**: Connect FamilyCollection saturation to modal_backward proof.

**Tasks**:
- [x] Analyze signature of `closure_saturation_implies_modal_backward_for_closure` for preconditions
- [x] Verify that isSaturated is insufficient - requires BOTH psi AND neg psi in closure
- [x] Define `FamilyCollection.isFullySaturated` - full saturation for ALL formulas
- [x] Implement modal_backward proof directly via contraposition:
  ```lean
  modal_backward := fun fam hfam psi t h_all => by
    -- Direct proof via contraposition, same logic as saturated_modal_backward
    by_contra h_not_box
    -- ... MCS negation completeness, box_dne_theorem, saturation gives witness
    -- Contradiction: psi in all families but neg psi in witness
  ```
- [x] Handle case when psi is NOT in closure - use isFullySaturated (full saturation)
- [x] Run `lake build` to verify compilation

**Timing**: 3-4 hours (actual: ~2 hours)

**Resolution Notes**:
The original plan used closure-restricted saturation `isSaturated`, but the contraposition
argument for `modal_backward` requires saturation for `neg psi` which may not be in closure.
Solution: Defined `isFullySaturated` (full saturation for all formulas) and updated `toBMCS`
to require this stronger condition. The proof then follows directly from the contraposition
argument used in `saturated_modal_backward`.

**Files modified**:
- `Theories/Bimodal/Metalogic/Bundle/SaturatedConstruction.lean`
  - Added `FamilyCollection.isFullySaturated` definition
  - Added `FamilyCollection.isFullySaturated_implies_isSaturated` theorem
  - Updated `FamilyCollection.toBMCS` to take `isFullySaturated` instead of `isSaturated`
  - Proved `modal_backward` completely (no sorry)

**Verification**:
- `lake build` succeeds with no sorry in modal_backward
- `grep -n "sorry" SaturatedConstruction.lean` returns only comments, no actual sorries

---

### Phase 3: Implement saturateFamilies with well-founded termination [PARTIAL]

**Goal**: Create recursive function that iteratively adds witness families until saturation is achieved, with proven termination.

**Tasks**:
- [x] Define helper predicates for tracking unsatisfied Diamond formulas
  - `isDiamondSatisfied`, `isDiamondUnsatisfied`, `unsatisfiedDiamondsPred`, `allDiamondsSatisfied`
- [x] Define `initialFamilyCollection` that wraps a single family with trivial saturation
- [x] Prove `witness_satisfies_diamond` - adding a witness satisfies the Diamond
- [ ] Define `saturateFamilies` recursive function
- [ ] Prove termination using well-founded recursion on candidate set
- [ ] Implement witness construction using `constructWitnessFamily`
- [ ] Prove box_coherence is preserved when adding witness families
- [ ] Prove the resulting collection achieves `isFullySaturated` (not just `isSaturated`)

**Key Design Decision**:
The original plan used `isSaturated` (closure-restricted saturation). However, Phase 2 established
that `FamilyCollection.toBMCS` requires `isFullySaturated` (full saturation for all formulas).
This significantly complicates Phase 3 because:
1. We need to saturate for ALL Diamond formulas, not just closure formulas
2. Termination argument is more complex (can't just use closure size)
3. May need to show witness families don't introduce new Diamond requirements

**Infrastructure Added**:
- `isDiamondSatisfied`, `isDiamondUnsatisfied` - check if a Diamond has a witness
- `unsatisfiedDiamondsPred` - predicate version of unsatisfied check (non-computable)
- `allDiamondsSatisfied` - all Diamonds in a candidate set are satisfied
- `witness_satisfies_diamond` - proves adding witness satisfies the Diamond
- `initialFamilyCollection` - creates a single-family collection with trivial box_coherence

**Timing**: 8-10 hours (estimated: 6 hours remaining for full implementation)

**Files modified**:
- `Theories/Bimodal/Metalogic/Bundle/SaturatedConstruction.lean`

**Verification**:
- [x] `lake build` succeeds (infrastructure compiles)
- [ ] `saturateFamilies` returns a collection where `isFullySaturated` holds
- [ ] No `sorry` in the termination or recursive calls

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
