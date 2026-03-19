# Implementation Plan: Task #1003

- **Task**: 1003 - Implement Sorry-Free Multi-Family Modal Coherence
- **Status**: [NOT STARTED]
- **Effort**: 2.5 hours
- **Dependencies**: Task #1002 (completed design document)
- **Research Inputs**: specs/1003_implement_modal_coherence/reports/02_design-integration-research.md
- **Design Document**: specs/1002_design_modal_witness_infrastructure/reports/03_design-document.md
- **Artifacts**: plans/01_modal-coherence-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Implement the modal witness infrastructure designed in Task 1002 to achieve sorry-free proofs of `modal_forward` and `modal_backward` for the multi-family BFMCS over `CanonicalMCS`. The key insight is that witness MCSes constructed via Lindenbaum extension are automatically `CanonicalMCS` elements (no reachability requirement), enabling modal saturation by construction. The singleton bundle `{canonicalMCSBFMCS}` is already modally saturated because witness MCSes are CanonicalMCS elements.

### Research Integration

The design integration research verified:
- All infrastructure is sorry-free: `saturated_modal_backward`, `modal_witness_seed_consistent`, `lindenbaumMCS_set_extends`, `lindenbaumMCS_set_is_mcs`
- **One sorry to eliminate**: `MultiFamilyBFMCS.lean:277` in `singletonCanonicalBFMCS.modal_backward`
- The singleton bundle `{canonicalMCSBFMCS}` is inherently saturated because `CanonicalMCS` only requires `SetMaximalConsistent`

## Goals & Non-Goals

**Goals**:
- Eliminate the single sorry at `MultiFamilyBFMCS.lean:277`
- Create modular `ModalWitnessData.lean` structure per design document
- Create `SaturatedConstruction.lean` with saturation existence proof
- Wire saturated construction into `singletonCanonicalBFMCS`
- Pass `lake build` with no new sorries

**Non-Goals**:
- Refactoring unrelated modal code
- Adding multi-family support beyond singleton bundle
- Changing the public API of existing BFMCS infrastructure

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `lindenbaumMCS_set` API mismatch | M | L | Already verified API in research; use exact signatures |
| Proof term complexity | M | M | Use `saturated_modal_backward` directly (already sorry-free) |
| Import cycle | L | L | Follow existing module structure, add to Bundle/ directory |

## Implementation Phases

### Phase 1: Create ModalWitnessData.lean [NOT STARTED]

**Goal**: Define the `ModalWitnessData` structure and helper functions that encapsulate modal witness construction.

**Tasks**:
- [ ] Create file `Theories/Bimodal/Metalogic/Bundle/ModalWitnessData.lean`
- [ ] Import required modules: ChainFMCS, Construction, CanonicalFMCS
- [ ] Define `ModalWitnessData` structure per design document
- [ ] Implement `buildWitnessMCS` using `lindenbaumMCS_set`
- [ ] Prove `buildWitnessMCS_is_mcs` (delegates to `lindenbaumMCS_set_is_mcs`)
- [ ] Prove `buildWitnessMCS_contains_psi` (delegates to `lindenbaumMCS_set_extends`)
- [ ] Define `witnessAsCanonicalMCS` wrapper
- [ ] Prove `witnessAsCanonicalMCS_contains_psi`

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/ModalWitnessData.lean` - NEW (~40 lines)

**Verification**:
- `lake build ProofChecker.Theories.Bimodal.Metalogic.Bundle.ModalWitnessData`
- No sorries in file

---

### Phase 2: Create SaturatedConstruction.lean [NOT STARTED]

**Goal**: Prove that the singleton bundle `{canonicalMCSBFMCS}` is modally saturated.

**Tasks**:
- [ ] Create file `Theories/Bimodal/Metalogic/Bundle/SaturatedConstruction.lean`
- [ ] Import ModalWitnessData, ModalSaturation, CanonicalFMCS
- [ ] Prove `singleton_canonical_is_saturated : is_modally_saturated {canonicalMCSBFMCS}`
  - For Diamond(psi) in `canonicalMCSBFMCS.mcs t = t.world`
  - Build `ModalWitnessData` with `source_mcs = t.world`
  - Construct witness via `witnessAsCanonicalMCS`
  - Show psi is in `canonicalMCSBFMCS.mcs witness_t`
- [ ] Define `saturatedSingletonBFMCS : BFMCS CanonicalMCS` with saturation built-in
- [ ] Prove `saturatedSingletonBFMCS_modal_backward` using `saturated_modal_backward`

**Timing**: 60 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SaturatedConstruction.lean` - NEW (~70 lines)

