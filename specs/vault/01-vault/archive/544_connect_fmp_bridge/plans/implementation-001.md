# Implementation Plan: Task #544

- **Task**: 544 - Connect FMP Bridge (Phase 3 of 540)
- **Status**: [NOT STARTED]
- **Effort**: 1 hour
- **Priority**: High
- **Dependencies**: 542 (completed), 543 (completed)
- **Research Inputs**: specs/544_connect_fmp_bridge/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Establish FiniteModelProperty.lean as the bridge module connecting the proven semantic completeness infrastructure (from FiniteCanonicalModel.lean) to the decidability and compactness modules. The research identified that the semantic canonical model approach has proven core results (`semantic_weak_completeness`), making it the preferred foundation. Key work involves fixing imports, defining a proper FMP statement using SemanticCanonicalModel structures, and connecting to the Decidability module.

### Research Integration

From research-001.md:
- The `semantic_weak_completeness` theorem in FiniteCanonicalModel.lean is proven and provides the core completeness result
- `SemanticCanonicalFrame` and `SemanticCanonicalModel` structures are well-defined with Fintype properties
- Mathlib's `Fintype.decidableExistsFintype` enables decidability once FMP is established
- The filtration approach has sorry gaps; prefer the semantic approach

## Goals & Non-Goals

**Goals**:
- Fix FiniteModelProperty.lean to compile without import errors
- Define FMP statement using proven SemanticCanonicalModel infrastructure
- Connect FMP to the Decidability module via Fintype decidability
- Enable downstream modules (Compactness, CompletenessTheorem) to use FMP

**Non-Goals**:
- Proving all sorry gaps in FiniteModelProperty.lean (only focus on core FMP)
- Implementing filtration-based FMP (use semantic approach instead)
- Modifying the Decidability tableau implementation

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Import cycles between Representation and Completeness modules | Build failure | Medium | Audit imports; use forward declarations if needed |
| Type mismatches between SemanticWorldState and existing FMP signatures | Type errors | Medium | Adapt signatures to use SemanticCanonicalModel types |
| Decidability connection complexity | Extended timeline | Low | Use Classical.dec for initial proof; optimize later |

## Implementation Phases

### Phase 1: Fix FiniteModelProperty.lean Imports [COMPLETED]

**Goal**: Get FiniteModelProperty.lean to compile by fixing import references and removing broken dependencies.

**Tasks**:
- [ ] Audit current imports in FiniteModelProperty.lean
- [ ] Fix import path to reference Completeness/FiniteCanonicalModel.lean correctly
- [ ] Remove or update broken references to CanonicalModel, CompletenessTheorem
- [ ] Ensure SemanticCanonicalFrame and SemanticCanonicalModel are accessible
- [ ] Run `lake build` to verify compilation

**Timing**: 20 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Representation/FiniteModelProperty.lean` - Fix imports

**Verification**:
- `lake build Theories.Bimodal.Metalogic.Representation.FiniteModelProperty` compiles without import errors
- All referenced types from FiniteCanonicalModel.lean resolve

---

### Phase 2: Define FMP Statement Using Semantic Approach [COMPLETED]

**Goal**: Define the Finite Model Property theorem using the proven SemanticCanonicalModel infrastructure.

**Tasks**:
- [ ] Add proper FMP theorem statement connecting `formula_satisfiable` to finite SemanticWorldState
- [ ] Implement `finite_model_property` using contrapositive of `semantic_weak_completeness`
- [ ] Add `semantic_world_state_finite` Fintype instance (if not already present)
- [ ] Add model size bound theorem using `Finset.card_powerset`
- [ ] Verify FMP compiles (may have sorry for non-trivial proofs)

**Timing**: 25 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Representation/FiniteModelProperty.lean` - Add FMP theorems

**Verification**:
- `finite_model_property` theorem statement type-checks
- `semantic_world_state_finite` Fintype instance compiles
- No additional import errors introduced

---

### Phase 3: Connect to Decidability Module [COMPLETED]

**Goal**: Bridge FMP to the Decidability module to enable `satisfiability_decidable`.

**Tasks**:
- [ ] Add `satisfiability_decidable` theorem using `Fintype.decidableExistsFintype`
- [ ] Update Decidability/Correctness.lean `tableau_complete` to reference FMP
- [ ] Verify cross-module imports work correctly
- [ ] Add exports to parent Metalogic.lean if needed

**Timing**: 15 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Representation/FiniteModelProperty.lean` - Add decidability theorem
- `Theories/Bimodal/Metalogic/Decidability/Correctness.lean` - Add FMP reference comment
- `Theories/Bimodal/Metalogic.lean` - Verify exports (optional)

**Verification**:
- `satisfiability_decidable` theorem compiles (may have sorry)
- No import cycles between modules
- `lake build Theories.Bimodal.Metalogic` succeeds

---

## Testing & Validation

- [ ] `lake build Theories.Bimodal.Metalogic.Representation.FiniteModelProperty` succeeds
- [ ] `lake build Theories.Bimodal.Metalogic` succeeds (full module)
- [ ] No new compilation errors in downstream modules
- [ ] FMP theorem signatures match expected types from research

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Representation/FiniteModelProperty.lean` (modified)
- `Theories/Bimodal/Metalogic/Decidability/Correctness.lean` (minor update)
- `specs/544_connect_fmp_bridge/summaries/implementation-summary-YYYYMMDD.md` (on completion)

## Rollback/Contingency

If implementation introduces breaking changes:
1. Revert FiniteModelProperty.lean to pre-implementation state using git
2. Keep existing sorry-based stubs functional
3. Document blocking issues for future task creation
