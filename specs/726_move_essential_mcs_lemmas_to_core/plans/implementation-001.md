# Implementation Plan: Task #726

- **Task**: 726 - Move essential MCS lemmas to Core
- **Status**: [IMPLEMENTING]
- **Effort**: 4-5 hours
- **Priority**: High
- **Dependencies**: None (subtask of Task 722)
- **Research Inputs**: specs/726_move_essential_mcs_lemmas_to_core/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Move 5 essential MCS lemmas from `Boneyard/Metalogic/Completeness.lean` to `Metalogic/Core/` to eliminate Boneyard imports from the active codebase. The lemmas (`set_mcs_closed_under_derivation`, `set_mcs_implication_property`, `set_mcs_negation_complete`, `set_mcs_all_future_all_future`, `set_mcs_all_past_all_past`) depend on `deduction_theorem` which must also be moved. All moved code requires provenance comments documenting Boneyard origins.

### Research Integration

- Research report identified current import pattern where 3 active files import from Boneyard
- Recommended creating `Core/DeductionTheorem.lean` and `Core/MCSProperties.lean`
- Identified dependency chain: `deduction_theorem` -> `set_mcs_closed_under_derivation` -> other 4 lemmas
- `temp_4_past` helper lemma also needed for `set_mcs_all_past_all_past`

## Goals & Non-Goals

**Goals**:
- Eliminate all Boneyard imports from `Metalogic/Representation/` files
- Add provenance comments to all moved lemmas documenting original Boneyard location
- Maintain clean import hierarchy: `DeductionTheorem` -> `MCSProperties` -> consumers
- Ensure `lake build` passes after each phase

**Non-Goals**:
- Refactoring or simplifying the moved proofs (copy verbatim)
- Removing the original Boneyard definitions (they remain as historical reference)
- Moving lemmas beyond the 5 essential ones specified
- Consolidating `Metalogic/Core/MaximalConsistent.lean` into MCSProperties (separate task)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Circular import from `DeductionTheorem` | High | Medium | Careful dependency ordering; DeductionTheorem only imports ProofSystem |
| Namespace conflicts between Boneyard and Core | Medium | Low | Use explicit `Bimodal.Metalogic.Core` namespace |
| Build failures from missing dependencies | Medium | Medium | Verify imports at each phase; run `lake build` incrementally |
| Helper lemmas not copied | Medium | Medium | Copy `derivation_exchange`, `cons_filter_neq_perm`, `derives_bot_from_phi_neg_phi`, `temp_4_past` |

## Implementation Phases

### Phase 1: Create Core/DeductionTheorem.lean [COMPLETED]

**Goal**: Copy deduction theorem and helper lemmas from Boneyard with provenance comments

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/Core/DeductionTheorem.lean`
- [ ] Add module docstring explaining purpose and origin
- [ ] Copy `deduction_theorem` from `Boneyard/Metalogic_v2/Core/DeductionTheorem.lean`
- [ ] Copy all helper lemmas: `weaken_under_imp`, `weaken_under_imp_ctx`, `exchange`, `removeAll`, `removeAll_subset`, `cons_removeAll_perm`, `deduction_axiom`, `deduction_assumption_same`, `deduction_assumption_other`, `deduction_mp`, `deduction_with_mem`
- [ ] Add provenance comments: `-- Origin: Boneyard/Metalogic_v2/Core/DeductionTheorem.lean`
- [ ] Verify imports match: `Bimodal.ProofSystem.Derivation`, `Bimodal.Theorems.Combinators`
- [ ] Run `lake build Bimodal.Metalogic.Core.DeductionTheorem`

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Core/DeductionTheorem.lean` - create new

**Verification**:
- File compiles with no errors
- `deduction_theorem` accessible as `Bimodal.Metalogic.Core.deduction_theorem`

---

### Phase 2: Create Core/MCSProperties.lean [COMPLETED]

**Goal**: Copy the 5 essential MCS lemmas with provenance comments

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/Core/MCSProperties.lean`
- [ ] Add imports: `Bimodal.Metalogic.Core.DeductionTheorem`, `Bimodal.Metalogic.Core.MaximalConsistent`
- [ ] Copy helper `derivation_exchange` from `Boneyard/Metalogic/Completeness.lean` (line ~560)
- [ ] Copy helper `cons_filter_neq_perm` from `Boneyard/Metalogic/Completeness.lean` (line ~540)
- [ ] Copy `set_mcs_closed_under_derivation` (line 577) with provenance comment
- [ ] Copy `set_mcs_implication_property` (line 655) with provenance comment
- [ ] Copy `set_mcs_negation_complete` (line 679) with provenance comment
- [ ] Copy helper `temp_4_past` (line 1079) with provenance comment
- [ ] Copy `set_mcs_all_future_all_future` (line 1055) with provenance comment
- [ ] Copy `set_mcs_all_past_all_past` (line 1115) with provenance comment
- [ ] Add module docstring explaining purpose
- [ ] Run `lake build Bimodal.Metalogic.Core.MCSProperties`

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Core/MCSProperties.lean` - create new

