# Implementation Plan: Task #514

- **Task**: 514 - Expand test coverage for Metalogic_v2
- **Status**: [COMPLETED]
- **Effort**: 10 hours
- **Priority**: Medium
- **Dependencies**: Metalogic_v2 directory must be stable (no major refactoring)
- **Research Inputs**: specs/514_expand_test_coverage_for_metalogic_v2/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This plan creates comprehensive test coverage for the Metalogic_v2 directory, following the established patterns from the original Metalogic tests. The approach follows the layered architecture: Core, Soundness, Representation, Completeness, and Integration. Tests use example-based verification, type signature verification, soundness application, and property-based testing with Plausible. The existing Generators.lean infrastructure is reused.

### Research Integration

Key findings from research-001.md incorporated:
- Metalogic_v2 follows layered architecture (Core -> Soundness -> Representation -> Completeness)
- Existing test patterns in Tests/BimodalTest/Metalogic/ provide templates
- Property testing infrastructure (Plausible, Generators.lean) is reusable
- Some components have axioms/sorries that limit testability (representation_theorem_backward_empty)
- All 15 axiom validity lemmas in Soundness are fully proven

## Goals & Non-Goals

**Goals**:
- Create test files for all Metalogic_v2 layers (Core, Soundness, Representation, Completeness)
- Follow established test patterns from Metalogic/ tests
- Use property-based testing where applicable
- Verify type signatures of key theorems
- Document test coverage and limitations

**Non-Goals**:
- Testing components with sorries (avoid noncomputable workarounds)
- Creating new property generators (reuse existing)
- Importing from old Metalogic/ directory
- Achieving 100% coverage (axiom-based components have inherent limits)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Axiom `representation_theorem_backward_empty` limits testability | Medium | High | Focus on type signatures and forward direction; document limitations |
| Sorries in Core/Basic.lean block tests | Low | Medium | Skip tests dependent on sorry; mark as known limitation |
| Architecture changes during implementation | Medium | Low | Start with stable Core layer; defer Completeness if needed |
| Property tests timeout on complex formulas | Low | Medium | Use size limits in generators (maxSize: 40) |
| Import conflicts with old Metalogic | High | Low | Use only Metalogic_v2 imports; verify at each phase |

## Implementation Phases

### Phase 1: Core Layer Tests [COMPLETED]

**Goal**: Create comprehensive tests for Core layer (Basic, Provability, DeductionTheorem, MaximalConsistent)

**Tasks**:
- [ ] Create `Tests/BimodalTest/Metalogic_v2/CoreTest.lean` with:
  - [ ] Consistency tests (empty context consistent, contradiction inconsistent)
  - [ ] Provability tests (ContextDerivable type verification)
  - [ ] Deduction theorem application examples
  - [ ] Maximal consistent set tests (lindenbaum, closure, negation completeness)
- [ ] Create `Tests/BimodalTest/Metalogic_v2/CorePropertyTest.lean` with:
  - [ ] Property tests for consistency preservation
  - [ ] Property tests for derivation closure

**Timing**: 2 hours

**Files to create**:
- `Tests/BimodalTest/Metalogic_v2/CoreTest.lean` - Example-based core tests
- `Tests/BimodalTest/Metalogic_v2/CorePropertyTest.lean` - Property-based core tests

**Verification**:
- `lake build Tests.BimodalTest.Metalogic_v2.CoreTest` compiles without errors
- `lake build Tests.BimodalTest.Metalogic_v2.CorePropertyTest` compiles without errors
- All example tests execute successfully

---

### Phase 2: Soundness Layer Tests [COMPLETED]

**Goal**: Create tests for Soundness layer with all 15 axiom validity lemmas

**Tasks**:
- [ ] Create `Tests/BimodalTest/Metalogic_v2/SoundnessTest.lean` with:
  - [ ] Tests for all 15 axiom validity lemmas (prop_k_valid, modal_t_valid, etc.)
  - [ ] Soundness application tests (deriv -> valid)
  - [ ] Soundness type signature verification
- [ ] Create `Tests/BimodalTest/Metalogic_v2/SoundnessPropertyTest.lean` with:
  - [ ] Property tests for axiom validity (forall phi : Formula, ...)
  - [ ] Property tests for soundness preservation

**Timing**: 2 hours

**Files to create**:
- `Tests/BimodalTest/Metalogic_v2/SoundnessTest.lean` - Axiom validity tests
- `Tests/BimodalTest/Metalogic_v2/SoundnessPropertyTest.lean` - Property-based soundness tests

**Verification**:
- All 15 axiom validity lemmas tested
- Property tests pass with 100 instances
- No imports from old Metalogic directory

