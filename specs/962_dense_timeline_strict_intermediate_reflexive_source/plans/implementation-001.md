# Implementation Plan: Task #962 (v001)

- **Task**: 962 - dense_timeline_strict_intermediate_reflexive_source
- **Status**: [COMPLETED]
- **Effort**: 2.5 hours
- **Dependencies**: Task 957 (completed - density_frame_condition theorem)
- **Research Inputs**: specs/962_dense_timeline_strict_intermediate_reflexive_source/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Modify `DenseTimeline.lean` to use `density_frame_condition_reflexive_source` when the source MCS is reflexive. This guarantees the intermediate is strictly ordered from the target (never equal to target in the quotient), fixing the root cause that blocks task 961. The change requires moving `density_frame_condition_reflexive_source` and its helper from `CantorApplication.lean` to `DensityFrameCondition.lean` to avoid circular imports.

### Research Integration

- **research-001.md**: Confirmed the root cause (Case B1 can return endpoint MCS), identified solution (use reflexive-source variant), and documented the import structure issue requiring lemma relocation.

## Goals & Non-Goals

**Goals**:
- Modify `densityIntermediateMCS` to dispatch to reflexive-source variant when source is reflexive
- Provide new spec lemma `densityIntermediateMCS_strict_from_target` for strictness property
- Update existing `densityIntermediateMCS_spec` to handle both branches
- Move required lemmas to avoid circular imports
- Unblock task 961 by providing strictness guarantees at the timeline level

**Non-Goals**:
- Proving strictness from source side (not provided by Case A construction)
- Modifying downstream theorems in CantorApplication.lean (separate task)
- Completing the `strict_intermediate_exists` theorem (task 961)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Proof complexity from `dif_pos`/`dif_neg` handling | Medium | Medium | Use `simp only [densityIntermediateMCS]` then `split` tactic pattern |
| Import cycle when moving lemmas | High | Low | Move `density_frame_condition_caseA_strict` and `density_frame_condition_reflexive_source` BEFORE modifying DenseTimeline.lean |
| Breaking downstream proofs | Medium | Low | Preserve exact signatures of existing spec lemmas |
| Type mismatch in if-then-else branches | Medium | Medium | Ensure both branches return `Set Formula` with same choose pattern |

## Sorry Characterization

### Pre-existing Sorries
- 1 sorry in `CantorApplication.lean` at line 367 (`strict_intermediate_exists` theorem)

### Expected Resolution
- This task does NOT resolve the sorry - it provides infrastructure for task 961 to resolve it
- The sorry at line 367 requires the strictness property that this task enables

### New Sorries
- None. NEVER introduce new sorries. If proof cannot be completed:
  - Mark phase [BLOCKED] with requires_user_review: true
  - User decides: revise plan, split task, or change approach
  - DO NOT use sorry and mark task complete

### Remaining Debt
After this implementation:
- 1 sorry remains in `CantorApplication.lean` (to be addressed by task 961)
- The sorry becomes provable using the new `densityIntermediateMCS_strict_from_target` lemma

## Implementation Phases

### Phase 1: Move Strict Density Lemmas [COMPLETED]

- **Dependencies:** None
- **Goal:** Relocate `density_frame_condition_caseA_strict` and `density_frame_condition_reflexive_source` from CantorApplication.lean to DensityFrameCondition.lean to avoid circular import

**Tasks:**
- [ ] Read CantorApplication.lean lines 250-305 to identify exact lemma boundaries
- [ ] Copy `density_frame_condition_caseA_strict` theorem (lines 257-282) to DensityFrameCondition.lean
- [ ] Copy `density_frame_condition_reflexive_source` theorem (lines 284-304) to DensityFrameCondition.lean
- [ ] Verify both theorems compile in new location with `lake build`
- [ ] Remove the original definitions from CantorApplication.lean
- [ ] Verify CantorApplication.lean still compiles (now imports the lemmas)

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/DensityFrameCondition.lean` - Add strict lemmas
- `Theories/Bimodal/Metalogic/StagedConstruction/CantorApplication.lean` - Remove moved lemmas

**Verification**:
- `lake build Bimodal.Metalogic.StagedConstruction.DensityFrameCondition` passes
- `lake build Bimodal.Metalogic.StagedConstruction.CantorApplication` passes
- `grep -n "density_frame_condition_reflexive_source" DensityFrameCondition.lean` shows definition present
- `grep -n "density_frame_condition_caseA_strict" DensityFrameCondition.lean` shows definition present

---

### Phase 2: Modify densityIntermediateMCS [COMPLETED]

- **Dependencies:** Phase 1
- **Goal:** Update `densityIntermediateMCS` to use reflexive-source variant when applicable

**Tasks:**
- [ ] Modify `densityIntermediateMCS` definition to use if-then-else based on `CanonicalR a.mcs a.mcs`
- [ ] Use `dite` pattern (if h : P then ... else ...) for decidable reflexivity check
- [ ] Verify reflexive branch calls `density_frame_condition_reflexive_source.choose`
- [ ] Verify non-reflexive branch calls `density_frame_condition.choose` (unchanged)
- [ ] Compile with `lake build` to verify syntax

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/DenseTimeline.lean` - Update definition

**Verification**:
- Definition compiles without errors
- Type is still `Set Formula` (unchanged)
- `lean_goal` at definition shows no red squiggles

---

### Phase 3: Update densityIntermediateMCS_spec [COMPLETED]

- **Dependencies:** Phase 2
- **Goal:** Update the base spec lemma to handle both branches while preserving its signature