**Verification**:
- `lake build ProofChecker.Theories.Bimodal.Metalogic.Bundle.SaturatedConstruction`
- No sorries in file
- `is_modally_saturated` proof completes

---

### Phase 3: Wire to MultiFamilyBFMCS.lean [NOT STARTED]

**Goal**: Replace the sorry in `singletonCanonicalBFMCS.modal_backward` with the saturated construction.

**Tasks**:
- [ ] Add import for SaturatedConstruction.lean to MultiFamilyBFMCS.lean
- [ ] Replace `singletonCanonicalBFMCS` definition to use `saturatedSingletonBFMCS`
- [ ] Remove the sorry at line 277
- [ ] Verify `singletonCanonicalBFMCS` still has same type signature

**Timing**: 20 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/MultiFamilyBFMCS.lean` - UPDATE (~15 lines changed)

**Verification**:
- `lake build ProofChecker.Theories.Bimodal.Metalogic.Algebraic.MultiFamilyBFMCS`
- Sorry count decreased by 1 in this file

---

### Phase 4: Final Verification [NOT STARTED]

**Goal**: Verify complete build passes and sorry count has decreased.

**Tasks**:
- [ ] Run full `lake build`
- [ ] Count sorries: `grep -r "sorry" Theories/Bimodal/ --include="*.lean" | wc -l`
- [ ] Verify no regressions in dependent modules
- [ ] Update module lakefile if needed (add new files to build)

**Timing**: 15 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle.lean` - ADD imports for new files

**Verification**:
- `lake build` passes with no errors
- Sorry count is one less than before implementation
- No sorry in MultiFamilyBFMCS.lean:277

## Testing & Validation

- [ ] `lake build` passes with no errors
- [ ] `grep -c "sorry" Theories/Bimodal/Metalogic/Algebraic/MultiFamilyBFMCS.lean` returns 0
- [ ] New files have no sorries: `grep -c "sorry" Theories/Bimodal/Metalogic/Bundle/ModalWitnessData.lean`
- [ ] New files have no sorries: `grep -c "sorry" Theories/Bimodal/Metalogic/Bundle/SaturatedConstruction.lean`
- [ ] `lean_verify` on key theorems: `singleton_canonical_is_saturated`, `saturatedSingletonBFMCS_modal_backward`

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Bundle/ModalWitnessData.lean` - Modal witness infrastructure
- `Theories/Bimodal/Metalogic/Bundle/SaturatedConstruction.lean` - Saturation proof
- `Theories/Bimodal/Metalogic/Algebraic/MultiFamilyBFMCS.lean` - Updated (sorry eliminated)
- `specs/1003_implement_modal_coherence/summaries/01_modal-coherence-summary.md` - Completion summary

## Rollback/Contingency

If implementation encounters blockers:
1. Preserve partial progress in new files (they are additive)
2. Do not modify MultiFamilyBFMCS.lean until Phase 3 succeeds
3. The sorry remains if new proofs are incomplete; no regression
4. Fall back to alternative: inline the witness construction directly in MultiFamilyBFMCS.lean

## Key Code Patterns

### ModalWitnessData Structure (Phase 1)
```lean
structure ModalWitnessData where
  inner_formula : Formula
  source_mcs : Set Formula
  source_is_mcs : SetMaximalConsistent source_mcs
  diamond_mem : inner_formula.diamond ∈ source_mcs
```

### Saturation Proof Pattern (Phase 2)
```lean
theorem singleton_canonical_is_saturated :
    is_modally_saturated ({canonicalMCSBFMCS} : Set (FMCS CanonicalMCS)) := by
  intro fam hfam t psi h_diamond
  simp at hfam; subst hfam
  -- Build witness using ModalWitnessData
  let w : ModalWitnessData := ⟨psi, t.world, t.is_mcs, h_diamond⟩
  let witness_t := witnessAsCanonicalMCS w
  use canonicalMCSBFMCS, Set.mem_singleton _
  exact witnessAsCanonicalMCS_contains_psi w
```

### Wiring Pattern (Phase 3)
```lean
noncomputable def singletonCanonicalBFMCS : BFMCS CanonicalMCS :=
  saturatedSingletonBFMCS
```