---

### Phase 3: Representation Layer Tests [COMPLETED]

**Goal**: Create tests for Representation layer (CanonicalModel, TruthLemma, RepresentationTheorem)

**Tasks**:
- [ ] Create `Tests/BimodalTest/Metalogic_v2/RepresentationTest.lean` with:
  - [ ] Canonical model construction tests
  - [ ] Truth lemma variant tests (atom, bot, imp, box)
  - [ ] Representation theorem type signature verification
  - [ ] Strong representation theorem examples
  - [ ] Completeness corollary application

**Timing**: 2 hours

**Files to create**:
- `Tests/BimodalTest/Metalogic_v2/RepresentationTest.lean` - Representation layer tests

**Verification**:
- Canonical model types verified
- Truth lemma coverage for all formula constructors
- Representation theorem type check passes

---

### Phase 4: Completeness Layer Tests [COMPLETED]

**Goal**: Create tests for Completeness layer (WeakCompleteness, StrongCompleteness)

**Tasks**:
- [ ] Create `Tests/BimodalTest/Metalogic_v2/CompletenessTest.lean` with:
  - [ ] Weak completeness type signature verification
  - [ ] Strong completeness type signature verification
  - [ ] `provable_iff_valid` bidirectional tests
  - [ ] Context-based derivability examples (noncomputable)

**Timing**: 1.5 hours

**Files to create**:
- `Tests/BimodalTest/Metalogic_v2/CompletenessTest.lean` - Completeness layer tests

**Verification**:
- Type signatures verified for weak and strong completeness
- `provable_iff_valid` equivalence tested in both directions
- Document axiom dependency limitations

---

### Phase 5: Integration Tests and Documentation [COMPLETED]

**Goal**: Create end-to-end integration tests and test documentation

**Tasks**:
- [ ] Create `Tests/BimodalTest/Integration/Metalogic_v2IntegrationTest.lean` with:
  - [ ] End-to-end workflow (derive -> soundness -> validity)
  - [ ] Layer integration tests (Core -> Representation -> Completeness)
  - [ ] Soundness/Completeness equivalence pathway
- [ ] Create `Tests/BimodalTest/Metalogic_v2/README.md` with:
  - [ ] Test coverage summary
  - [ ] Known limitations (axioms, sorries)
  - [ ] Running instructions
  - [ ] Generator usage notes
- [ ] Verify all test files compile together
- [ ] Run full test suite

**Timing**: 2.5 hours

**Files to create**:
- `Tests/BimodalTest/Integration/Metalogic_v2IntegrationTest.lean` - Integration tests
- `Tests/BimodalTest/Metalogic_v2/README.md` - Test documentation

**Verification**:
- `lake build` succeeds with all test files
- Integration tests demonstrate complete pathway
- README documents all coverage and limitations

## Testing & Validation

- [ ] Each phase: `lake build` succeeds for new test files
- [ ] Phase 2: All 15 axiom validity lemmas have dedicated tests
- [ ] Phase 3: Truth lemma coverage for atom, bot, imp, box, all_past, all_future
- [ ] Phase 5: Full `lake build` succeeds with all test files
- [ ] Phase 5: Property tests pass with 100 instances (Plausible)
- [ ] No imports from deprecated Metalogic/ directory

## Artifacts & Outputs

- `Tests/BimodalTest/Metalogic_v2/CoreTest.lean`
- `Tests/BimodalTest/Metalogic_v2/CorePropertyTest.lean`
- `Tests/BimodalTest/Metalogic_v2/SoundnessTest.lean`
- `Tests/BimodalTest/Metalogic_v2/SoundnessPropertyTest.lean`
- `Tests/BimodalTest/Metalogic_v2/RepresentationTest.lean`
- `Tests/BimodalTest/Metalogic_v2/CompletenessTest.lean`
- `Tests/BimodalTest/Integration/Metalogic_v2IntegrationTest.lean`
- `Tests/BimodalTest/Metalogic_v2/README.md`
- `specs/514_expand_test_coverage_for_metalogic_v2/summaries/implementation-summary-{DATE}.md`

## Rollback/Contingency

If implementation fails:
1. Delete created test files from `Tests/BimodalTest/Metalogic_v2/`
2. Delete integration test from `Tests/BimodalTest/Integration/`
3. Ensure no modifications to existing files (this plan creates new files only)
4. Task can be reattempted after addressing blocking issues

If specific phase fails:
- Phase 1-4: Continue with subsequent phases; mark failed phase tests as TODO
- Phase 5 integration: Can still deliver individual layer tests without integration