**Verification**:
- File compiles with no errors
- All 5 lemmas accessible in `Bimodal.Metalogic.Core` namespace

---

### Phase 3: Update Core/Core.lean module re-export [COMPLETED]

**Goal**: Add new modules to Core re-export

**Tasks**:
- [ ] Edit `Theories/Bimodal/Metalogic/Core/Core.lean`
- [ ] Add `import Bimodal.Metalogic.Core.DeductionTheorem`
- [ ] Add `import Bimodal.Metalogic.Core.MCSProperties`
- [ ] Run `lake build Bimodal.Metalogic.Core`

**Timing**: 15 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Core/Core.lean` - add imports

**Verification**:
- Core module compiles
- Downstream `Metalogic.Core` imports get new lemmas

---

### Phase 4: Update IndexedMCSFamily.lean imports [COMPLETED]

**Goal**: Replace Boneyard import with Core import in IndexedMCSFamily

**Tasks**:
- [ ] Edit `Theories/Bimodal/Metalogic/Representation/IndexedMCSFamily.lean`
- [ ] Remove `import Bimodal.Boneyard.Metalogic.Completeness`
- [ ] Add `import Bimodal.Metalogic.Core.MCSProperties` (or rely on Core re-export)
- [ ] Update any explicit namespace references from `Bimodal.Boneyard.Metalogic` to `Bimodal.Metalogic.Core`
- [ ] Run `lake build Bimodal.Metalogic.Representation.IndexedMCSFamily`

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Representation/IndexedMCSFamily.lean` - update imports

**Verification**:
- File compiles with no errors
- No Boneyard imports remain in this file

---

### Phase 5: Update CoherentConstruction.lean imports [COMPLETED]

**Goal**: Replace Boneyard import with Core import in CoherentConstruction

**Tasks**:
- [ ] Edit `Theories/Bimodal/Metalogic/Representation/CoherentConstruction.lean`
- [ ] Remove `import Bimodal.Boneyard.Metalogic.Completeness`
- [ ] Remove comment on line 69 about Boneyard import
- [ ] Add `import Bimodal.Metalogic.Core.MCSProperties` if needed
- [ ] Update namespace references from `Bimodal.Boneyard.Metalogic` to `Bimodal.Metalogic.Core`
- [ ] Run `lake build Bimodal.Metalogic.Representation.CoherentConstruction`

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Representation/CoherentConstruction.lean` - update imports

**Verification**:
- File compiles with no errors
- No Boneyard imports remain in this file

---

### Phase 6: Verify and update documentation [NOT STARTED]

**Goal**: Update README and verify complete build

**Tasks**:
- [ ] Run full `lake build` to verify project compiles
- [ ] Edit `Theories/Bimodal/Metalogic/README.md` to reflect new Core structure
- [ ] Add section documenting Core module components:
  - `MaximalConsistent.lean` - MCS definitions (re-exported from Boneyard)
  - `DeductionTheorem.lean` - Deduction theorem infrastructure
  - `MCSProperties.lean` - Essential MCS lemmas for Representation layer
- [ ] Verify no active files import from Boneyard (grep check)
- [ ] Update `Metalogic/Core/Core.lean` docstring if needed

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/README.md` - update documentation
- `Theories/Bimodal/Metalogic/Core/Core.lean` - update docstring

**Verification**:
- `lake build` succeeds
- `grep -r "Boneyard" Theories/Bimodal/Metalogic/Representation/` returns no matches
- README accurately describes Core structure

---

## Testing & Validation

- [ ] `lake build` completes successfully after each phase
- [ ] All 5 essential lemmas accessible from `Bimodal.Metalogic.Core`
- [ ] No active files in `Metalogic/Representation/` import from Boneyard
- [ ] Provenance comments present on all moved lemmas
- [ ] README documentation updated to reflect new Core structure

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Core/DeductionTheorem.lean` - new file
- `Theories/Bimodal/Metalogic/Core/MCSProperties.lean` - new file
- `Theories/Bimodal/Metalogic/Core/Core.lean` - modified imports
- `Theories/Bimodal/Metalogic/Representation/IndexedMCSFamily.lean` - updated imports
- `Theories/Bimodal/Metalogic/Representation/CoherentConstruction.lean` - updated imports
- `Theories/Bimodal/Metalogic/README.md` - updated documentation

## Rollback/Contingency

If implementation fails:
1. Remove newly created files (`DeductionTheorem.lean`, `MCSProperties.lean`)
2. Revert `Core.lean` import additions
3. Restore Boneyard imports in Representation files
4. Git revert to pre-implementation state

The Boneyard files remain unchanged throughout, so original functionality is always available as fallback.