**Tasks:**
- [ ] Modify proof to use `simp only [densityIntermediateMCS]` to unfold definition
- [ ] Use `split` tactic to handle both if-branches
- [ ] In reflexive case: extract `.choose_spec` from `density_frame_condition_reflexive_source` and project to first 3 components
- [ ] In non-reflexive case: use original `density_frame_condition.choose_spec`
- [ ] Verify proof compiles and type signature unchanged

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/DenseTimeline.lean` - Update proof

**Verification**:
- `lake build` passes
- Signature remains: `SetMaximalConsistent _ /\ CanonicalR a.mcs _ /\ CanonicalR _ b.mcs`
- `lean_goal` at theorem shows "no goals" at end of proof

---

### Phase 4: Add Strictness Lemma [COMPLETED]

- **Dependencies:** Phase 2
- **Goal:** Add new `densityIntermediateMCS_strict_from_target` lemma exposing strictness when source is reflexive

**Tasks:**
- [ ] Add theorem `densityIntermediateMCS_strict_from_target` with signature taking reflexivity hypothesis
- [ ] Proof: `simp only [densityIntermediateMCS, dif_pos h_refl]`
- [ ] Extract `.choose_spec.2.2.2` from `density_frame_condition_reflexive_source`
- [ ] Verify the negated CanonicalR property is returned
- [ ] Add corresponding helper for `densityIntermediatePoint` level if needed

**Timing**: 20 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/DenseTimeline.lean` - Add new lemma

**Verification**:
- `lake build` passes
- Signature is: `negCanonicalR b.mcs (densityIntermediateMCS a b h_R h_not_R)` (given `h_refl : CanonicalR a.mcs a.mcs`)
- `lean_goal` at theorem shows "no goals"

---

### Phase 5: Verify Downstream Compatibility [COMPLETED]

- **Dependencies:** Phase 3, Phase 4
- **Goal:** Ensure all downstream theorems still compile

**Tasks:**
- [ ] Run full `lake build` to check all downstream dependencies
- [ ] Check `dense_timeline_has_intermediate` still compiles (uses densityIntermediateMCS_spec)
- [ ] Check `densityIntermediatePoint_canonicalR_left/right` still work
- [ ] Check `CantorApplication.lean` compiles (should now have access to strictness)
- [ ] Verify no new sorries introduced with `grep -rn "\bsorry\b" DenseTimeline.lean`

**Timing**: 25 minutes

**Files to modify**:
- None (verification only)

**Verification**:
- `lake build` passes with no errors
- `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/StagedConstruction/DenseTimeline.lean` returns empty
- `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/StagedConstruction/DensityFrameCondition.lean` returns empty
- Count of sorries in CantorApplication.lean unchanged (1 sorry at line 367)

---

### Phase 6: Final Verification [COMPLETED]

- **Dependencies:** Phase 5
- **Goal:** Confirm implementation is complete and correct

**Tasks:**
- [ ] Run `lake build` on entire project
- [ ] Verify no new axioms: `grep -n "^axiom " DenseTimeline.lean` returns empty
- [ ] Verify no sorries in modified files
- [ ] Confirm strictness lemma is available for task 961

**Timing**: 15 minutes

**Files to modify**:
- None (verification only)

**Verification**:
- `lake build` passes
- `grep -rn "\bsorry\b" DenseTimeline.lean DensityFrameCondition.lean` returns empty
- `grep -n "^axiom " DenseTimeline.lean DensityFrameCondition.lean` returns empty
- All proofs verified with `lean_goal` showing "no goals"

## Testing & Validation

### For Lean Tasks (Required)
- [ ] `lake build` passes with no errors
- [ ] `grep -rn "\bsorry\b" DenseTimeline.lean DensityFrameCondition.lean` returns empty (zero-debt gate)
- [ ] `grep -n "^axiom " DenseTimeline.lean DensityFrameCondition.lean` shows no new axioms
- [ ] All proofs verified with `lean_goal` showing "no goals"

### Specific Checks
- [ ] `densityIntermediateMCS_spec` signature unchanged
- [ ] `densityIntermediateMCS_strict_from_target` provides `negCanonicalR` property
- [ ] `densityIntermediatePoint_canonicalR_left/right` still work unchanged
- [ ] `dense_timeline_has_intermediate` still compiles
- [ ] CantorApplication.lean compiles and imports the strict lemmas

## Artifacts & Outputs

- `specs/962_dense_timeline_strict_intermediate_reflexive_source/plans/implementation-001.md` (this file)
- Modified: `Theories/Bimodal/Metalogic/StagedConstruction/DensityFrameCondition.lean`
- Modified: `Theories/Bimodal/Metalogic/StagedConstruction/DenseTimeline.lean`
- Modified: `Theories/Bimodal/Metalogic/StagedConstruction/CantorApplication.lean`
- `specs/962_dense_timeline_strict_intermediate_reflexive_source/summaries/implementation-summary-{DATE}.md` (on completion)

## Rollback/Contingency

If implementation fails:
1. Revert changes to DensityFrameCondition.lean (remove added lemmas)
2. Revert changes to DenseTimeline.lean (restore original definitions)
3. Revert changes to CantorApplication.lean (restore moved lemmas)
4. All changes are in git, so `git checkout -- <files>` reverts

If Phase 1 (lemma relocation) creates unexpected import issues:
- Alternative: Create new intermediate file `DensityFrameConditionStrict.lean` imported by both
- This avoids modifying the existing DensityFrameCondition.lean structure
